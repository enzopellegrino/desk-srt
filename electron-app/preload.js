const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
    startStreaming: (srtUrl) => ipcRenderer.invoke('start-streaming', srtUrl),
    stopStreaming: () => ipcRenderer.invoke('stop-streaming'),
    getStreamingStatus: () => ipcRenderer.invoke('get-streaming-status'),
    onStreamingStatus: (callback) => ipcRenderer.on('streaming-status', callback),
    startChromeKiosk: () => ipcRenderer.invoke('start-chrome-kiosk'),
    exitChromeKiosk: () => ipcRenderer.invoke('exit-chrome-kiosk'),
    checkBrowser: () => ipcRenderer.invoke('check-browser'),
    hideWindow: () => ipcRenderer.invoke('hide-window'),
    showWindow: () => ipcRenderer.invoke('show-window'),
    getPlatform: () => ipcRenderer.invoke('get-platform'),
    checkFFmpeg: () => ipcRenderer.invoke('check-ffmpeg'),
    openExternal: (url) => ipcRenderer.invoke('open-external', url),
    adjustWindowSize: () => ipcRenderer.invoke('adjust-window-size')
});
