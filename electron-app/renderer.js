let isStreaming = false;
let chromeKioskActive = false;
let windowHidden = false;
let countdownInterval = null;

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
                updateStatus(`❌ Chrome: ${result.message}`, 'stopped');
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
        updateStatus(`❌ Chrome Error: ${error.message}`, 'stopped');
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
        }
        
        // Check streaming status
        const status = await window.electronAPI.getStreamingStatus();
        if (status.streaming) {
            updateStatus('🔴 Stream active', 'streaming');
            updateButtons(false);
            isStreaming = true;
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
