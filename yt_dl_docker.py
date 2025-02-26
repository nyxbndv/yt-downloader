from flask import Flask, request, jsonify, render_template, Response
import subprocess
import os
import threading

app = Flask(__name__)

# Environment variables for permissions
PUID = os.getenv("PUID", "1000")
PGID = os.getenv("PGID", "100")
UMASK = os.getenv("UMASK", "022")

BASE_DIR = os.path.abspath(".")
DOWNLOAD_DIR = os.path.join(BASE_DIR, "downloads")
LOG_FILE = os.path.join(BASE_DIR, "logs.txt")
FFMPEG = os.path.join(BASE_DIR, "ffmpeg")
YT_DLP = "/app/yt-dlp"

# Ensure directories exist
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

# Ensure logs.txt exists
if not os.path.exists(LOG_FILE):
    open(LOG_FILE, "w").close()

def write_log(message):
    """Writes a message to the log file and flushes it immediately."""
    with open(LOG_FILE, "a") as log_file:
        log_file.write(message + "\n")
        log_file.flush()  # Ensure real-time updates

def download_video(url, format_option):
    """Handles video downloads and logs full yt-dlp output without filtering."""
    write_log(f"Starting download: {url} with format {format_option}")

    commands = {
        "standard": [YT_DLP, "-f", "bestvideo+bestaudio", "--ffmpeg-location", FFMPEG, "-o", os.path.join(DOWNLOAD_DIR, "%(title)s.%(ext)s"), url],
        "audio_only": [YT_DLP, "-f", "bestaudio", "--extract-audio", "--audio-format", "mp3", "--ffmpeg-location", FFMPEG, "-o", os.path.join(DOWNLOAD_DIR, "%(title)s.%(ext)s"), url],
    }

    process = subprocess.Popen(commands[format_option], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)

    for line in iter(process.stdout.readline, ''):
        write_log(line.strip())  # ✅ Log everything, no filtering

    process.wait()
    write_log("✅ Download Complete!")

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    data = request.json
    threading.Thread(target=download_video, args=(data["url"], data["format"]), daemon=True).start()
    return jsonify({"message": "Download started."})

@app.route('/logs', methods=['GET'])
def get_logs():
    return Response(open(LOG_FILE, "r"), mimetype="text/plain")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
