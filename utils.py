"""
Utilities for Desk SRT Application
Gestione logging, errori e utilità varie per Windows Server 2022
"""

import logging
import os
import sys
from datetime import datetime
from pathlib import Path

class SRTLogger:
    """Logger ottimizzato per l'applicazione Desk SRT"""
    
    def __init__(self, log_level=logging.INFO):
        self.log_dir = Path("logs")
        self.log_dir.mkdir(exist_ok=True)
        
        # Setup logger
        self.logger = logging.getLogger("DeskSRT")
        self.logger.setLevel(log_level)
        
        # Evita duplicazione handlers
        if not self.logger.handlers:
            self.setup_handlers()
    
    def setup_handlers(self):
        """Configura i gestori di log"""
        # File handler
        log_file = self.log_dir / f"desk_srt_{datetime.now().strftime('%Y%m%d')}.log"
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        
        # Console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        
        # Formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        
        file_handler.setFormatter(formatter)
        console_handler.setFormatter(formatter)
        
        self.logger.addHandler(file_handler)
        self.logger.addHandler(console_handler)
    
    def info(self, message):
        self.logger.info(message)
    
    def error(self, message):
        self.logger.error(message)
    
    def warning(self, message):
        self.logger.warning(message)
    
    def debug(self, message):
        self.logger.debug(message)

class FFmpegValidator:
    """Validatore per FFmpeg e supporto NVENC"""
    
    @staticmethod
    def check_ffmpeg():
        """Verifica se FFmpeg è disponibile"""
        try:
            import subprocess
            result = subprocess.run(['ffmpeg', '-version'], 
                                  capture_output=True, text=True,
                                  creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
            return result.returncode == 0, result.stdout
        except FileNotFoundError:
            return False, "FFmpeg non trovato"
    
    @staticmethod
    def check_nvenc():
        """Verifica supporto NVENC"""
        try:
            import subprocess
            result = subprocess.run(['ffmpeg', '-encoders'], 
                                  capture_output=True, text=True,
                                  creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
            return 'h264_nvenc' in result.stdout, result.stdout
        except FileNotFoundError:
            return False, "FFmpeg non trovato"
    
    @staticmethod
    def check_nvidia_gpu():
        """Verifica presenza GPU NVIDIA"""
        try:
            import subprocess
            result = subprocess.run(['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'], 
                                  capture_output=True, text=True,
                                  creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
            if result.returncode == 0:
                return True, result.stdout.strip()
            return False, "nvidia-smi failed"
        except FileNotFoundError:
            return False, "nvidia-smi non trovato"

class SystemInfo:
    """Informazioni di sistema per debugging"""
    
    @staticmethod
    def get_system_info():
        """Raccoglie informazioni di sistema"""
        import platform
        import psutil
        
        info = {
            'platform': platform.platform(),
            'python_version': platform.python_version(),
            'cpu_count': psutil.cpu_count(),
            'memory_gb': round(psutil.virtual_memory().total / (1024**3), 2),
            'disk_free_gb': round(psutil.disk_usage('.').free / (1024**3), 2)
        }
        
        # Informazioni GPU se disponibile
        gpu_available, gpu_info = FFmpegValidator.check_nvidia_gpu()
        if gpu_available:
            info['gpu'] = gpu_info
        
        return info
    
    @staticmethod
    def log_system_info(logger):
        """Log delle informazioni di sistema"""
        info = SystemInfo.get_system_info()
        logger.info("=== Informazioni Sistema ===")
        for key, value in info.items():
            logger.info(f"{key}: {value}")
        logger.info("===========================")

class ConfigValidator:
    """Validatore per file di configurazione"""
    
    @staticmethod
    def validate_srt_endpoint(endpoint):
        """Valida un endpoint SRT"""
        if not endpoint.startswith('srt://'):
            return False, "Endpoint deve iniziare con 'srt://'"
        
        # Parsing base dell'URL
        try:
            from urllib.parse import urlparse
            parsed = urlparse(endpoint)
            if not parsed.hostname:
                return False, "Hostname non valido"
            if not parsed.port:
                return False, "Porta non specificata"
            return True, "Endpoint valido"
        except Exception as e:
            return False, f"Errore parsing endpoint: {e}"
    
    @staticmethod
    def validate_resolution(resolution):
        """Valida formato risoluzione (es. 1920x1080)"""
        try:
            width, height = resolution.split('x')
            w, h = int(width), int(height)
            if w <= 0 or h <= 0:
                return False, "Dimensioni devono essere positive"
            if w > 7680 or h > 4320:  # Max 8K
                return False, "Risoluzione troppo alta"
            return True, "Risoluzione valida"
        except ValueError:
            return False, "Formato risoluzione non valido (usa: widthxheight)"

def emergency_stop():
    """Funzione di emergenza per fermare tutti i processi FFmpeg"""
    import subprocess
    import psutil
    
    logger = SRTLogger()
    logger.warning("Avviando arresto di emergenza...")
    
    # Trova tutti i processi FFmpeg
    ffmpeg_processes = []
    for proc in psutil.process_iter(['pid', 'name']):
        try:
            if 'ffmpeg' in proc.info['name'].lower():
                ffmpeg_processes.append(proc)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    # Termina processi FFmpeg
    for proc in ffmpeg_processes:
        try:
            proc.terminate()
            logger.info(f"Terminato processo FFmpeg PID: {proc.pid}")
        except (psutil.NoSuchProcess, psutil.AccessDenied) as e:
            logger.error(f"Errore terminando processo {proc.pid}: {e}")
    
    # Attendi e forza se necessario
    import time
    time.sleep(2)
    
    for proc in ffmpeg_processes:
        try:
            if proc.is_running():
                proc.kill()
                logger.warning(f"Forzata terminazione processo PID: {proc.pid}")
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    logger.info("Arresto di emergenza completato")

if __name__ == "__main__":
    # Test delle utilità
    logger = SRTLogger()
    
    # Test sistema
    SystemInfo.log_system_info(logger)
    
    # Test FFmpeg
    ffmpeg_ok, ffmpeg_info = FFmpegValidator.check_ffmpeg()
    logger.info(f"FFmpeg disponibile: {ffmpeg_ok}")
    
    nvenc_ok, nvenc_info = FFmpegValidator.check_nvenc()
    logger.info(f"NVENC disponibile: {nvenc_ok}")
    
    # Test validazione endpoint
    test_endpoints = [
        "srt://direct-obs4.wyscout.com:10080",
        "http://wrong.com",
        "srt://test.com:1234"
    ]
    
    for endpoint in test_endpoints:
        valid, message = ConfigValidator.validate_srt_endpoint(endpoint)
        logger.info(f"Endpoint {endpoint}: {valid} - {message}")
