#!/usr/bin/env python3
"""
Build script per creare eseguibile standalone di Desk SRT
Usa PyInstaller per evitare falsi positivi antivirus
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def build_executable():
    """Crea eseguibile standalone usando PyInstaller"""
    
    print("🚀 Build Desk SRT Standalone Executable")
    print("=" * 50)
    
    # Verifica ambiente
    if not Path("desk_srt.py").exists():
        print("❌ Errore: desk_srt.py non trovato!")
        return False
    
    # Pulizia build precedenti
    build_dirs = ["build", "dist", "__pycache__"]
    for dir_name in build_dirs:
        if Path(dir_name).exists():
            print(f"🧹 Rimuovo {dir_name}/")
            shutil.rmtree(dir_name)
    
    # Rimuovi file spec precedenti
    spec_files = list(Path(".").glob("*.spec"))
    for spec in spec_files:
        spec.unlink()
        print(f"🧹 Rimosso {spec}")
    
    print("\n📦 Creazione eseguibile con PyInstaller...")
    
    # Comando PyInstaller ottimizzato per Windows target
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--onedir",                     # Usa onedir invece di onefile per compatibilità
        "--windowed",                   # No console window
        "--name", "DeskSRT",           # Nome eseguibile
        "--add-data", "config:config", # Include cartella config (: per cross-platform)
        "--add-data", "README.md:.",   # Include README
        "--distpath", "dist",          # Directory output
        "--workpath", "build",         # Directory build temporanea
        "--noconfirm",                 # No conferma sovrascrittura
        "--target-arch", "x86_64",     # Target Windows x64
        "desk_srt.py"                  # File principale
    ]
    
    # Aggiungi icona se disponibile
    if Path("icon.ico").exists():
        cmd.extend(["--icon", "icon.ico"])
    
    # Rimuovi argomenti vuoti
    cmd = [arg for arg in cmd if arg]
    
    try:
        print(f"Comando: {' '.join(cmd)}")
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        
        print("✅ Build completato con successo!")
        
        # Verifica output
        exe_path = Path("dist/DeskSRT.exe")
        if exe_path.exists():
            size_mb = exe_path.stat().st_size / (1024 * 1024)
            print(f"📁 Eseguibile creato: {exe_path}")
            print(f"📏 Dimensione: {size_mb:.1f} MB")
            
            # Copia file necessari nella dist
            copy_files = [
                ("config/settings.ini", "dist/config/settings.ini"),
                ("README.md", "dist/README.md"),
                ("LICENSE.txt", "dist/LICENSE.txt")
            ]
            
            for src, dst in copy_files:
                src_path = Path(src)
                dst_path = Path(dst)
                if src_path.exists():
                    dst_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src_path, dst_path)
                    print(f"📋 Copiato: {src} → {dst}")
            
            print("\n🎯 Eseguibile standalone pronto!")
            print(f"📍 Percorso: {exe_path.absolute()}")
            print("\n💡 Vantaggi:")
            print("   ✅ Nessuna dipendenza Python richiesta")
            print("   ✅ Meno falsi positivi antivirus")  
            print("   ✅ Distribuzione semplificata")
            print("   ⚠️  Richiede ancora FFmpeg separatamente")
            
            return True
        else:
            print("❌ Errore: Eseguibile non creato!")
            return False
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Errore durante build: {e}")
        print(f"Output: {e.stdout}")
        print(f"Errori: {e.stderr}")
        return False

def create_portable_package():
    """Crea package portable con FFmpeg incluso"""
    
    exe_path = Path("dist/DeskSRT.exe")
    if not exe_path.exists():
        print("❌ Eseguibile non trovato. Esegui prima il build.")
        return False
    
    print("\n📦 Creazione package portable...")
    
    portable_dir = Path("DeskSRT_Portable")
    if portable_dir.exists():
        shutil.rmtree(portable_dir)
    
    portable_dir.mkdir()
    
    # Copia eseguibile e file
    shutil.copy2("dist/DeskSRT.exe", portable_dir / "DeskSRT.exe")
    shutil.copy2("dist/config/settings.ini", portable_dir / "settings.ini")
    shutil.copy2("dist/README.md", portable_dir / "README.md")
    shutil.copy2("dist/LICENSE.txt", portable_dir / "LICENSE.txt")
    
    # Crea script di avvio
    launcher_script = portable_dir / "Avvia_DeskSRT.bat"
    launcher_content = """@echo off
echo Avvio Desk SRT Portable...
echo.
echo NOTA: Assicurati che FFmpeg sia disponibile:
echo - Nel PATH di sistema
echo - Oppure copia ffmpeg.exe in questa cartella
echo.
DeskSRT.exe
pause
"""
    launcher_script.write_text(launcher_content)
    
    print(f"✅ Package portable creato: {portable_dir}")
    print("📁 Contenuto:")
    for item in portable_dir.iterdir():
        size = item.stat().st_size if item.is_file() else 0
        print(f"   📄 {item.name} ({size:,} bytes)")
    
    return True

if __name__ == "__main__":
    success = build_executable()
    
    if success:
        create_portable = input("\n❓ Vuoi creare anche un package portable? (s/n): ")
        if create_portable.lower() == 's':
            create_portable_package()
    
    print("\n🏁 Build completato!")
