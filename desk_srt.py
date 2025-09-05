#!/usr/bin/env python3
"""
Desk SRT - Screen Capture to SRT Streaming Application
Ottimizzato per Windows Server 2022 con accelerazione GPU NVENC
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import threading
import configparser
import os
import sys
import time
from pathlib import Path

class DeskSRTApp:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.load_config()
        self.setup_gui()
        self.ffmpeg_process = None
        self.is_streaming = False
        
    def setup_window(self):
        """Configura la finestra principale per Windows Server 2022"""
        self.root.title("Desk SRT - Screen Capture")
        self.root.geometry("350x200")
        self.root.resizable(False, False)
        
        # Sempre in primo piano
        self.root.attributes('-topmost', True)
        
        # Posiziona la finestra nell'angolo in alto a destra
        self.root.geometry("350x200+{}+10".format(self.root.winfo_screenwidth() - 360))
        
        # Icona di sistema (se disponibile)
        try:
            self.root.iconbitmap('icon.ico')
        except:
            pass
            
    def load_config(self):
        """Carica le configurazioni dal file settings.ini"""
        self.config = configparser.ConfigParser()
        config_path = Path("config/settings.ini")
        
        if config_path.exists():
            self.config.read(config_path)
        else:
            messagebox.showerror("Errore", "File di configurazione non trovato!")
            sys.exit(1)
            
    def setup_gui(self):
        """Crea l'interfaccia utente minimale"""
        # Frame principale
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Titolo
        title_label = ttk.Label(main_frame, text="Desk SRT Streamer", font=("Arial", 12, "bold"))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))
        
        # Selezione endpoint
        ttk.Label(main_frame, text="Endpoint SRT:").grid(row=1, column=0, sticky=tk.W)
        
        self.endpoint_var = tk.StringVar()
        endpoints = self.config.get('SRT_ENDPOINTS', 'endpoints').split(',')
        self.endpoint_combo = ttk.Combobox(main_frame, textvariable=self.endpoint_var, 
                                          values=endpoints, width=30)
        self.endpoint_combo.grid(row=1, column=1, padx=(5, 0))
        self.endpoint_combo.set(endpoints[0] if endpoints else "")
        
        # Pulsanti controllo
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=2, column=0, columnspan=2, pady=10)
        
        self.start_button = ttk.Button(button_frame, text="Avvia Streaming", 
                                      command=self.start_streaming)
        self.start_button.pack(side=tk.LEFT, padx=(0, 5))
        
        self.stop_button = ttk.Button(button_frame, text="Ferma Streaming", 
                                     command=self.stop_streaming, state=tk.DISABLED)
        self.stop_button.pack(side=tk.LEFT, padx=(5, 0))
        
        # Status
        self.status_var = tk.StringVar(value="Pronto")
        status_label = ttk.Label(main_frame, textvariable=self.status_var, 
                                foreground="green", font=("Arial", 9))
        status_label.grid(row=3, column=0, columnspan=2, pady=(5, 0))
        
        # Pulsante minimizza
        minimize_button = ttk.Button(main_frame, text="Minimizza", 
                                   command=self.minimize_window)
        minimize_button.grid(row=4, column=0, columnspan=2, pady=(10, 0))
        
    def minimize_window(self):
        """Minimizza la finestra"""
        self.root.iconify()
        
    def get_ffmpeg_command(self, endpoint):
        """Genera il comando FFmpeg con accelerazione GPU per Windows"""
        # Parametri dalla configurazione
        fps = self.config.get('VIDEO_SETTINGS', 'fps')
        bitrate = self.config.get('VIDEO_SETTINGS', 'bitrate')
        resolution = self.config.get('VIDEO_SETTINGS', 'resolution')
        preset = self.config.get('VIDEO_SETTINGS', 'preset')
        
        # Parametri NVENC
        codec = self.config.get('ENCODER_SETTINGS', 'codec')
        gpu_device = self.config.get('ENCODER_SETTINGS', 'gpu_device')
        rc_mode = self.config.get('ENCODER_SETTINGS', 'rc_mode')
        profile = self.config.get('ENCODER_SETTINGS', 'profile')
        
        # Parametri cattura
        input_format = self.config.get('CAPTURE_SETTINGS', 'input_format')
        input_device = self.config.get('CAPTURE_SETTINGS', 'input_device')
        
        cmd = [
            'ffmpeg',
            # Input da desktop Windows con GDI
            '-f', input_format,
            '-framerate', fps,
            '-i', input_device,
            
            # Encoder NVENC per GPU acceleration
            '-c:v', codec,
            '-gpu', gpu_device,
            '-preset', preset,
            '-profile:v', profile,
            '-rc', rc_mode,
            '-b:v', bitrate,
            '-maxrate', bitrate,
            '-bufsize', str(int(bitrate) * 2),
            
            # Impostazioni video
            '-s', resolution,
            '-r', fps,
            '-g', str(int(fps) * 2),  # Keyframe interval
            '-bf', '3',
            '-refs', '3',
            
            # Ottimizzazioni low-latency
            '-tune', 'zerolatency',
            '-fflags', 'nobuffer',
            '-flags', 'low_delay',
            
            # Output SRT
            '-f', 'mpegts',
            endpoint
        ]
        
        return cmd
        
    def start_streaming(self):
        """Avvia lo streaming SRT"""
        if self.is_streaming:
            return
            
        endpoint = self.endpoint_var.get().strip()
        if not endpoint:
            messagebox.showerror("Errore", "Seleziona un endpoint SRT")
            return
            
        try:
            cmd = self.get_ffmpeg_command(endpoint)
            
            # Avvia FFmpeg in background
            self.ffmpeg_process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            )
            
            self.is_streaming = True
            self.start_button.config(state=tk.DISABLED)
            self.stop_button.config(state=tk.NORMAL)
            self.status_var.set(f"Streaming a: {endpoint}")
            
            # Monitor del processo in thread separato
            threading.Thread(target=self.monitor_ffmpeg, daemon=True).start()
            
        except FileNotFoundError:
            messagebox.showerror("Errore", "FFmpeg non trovato! Installa FFmpeg e aggiungi al PATH.")
        except Exception as e:
            messagebox.showerror("Errore", f"Errore avvio streaming: {str(e)}")
            
    def stop_streaming(self):
        """Ferma lo streaming SRT"""
        if self.ffmpeg_process and self.is_streaming:
            try:
                self.ffmpeg_process.terminate()
                # Attendi chiusura o forza dopo 5 secondi
                try:
                    self.ffmpeg_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self.ffmpeg_process.kill()
                    
                self.ffmpeg_process = None
            except Exception as e:
                print(f"Errore fermando FFmpeg: {e}")
                
        self.is_streaming = False
        self.start_button.config(state=tk.NORMAL)
        self.stop_button.config(state=tk.DISABLED)
        self.status_var.set("Streaming fermato")
        
    def monitor_ffmpeg(self):
        """Monitora il processo FFmpeg"""
        if self.ffmpeg_process:
            self.ffmpeg_process.wait()
            
            if self.is_streaming:  # Se è terminato inaspettatamente
                self.root.after(0, lambda: self.status_var.set("Errore: Streaming interrotto"))
                self.root.after(0, lambda: self.start_button.config(state=tk.NORMAL))
                self.root.after(0, lambda: self.stop_button.config(state=tk.DISABLED))
                self.is_streaming = False
                
    def on_closing(self):
        """Gestione chiusura applicazione"""
        if self.is_streaming:
            if messagebox.askokcancel("Chiusura", "Vuoi fermare lo streaming e chiudere?"):
                self.stop_streaming()
                self.root.destroy()
        else:
            self.root.destroy()
            
    def run(self):
        """Avvia l'applicazione"""
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        
        # Porta in primo piano all'avvio
        self.root.lift()
        self.root.focus_force()
        
        self.root.mainloop()

def main():
    """Funzione principale"""
    # Verifica se siamo su Windows
    if os.name != 'nt':
        print("Questa applicazione è ottimizzata per Windows Server 2022")
        
    # Verifica FFmpeg
    try:
        subprocess.run(['ffmpeg', '-version'], 
                      capture_output=True, check=True,
                      creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
    except (FileNotFoundError, subprocess.CalledProcessError):
        print("ATTENZIONE: FFmpeg non trovato o non funzionante!")
        print("Installa FFmpeg con supporto NVENC")
        
    # Avvia applicazione
    app = DeskSRTApp()
    app.run()

if __name__ == "__main__":
    main()
