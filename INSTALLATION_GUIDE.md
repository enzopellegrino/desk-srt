# 🔧 Desk SRT Installation Troubleshooting

## Common Installation Issues

### 1. "Windows protected your PC" message
- Click "More info" → "Run anyway"
- Or right-click installer → Properties → Unblock → OK

### 2. Antivirus blocking installation
- Temporarily disable real-time protection
- Add exception for `Desk SRT_Setup_2.3.0.exe`
- Re-enable antivirus after installation

### 3. Installation fails or crashes
- Run installer as Administrator (right-click → "Run as administrator")
- Disable antivirus temporarily
- Close all other programs
- Restart computer and try again

### 4. "This app can't run on your PC"
- Download the universal installer (v2.3.0) which supports both x64 and 32-bit
- Check Windows version: requires Windows 10/11 or Windows Server 2022

### 5. FFmpeg not found after installation
- Download FFmpeg from: https://ffmpeg.org/download.html#build-windows
- Extract to C:\ffmpeg\bin\
- Add C:\ffmpeg\bin\ to system PATH
- Restart Desk SRT

### 6. Chrome/Edge kiosk mode not working
- Install Chrome: https://www.google.com/chrome/
- Or ensure Edge is updated to latest version
- Check that browser is in standard installation path

## Installation Steps

1. **Download** `Desk SRT_Setup_2.3.0.exe` (164MB)
2. **Right-click** → "Run as administrator"
3. **Follow** the installation wizard
4. **Install FFmpeg** if prompted
5. **Launch** from desktop shortcut or Start Menu

## Post-Installation

- First run may show FFmpeg/browser detection messages
- Follow on-screen instructions for missing dependencies
- Demo mode banner appears on macOS (normal behavior)

## Support

If issues persist:
- Check Windows Event Viewer for error details
- Ensure Windows Defender/antivirus exceptions
- Try running in Windows compatibility mode
- Contact via GitHub issues: https://github.com/enzopellegrino/desk-srt/issues
