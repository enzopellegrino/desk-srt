<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Desk SRT - Screen Capture to SRT Streaming Application

This project is a minimal desktop application that captures the entire screen and streams it to SRT endpoints using FFmpeg with GPU acceleration.

## Project Structure
- Windows Server 2022 desktop application
- FFmpeg integration with GPU acceleration (NVENC/DirectShow)
- Minimal GUI that stays always on top and out of capture area
- Support for multiple SRT destinations (e.g., srt://direct-obs4.wyscout.com:10080, srt://direct-obs4.wyscout.com:10081)

## Development Guidelines
- Use Python with tkinter for Windows GUI
- Leverage FFmpeg with GPU acceleration for screen capture and streaming
- Keep the application window small, always on top, and minimizable
- Use NVENC for hardware-accelerated encoding on Windows Server
- Focus on reliability and low latency streaming
- Provide easy configuration for SRT endpoints

## Key Features
- Full screen capture with GPU acceleration
- Real-time SRT streaming with hardware encoding
- Multiple destination support
- Always on top window behavior
- Minimal resource footprint
- Simple configuration interface
- Windows Server 2022 optimized
