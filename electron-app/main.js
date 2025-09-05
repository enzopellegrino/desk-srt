const { app, BrowserWindow, ipcMain, dialog, globalShortcut, Tray, Menu, nativeImage, shell } = require('electron');
const path = require('path');
const { spawn, exec } = require('child_process');
const os = require('os');
const fs = require('fs');

let mainWindow;
let ffmpegProcess = null;
let chromeProcess = null;
let isStreaming = false;
let tray = null;

// Check FFmpeg availability
function checkFFmpeg() {
    return new Promise((resolve) => {
        const platform = os.platform();
        
        if (platform === 'win32') {
            // First try PATH command
            exec('where ffmpeg', (error, stdout, stderr) => {
                if (!error) {
                    const ffmpegPath = stdout.trim();
                    console.log(`✅ FFmpeg found in PATH: ${ffmpegPath}`);
                    resolve({ available: true, path: ffmpegPath });
                    return;
                }
                
                // If not in PATH, check common installation locations
                const commonPaths = [
                    'C:\\ffmpeg\\bin\\ffmpeg.exe',
                    'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe',
                    'C:\\Program Files (x86)\\ffmpeg\\bin\\ffmpeg.exe',
                    `${process.env.USERPROFILE}\\ffmpeg\\bin\\ffmpeg.exe`,
                    `${process.env.LOCALAPPDATA}\\ffmpeg\\bin\\ffmpeg.exe`,
                    `${process.env.PROGRAMFILES}\\ffmpeg\\bin\\ffmpeg.exe`,
                    `${process.env['PROGRAMFILES(X86)']}\\ffmpeg\\bin\\ffmpeg.exe`,
                    'C:\\tools\\ffmpeg\\bin\\ffmpeg.exe'
                ];
                
                for (const path of commonPaths) {
                    try {
                        if (fs.existsSync(path)) {
                            console.log(`✅ FFmpeg found at: ${path}`);
                            resolve({ available: true, path: path });
                            return;
                        }
                    } catch (err) {
                        console.log(`❌ Error checking ${path}: ${err.message}`);
                    }
                }
                
                console.log('❌ FFmpeg not found in PATH or common locations');
                resolve({ available: false, path: null });
            });
        } else {
            // macOS/Linux - use which command
            exec('which ffmpeg', (error, stdout, stderr) => {
                if (error) {
                    console.log('❌ FFmpeg not found in PATH');
                    resolve({ available: false, path: null });
                } else {
                    const ffmpegPath = stdout.trim();
                    console.log(`✅ FFmpeg found: ${ffmpegPath}`);
                    resolve({ available: true, path: ffmpegPath });
                }
            });
        }
    });
}

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 480,
        height: 580,
        minWidth: 450,
        minHeight: 550,
        maxWidth: 600,
        alwaysOnTop: true,
        resizable: true,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        },
        title: 'Desk SRT - Screen Capture by Enzo Pellegrino',
        autoHideMenuBar: true,
        show: false  // Don't show until ready
    });

    mainWindow.loadFile('index.html');
    
    // Show window when ready to avoid flash
    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
    });
    
    // Hide menu bar completely
    mainWindow.setMenuBarVisibility(false);
    
    // Position window outside capture area but visible (top-right corner)
    const { screen } = require('electron');
    const primaryDisplay = screen.getPrimaryDisplay();
    const { width, height } = primaryDisplay.workAreaSize;
    
    // Position the window in the top-right corner, fully visible
    const windowX = width - 580;  // Leave some margin from right edge
    const windowY = 20;           // Small margin from top
    
    mainWindow.setPosition(windowX, windowY);
    
    // Make sure window stays on top but not during capture
    mainWindow.setAlwaysOnTop(true, 'floating', 1);
}

// Function to adjust window size based on content
function adjustWindowSize() {
    if (!mainWindow || mainWindow.isDestroyed()) return;
    
    try {
        // Simple approach: just make the window more compact
        const [currentWidth] = mainWindow.getSize();
        const newHeight = 580; // Increased height for better visibility
        mainWindow.setSize(currentWidth, newHeight);
        console.log(`Window resized to: ${currentWidth}x${newHeight}`);
    } catch (err) {
        console.log('Could not resize window:', err);
    }
}

function createTray() {
    // Create tray icon (we'll use a simple emoji for now)
    const iconPath = path.join(__dirname, 'assets', 'tray-icon.png');
    
    // Create a simple tray icon if file doesn't exist
    try {
        if (!fs.existsSync(iconPath)) {
            // Use the app icon or create a simple one
            tray = new Tray(path.join(__dirname, 'assets', 'icon.ico'));
        } else {
            tray = new Tray(iconPath);
        }
    } catch (error) {
        // Fallback: create tray without icon
        tray = new Tray(nativeImage.createEmpty());
    }
    
    // Create context menu for tray
    const contextMenu = Menu.buildFromTemplate([
        {
            label: 'Show Desk SRT',
            click: () => {
                showMainWindow();
            }
        },
        {
            label: 'Hide Window',
            click: () => {
                mainWindow.hide();
            }
        },
        { type: 'separator' },
        {
            label: 'Stream Status',
            enabled: false
        },
        {
            label: isStreaming ? '🔴 Streaming Active' : '⏹ Stream Stopped',
            enabled: false
        },
        { type: 'separator' },
        {
            label: 'Quit Desk SRT',
            click: () => {
                app.quit();
            }
        }
    ]);
    
    tray.setContextMenu(contextMenu);
    tray.setToolTip('Desk SRT - Screen Capture');
    
    // Double click to show window
    tray.on('double-click', () => {
        showMainWindow();
    });
}

function registerGlobalShortcuts() {
    // Global shortcut to show/hide window: Ctrl+Shift+D
    globalShortcut.register('CommandOrControl+Shift+D', () => {
        if (mainWindow.isVisible()) {
            mainWindow.hide();
        } else {
            showMainWindow();
        }
    });
    
    // Emergency exit for Chrome kiosk: Ctrl+Shift+Escape
    globalShortcut.register('CommandOrControl+Shift+Escape', () => {
        if (chromeProcess) {
            console.log('🚨 Emergency exit: Terminating Chrome kiosk');
            chromeProcess.kill();
            chromeProcess = null;
            showMainWindow();
        }
    });
    
    // Alternative exit: Ctrl+Alt+Q 
    globalShortcut.register('CommandOrControl+Alt+Q', () => {
        if (chromeProcess) {
            console.log('🚨 Alternative exit: Terminating Chrome kiosk');
            chromeProcess.kill();
            chromeProcess = null;
            showMainWindow();
        }
    });
    
    // Global shortcut to toggle streaming: Ctrl+Shift+S
    globalShortcut.register('CommandOrControl+Shift+S', () => {
        if (isStreaming) {
            // Stop streaming
            if (ffmpegProcess) {
                ffmpegProcess.kill();
                ffmpegProcess = null;
            }
            isStreaming = false;
        } else {
            // Quick start streaming with default settings
            const defaultUrl = 'srt://direct-obs4.wyscout.com:10080';
            // We could implement quick start here
        }
    });
}

function showMainWindow() {
    if (mainWindow.isMinimized()) {
        mainWindow.restore();
    }
    mainWindow.show();
    mainWindow.focus();
}

function updateTrayMenu() {
    if (tray) {
        const contextMenu = Menu.buildFromTemplate([
            {
                label: 'Show Desk SRT',
                click: () => {
                    showMainWindow();
                }
            },
            {
                label: 'Hide Window',
                click: () => {
                    mainWindow.hide();
                }
            },
            { type: 'separator' },
            {
                label: 'Stream Status',
                enabled: false
            },
            {
                label: isStreaming ? '🔴 Streaming Active' : '⏹ Stream Stopped',
                enabled: false
            },
            { type: 'separator' },
            {
                label: 'Quit Desk SRT',
                click: () => {
                    app.quit();
                }
            }
        ]);
        tray.setContextMenu(contextMenu);
    }
}

app.whenReady().then(() => {
    createWindow();
    createTray();
    registerGlobalShortcuts();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        } else {
            mainWindow.show();
            mainWindow.focus();
        }
    });
});

app.on('before-quit', () => {
    // Clean up processes before quitting
    if (ffmpegProcess) {
        ffmpegProcess.kill();
    }
    if (chromeProcess) {
        chromeProcess.kill();
    }
    
    // Unregister global shortcuts
    globalShortcut.unregisterAll();
});

app.on('window-all-closed', () => {
    // Don't quit on window close, keep running in tray
    if (process.platform !== 'darwin') {
        // On Windows/Linux, keep app running in tray
        // Uncomment next line if you want to quit when window closes:
        // app.quit();
    }
});

// IPC handlers
ipcMain.handle('start-streaming', async (event, srtUrl) => {
    if (isStreaming) {
        return { success: false, message: 'Stream already active' };
    }

    try {
        // Check FFmpeg availability first
        const ffmpegCheck = await checkFFmpeg();
        if (!ffmpegCheck.available) {
            return { 
                success: false, 
                message: 'FFmpeg not found. Please install FFmpeg and add it to your PATH.\n\nFor Windows:\n1. Download from https://ffmpeg.org/download.html#build-windows\n2. Extract to C:\\ffmpeg\n3. Add C:\\ffmpeg\\bin to PATH\n4. Restart the application' 
            };
        }

        // Check if on macOS - use demo mode for testing countdown
        if (os.platform() === 'darwin') {
            console.log('🍎 Running on macOS - Demo mode (countdown test)');
            isStreaming = true;
            
            // Simulate successful stream start for testing
            setTimeout(() => {
                if (mainWindow) {
                    mainWindow.webContents.send('streaming-status', { 
                        streaming: true 
                    });
                }
            }, 100);
            
            return { success: true, message: 'Demo mode - Stream simulated' };
        }

        // FFmpeg command optimized for EC2 g4.xlarge (NVIDIA T4) with window exclusion
        const ffmpegArgs = [
            // Video input - Windows screen capture with window exclusion
            '-f', 'gdigrab',
            '-framerate', '30',
            '-video_size', '1920x1080',
            '-show_region', '1',  // Show capture region (helps exclude our window)
            '-i', 'desktop',
            // Audio input - system audio capture
            '-f', 'dshow',
            '-i', 'audio="Stereo Mix"',
            // Video filters to exclude our window (we'll position it outside capture area)
            '-vf', 'scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2',
            // Video encoding optimized for NVIDIA T4
            '-c:v', 'h264_nvenc',
            '-preset', 'p4',          // Preset optimized for T4
            '-tune', 'ull',           // Ultra Low Latency for streaming
            '-profile:v', 'high',
            '-level', '4.1',
            '-pix_fmt', 'yuv420p',
            '-b:v', '4000k',          // Optimal bitrate for T4
            '-maxrate', '5000k',
            '-bufsize', '8000k',
            '-g', '60',               // Optimized GOP
            '-keyint_min', '30',
            '-r', '30',
            '-rc', 'cbr',             // Constant bitrate for streaming
            // Audio encoding
            '-c:a', 'aac',
            '-b:a', '192k',           // Increased audio quality
            '-ar', '48000',           // Professional sample rate
            '-ac', '2',
            // SRT specific optimizations
            '-f', 'mpegts',
            '-muxrate', '5000k',
            srtUrl
        ];

        ffmpegProcess = spawn('ffmpeg', ffmpegArgs, {
            stdio: ['pipe', 'pipe', 'pipe']
        });

        ffmpegProcess.on('error', (error) => {
            console.error('Errore FFmpeg:', error);
            isStreaming = false;
            mainWindow.webContents.send('streaming-status', { streaming: false, error: error.message });
        });

        ffmpegProcess.on('close', (code) => {
            console.log(`FFmpeg terminato con codice ${code}`);
            isStreaming = false;
            mainWindow.webContents.send('streaming-status', { streaming: false });
        });

        isStreaming = true;
        updateTrayMenu(); // Update tray menu to show streaming status
        
        // Hide window during streaming to avoid capture (optional)
        // mainWindow.minimize(); // Uncomment to auto-minimize during stream
        
        return { success: true, message: 'Streaming started successfully' };
    } catch (error) {
        return { success: false, message: `Error: ${error.message}` };
    }
});

ipcMain.handle('stop-streaming', async () => {
    if (os.platform() === 'darwin') {
        console.log('🍎 macOS Demo mode - Stopping simulated stream');
        isStreaming = false;
        updateTrayMenu(); // Update tray menu to show stopped status
        
        // Notify renderer that stream stopped
        if (mainWindow) {
            mainWindow.webContents.send('streaming-status', { 
                streaming: false 
            });
        }
        
        return { success: true, message: 'Demo stream stopped' };
    }
    
    if (ffmpegProcess) {
        ffmpegProcess.kill();
        ffmpegProcess = null;
    }
    isStreaming = false;
    updateTrayMenu(); // Update tray menu to show stopped status
    return { success: true, message: 'Stream stopped' };
});

ipcMain.handle('get-streaming-status', async () => {
    return { streaming: isStreaming };
});

// Funzione per verificare la disponibilità dei browser
function checkBrowserAvailability() {
    if (os.platform() === 'win32') {
        const chromePaths = [
            'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
            'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
            `${process.env.LOCALAPPDATA}\\Google\\Chrome\\Application\\chrome.exe`,
            `${process.env.PROGRAMFILES}\\Google\\Chrome\\Application\\chrome.exe`,
            'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
            'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
            `${process.env.PROGRAMFILES}\\Microsoft\\Edge\\Application\\msedge.exe`,
            `${process.env['PROGRAMFILES(X86)']}\\Microsoft\\Edge\\Application\\msedge.exe`
        ];

        for (const browserPath of chromePaths) {
            try {
                if (fs.existsSync(browserPath)) {
                    const browserName = browserPath.includes('msedge') ? 'Edge' : 'Chrome';
                    console.log(`✅ ${browserName} disponibile: ${browserPath}`);
                    return { available: true, path: browserPath, name: browserName };
                }
            } catch (error) {
                console.log(`❌ Controllo fallito: ${browserPath} - ${error.message}`);
            }
        }
    } else {
        // macOS/Linux fallback
        return { available: false, path: null, name: null };
    }
    
    console.log('⚠️ Nessun browser trovato nei percorsi standard');
    return { available: false, path: null, name: null };
}

ipcMain.handle('check-browser', async () => {
    return checkBrowserAvailability();
});

// Chrome Kiosk handlers
ipcMain.handle('start-chrome-kiosk', async () => {
    if (chromeProcess) {
        return { success: false, message: 'Browser already running' };
    }

    try {
        // Check browser availability first
        const browserCheck = checkBrowserAvailability();
        if (!browserCheck.available) {
            return { 
                success: false, 
                message: 'No compatible browser found. Please install Chrome or Edge.\n\nFor Windows:\n1. Install Google Chrome or Microsoft Edge\n2. Restart the application' 
            };
        }

        // Comando per avviare browser in modalità kiosk
        const browserArgs = [
            '--kiosk',
            '--disable-infobars',
            '--disable-session-crashed-bubble',
            '--disable-restore-session-state',
            '--disable-web-security',
            '--disable-features=VizDisplayCompositor',
            '--start-fullscreen',
            '--no-first-run',
            '--disable-translate',
            '--disable-default-apps',
            '--disable-popup-blocking',
            '--disable-extensions',
            '--disable-plugins',
            '--no-default-browser-check',
            'https://example.com'  // Pagina di test semplice e veloce
        ];

        console.log(`🌐 Avvio ${browserCheck.name} kiosk: ${browserCheck.path}`);
        
        chromeProcess = spawn(browserCheck.path, browserArgs, {
            detached: true,
            stdio: 'ignore'
        });

        chromeProcess.on('error', (error) => {
            console.error(`Errore ${browserCheck.name}:`, error);
            chromeProcess = null;
        });

        chromeProcess.on('close', (code) => {
            console.log(`${browserCheck.name} terminato con codice ${code}`);
            chromeProcess = null;
        });

        return { 
            success: true, 
            message: `${browserCheck.name} Kiosk started\n\nEmergency Exit:\n• Ctrl+Shift+Esc - Force close kiosk\n• Ctrl+Alt+Q - Alternative exit\n• Use "Exit Kiosk" button in app`, 
            browserName: browserCheck.name 
        };
    } catch (error) {
        return { success: false, message: `Error: ${error.message}` };
    }
});

ipcMain.handle('exit-chrome-kiosk', async () => {
    if (chromeProcess) {
        chromeProcess.kill();
        chromeProcess = null;
        return { success: true, message: 'Browser Kiosk terminated' };
    }
    return { success: false, message: 'Browser not running' };
});

// Window visibility handlers
ipcMain.handle('hide-window', async () => {
    try {
        mainWindow.hide(); // Use hide instead of minimize for better control
        return { success: true, message: 'Window hidden (use Ctrl+Shift+D or tray to show)' };
    } catch (error) {
        return { success: false, message: `Error: ${error.message}` };
    }
});

ipcMain.handle('show-window', async () => {
    try {
        showMainWindow();
        return { success: true, message: 'Window shown' };
    } catch (error) {
        return { success: false, message: `Error: ${error.message}` };
    }
});

// Window resize handler
ipcMain.handle('adjust-window-size', async () => {
    try {
        adjustWindowSize();
        return { success: true, message: 'Window resized' };
    } catch (error) {
        return { success: false, message: `Error: ${error.message}` };
    }
});

ipcMain.handle('get-platform', async () => {
    return os.platform();
});

ipcMain.handle('check-ffmpeg', async () => {
    return await checkFFmpeg();
});

ipcMain.handle('open-external', async (event, url) => {
    try {
        await shell.openExternal(url);
        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

// Gestione errori non catturati
process.on('uncaughtException', (error) => {
    console.error('Errore non catturato:', error);
    if (ffmpegProcess) {
        ffmpegProcess.kill();
    }
});
