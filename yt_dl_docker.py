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
FFMPEG = os.path.join(BASE_DIR, "ffmpeg")  # Use the locally installed ffmpeg
YT_DLP = os.path.join(BASE_DIR, "yt-dlp")  # Use the locally installed yt-dlp

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
    """Handles video downloads and logs output."""
    write_log(f"Starting download: {url} with format {format_option}")

    commands = {
        "standard": [YT_DLP, "-f", "bestvideo+bestaudio", "--ffmpeg-location", FFMPEG, "-o", os.path.join(DOWNLOAD_DIR, "%(title)s.%(ext)s"), url],
        "audio_only": [YT_DLP, "-f", "bestaudio", "--extract-audio", "--audio-format", "mp3", "--ffmpeg-location", FFMPEG, "-o", os.path.join(DOWNLOAD_DIR, "%(title)s.%(ext)s"), url],
    }
    
    if format_option not in commands:
        write_log("Error: Invalid format option.")
        return
    
    # Clear log file before starting new download
    open(LOG_FILE, "w").close()
    
    process = subprocess.Popen(commands[format_option], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
    
    for line in process.stdout:
        write_log(line.strip())  # Write logs in real-time
    
    process.wait()
    write_log("Download Complete!")

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/download', methods=['POST'])
def download():
    """Start a download in a background thread."""
    data = request.json
    url = data.get("url")
    format_option = data.get("format")
    
    if not url:
        return jsonify({"error": "No URL provided."}), 400
    
    threading.Thread(target=download_video, args=(url, format_option), daemon=True).start()
    return jsonify({"message": "Download started."})

@app.route('/logs', methods=['GET'])
def get_logs():
    """Stream the log file for live updates."""
    def generate():
        with open(LOG_FILE, "r") as log_file:
            while True:
                line = log_file.readline()
                if not line:
                    break
                yield f"data: {line.strip()}\\n\\n"
    
    return Response(generate(), mimetype="text/event-stream")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
