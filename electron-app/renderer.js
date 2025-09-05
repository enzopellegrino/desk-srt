let isStreaming = false;
let chromeKioskActive = false;
let windowHidden = false;
let countdownInterval = null;

// Helper function to adjust window size with delay
function adjustWindowSizeDelayed() {
    // Wait a bit for DOM changes to complete
    setTimeout(async () => {
        try {
            if (window.electronAPI.adjustWindowSize) {
                await window.electronAPI.adjustWindowSize();
            }
        } catch (error) {
            console.log('Window resize not available:', error);
        }
    }, 100);
}

async function startStreaming() {
    const srtUrl = document.getElementById('srtUrl').value.trim();
    
    if (!srtUrl) {
        updateStatus('⚠️ Enter a valid SRT URL', 'stopped');
        return;
    }
    
    // If stream is already running, just hide window
    if (isStreaming) {
        try {
            await window.electronAPI.hideWindow();
            windowHidden = true;
            const hideBtn = document.getElementById('hideBtn');
            hideBtn.textContent = '👁️ Show Window';
            hideBtn.className = 'btn-hide hidden';
        } catch (error) {
            console.error('Hide failed:', error);
        }
        return;
    }
    
    // Start countdown and then stream
    await startCountdownAndStream(srtUrl);
}

async function startCountdownAndStream(srtUrl) {
    console.log('🚀 Starting countdown and stream with URL:', srtUrl);
    updateButtons(false); // Disable buttons during countdown
    
    let countdown = 5; // 5 second countdown
    
    // Show countdown
    console.log(`🕐 Countdown: ${countdown} seconds`);
    updateStatus(`🚀 Starting stream in ${countdown}s... App will auto-hide`, 'countdown');
    
    countdownInterval = setInterval(async () => {
        countdown--;
        
        if (countdown > 0) {
            console.log(`🕐 Countdown: ${countdown} seconds`);
            updateStatus(`🚀 Starting stream in ${countdown}s... App will auto-hide`, 'countdown');
        } else {
            // Countdown finished, start streaming
            clearInterval(countdownInterval);
            countdownInterval = null;
            
            updateStatus('🔄 Starting stream...', 'stopped');
            
            try {
                const result = await window.electronAPI.startStreaming(srtUrl);
                
                if (result.success) {
                    isStreaming = true;
                    updateStatus('🔴 Stream active - App will hide in 2s', 'streaming');
                    updateButtons(false);
                    
                    // Auto-hide window after 2 more seconds
                    setTimeout(async () => {
                        try {
                            await window.electronAPI.hideWindow();
                            windowHidden = true;
                            const hideBtn = document.getElementById('hideBtn');
                            hideBtn.textContent = '👁️ Show Window';
                            hideBtn.className = 'btn-hide hidden';
                        } catch (error) {
                            console.error('Auto-hide failed:', error);
                        }
                    }, 2000);
                    
                } else {
                    updateStatus(`❌ ${result.message}`, 'stopped');
                    updateButtons(true);
                }
            } catch (error) {
                updateStatus(`❌ Error: ${error.message}`, 'stopped');
                updateButtons(true);
            }
        }
    }, 1000);
}

async function stopStreaming() {
    // Clear countdown if active
    if (countdownInterval) {
        clearInterval(countdownInterval);
        countdownInterval = null;
        updateStatus('⏹ Stream start cancelled', 'stopped');
        updateButtons(true);
        return;
    }

    try {
        const result = await window.electronAPI.stopStreaming();
        
        if (result.success) {
            isStreaming = false;
            updateStatus('⏹ Stream stopped', 'stopped');
            updateButtons(true);
            
            // Show window when stream stops
            if (windowHidden) {
                try {
                    await window.electronAPI.showWindow();
                    windowHidden = false;
                    const hideBtn = document.getElementById('hideBtn');
                    hideBtn.textContent = '👁️ Hide Window';
                    hideBtn.className = 'btn-hide';
                } catch (error) {
                    console.error('Auto-show failed:', error);
                }
            }
        }
    } catch (error) {
        updateStatus(`❌ Error: ${error.message}`, 'stopped');
    }
}

function updateStatus(message, type) {
    console.log(`📊 Status update: ${message} (type: ${type})`);
    const statusElement = document.getElementById('status');
    statusElement.textContent = message;
    statusElement.className = `status ${type}`;
    
    // Adjust window size when status changes
    adjustWindowSizeDelayed();
}

function updateButtons(canStart) {
    const startBtn = document.getElementById('startBtn');
    const stopBtn = document.getElementById('stopBtn');
    
    if (canStart) {
        startBtn.disabled = false;
        stopBtn.disabled = true;
        startBtn.textContent = '▶ Start Stream';
        stopBtn.textContent = '⏹ Stop Stream';
    } else {
        startBtn.disabled = true;
        stopBtn.disabled = false;
        
        if (countdownInterval) {
            // During countdown, show cancel option
            startBtn.textContent = '⏸️ Cancelled';
            stopBtn.textContent = '❌ Cancel Start';
        } else {
            // During streaming
            startBtn.textContent = '🔴 Streaming...';
            stopBtn.textContent = '⏹ Stop Stream';
        }
    }
}

function updateSrtUrl() {
    const serverSelect = document.getElementById('serverSelect');
    const portSelect = document.getElementById('portSelect');
    const srtUrl = document.getElementById('srtUrl');
    
    const server = serverSelect.value;
    const port = portSelect.value;
    
    if (server && port) {
        srtUrl.value = `srt://${server}:${port}`;
    }
}

async function toggleWindowVisibility() {
    const hideBtn = document.getElementById('hideBtn');
    
    try {
        if (windowHidden) {
            await window.electronAPI.showWindow();
            windowHidden = false;
            hideBtn.textContent = '👁️ Hide Window';
            hideBtn.className = 'btn-hide';
        } else {
            await window.electronAPI.hideWindow();
            windowHidden = true;
            hideBtn.textContent = '👁️ Show Window';
            hideBtn.className = 'btn-hide hidden';
        }
    } catch (error) {
        updateStatus(`❌ Error: ${error.message}`, 'stopped');
    }
}

async function toggleChromeKiosk() {
    const chromeBtn = document.getElementById('chromeBtn');
    
    try {
        if (!chromeKioskActive) {
            // Start kiosk mode
            const result = await window.electronAPI.startChromeKiosk();
            if (result.success) {
                chromeKioskActive = true;
                const browserName = result.browserName || 'Chrome';
                chromeBtn.textContent = `🌐 Exit ${browserName} Kiosk`;
                chromeBtn.className = 'btn-chrome kiosk-active';
            } else {
                updateStatus(`❌ Chrome: ${result.message}`, 'error');
            }
        } else {
            // Exit kiosk mode
            const result = await window.electronAPI.exitChromeKiosk();
            if (result.success) {
                chromeKioskActive = false;
                chromeBtn.textContent = '🌐 Start Chrome Kiosk';
                chromeBtn.className = 'btn-chrome';
            }
        }
    } catch (error) {
        updateStatus(`❌ Chrome Error: ${error.message}`, 'error');
    }
}

async function openFFmpegDownload() {
    try {
        await window.electronAPI.openExternal?.('https://ffmpeg.org/download.html#build-windows');
    } catch (error) {
        console.error('Failed to open FFmpeg download:', error);
        updateStatus('💡 Visit: https://ffmpeg.org/download.html#build-windows', 'error');
    }
}

// Function to recheck FFmpeg availability
async function recheckFFmpeg() {
    try {
        updateStatus('🔍 Checking FFmpeg installation...', 'countdown');
        const ffmpegCheck = await window.electronAPI.checkFFmpeg?.();
        
        if (ffmpegCheck?.available) {
            updateStatus('✅ FFmpeg found! Ready to stream', 'stopped');
            // Re-enable start button
            const startBtn = document.getElementById('startBtn');
            startBtn.disabled = false;
            startBtn.textContent = '▶ Start Stream';
            startBtn.title = 'Start streaming to SRT server';
            
            // Hide FFmpeg helper
            const ffmpegHelper = document.getElementById('ffmpegHelper');
            ffmpegHelper.style.display = 'none';
            
            // Adjust window size
            adjustWindowSizeDelayed();
        } else {
            updateStatus('❌ FFmpeg still not found - Check installation guide', 'error');
        }
    } catch (error) {
        console.error('FFmpeg recheck failed:', error);
        updateStatus('⚠️ Could not check FFmpeg status', 'error');
    }
}

// Listen for streaming status updates
window.electronAPI.onStreamingStatus((event, status) => {
    if (status.streaming) {
        updateStatus('🔴 Stream active', 'streaming');
        updateButtons(false);
    } else {
        if (status.error) {
            updateStatus(`❌ Error: ${status.error}`, 'stopped');
        } else {
            updateStatus('⏹ Stream stopped', 'stopped');
        }
        updateButtons(true);
    }
    isStreaming = status.streaming;
});

// Check initial status
window.addEventListener('DOMContentLoaded', async () => {
    try {
        // Check if on macOS and show demo mode message
        const platform = await window.electronAPI.getPlatform?.() || 'unknown';
        if (platform === 'darwin') {
            updateStatus('🍎 Demo Mode - Test countdown functionality', 'stopped');
            // Show demo mode banner
            const demoBanner = document.getElementById('demoModeBanner');
            if (demoBanner) {
                demoBanner.style.display = 'block';
                // Adjust window size after showing banner
                adjustWindowSizeDelayed();
            }
        }
        
        // Check FFmpeg availability on Windows
        if (platform === 'win32') {
            try {
                const ffmpegCheck = await window.electronAPI.checkFFmpeg?.();
                if (!ffmpegCheck?.available) {
                    updateStatus('❌ FFmpeg not found in PATH or common locations', 'error');
                    // Disable start button until FFmpeg is installed
                    const startBtn = document.getElementById('startBtn');
                    startBtn.disabled = true;
                    startBtn.textContent = '❌ Install FFmpeg First';
                    startBtn.title = 'Download from https://ffmpeg.org/download.html#build-windows';
                    
                    // Show FFmpeg helper button
                    const ffmpegHelper = document.getElementById('ffmpegHelper');
                    ffmpegHelper.style.display = 'block';
                    
                    // Show installation instructions
                    setTimeout(() => {
                        updateStatus('📥 Extract FFmpeg to C:\\ffmpeg\\bin\\ or add to PATH', 'error');
                        // Adjust window size after content change
                        adjustWindowSizeDelayed();
                    }, 3000);
                    
                    // Adjust window size after showing error content
                    adjustWindowSizeDelayed();
                    return;
                } else {
                    updateStatus('✅ FFmpeg ready - Select server and port to start streaming', 'stopped');
                }
            } catch (error) {
                console.error('FFmpeg check failed:', error);
                updateStatus('⚠️ Could not check FFmpeg status', 'error');
            }
        }
        
        // Check streaming status
        const status = await window.electronAPI.getStreamingStatus();
        if (status.streaming) {
            updateStatus('🔴 Stream active', 'streaming');
            updateButtons(false);
            isStreaming = true;
        } else {
            // Only update status if not on macOS demo mode
            if (platform !== 'darwin') {
                updateStatus('⏹ Ready to stream', 'stopped');
            }
            // Keep demo mode message visible on macOS
        }
        
        // Check browser availability
        const browserCheck = await window.electronAPI.checkBrowser();
        const chromeBtn = document.getElementById('chromeBtn');
        
        if (browserCheck.available) {
            console.log(`✅ Browser available: ${browserCheck.name}`);
            if (browserCheck.name === 'Edge') {
                chromeBtn.textContent = '🌐 Start Edge Kiosk';
            }
        } else {
            console.log('⚠️ No compatible browser found');
            chromeBtn.disabled = true;
            chromeBtn.textContent = '❌ Browser not found';
            chromeBtn.style.opacity = '0.5';
            chromeBtn.title = 'Please install Google Chrome or Microsoft Edge';
            
            // Show browser installation message after a delay
            if (platform === 'win32') {
                setTimeout(() => {
                    updateStatus('💡 Install Chrome or Edge for kiosk mode', 'stopped');
                }, 5000);
            }
        }
    } catch (error) {
        console.error('Initial check error:', error);
    }
});

// Keyboard shortcuts
document.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' && !isStreaming) {
        startStreaming();
    } else if (event.key === 'Escape' && isStreaming) {
        stopStreaming();
    }
});
