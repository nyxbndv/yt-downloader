# 🎬 YouTube Downloader - Docker Edition

A simple web-based **YouTube video & audio downloader** powered by `yt-dlp` and `Flask`, running inside a **Docker container**.

---

## 🚀 Features
✔ **Download YouTube videos** in high quality (`bestvideo+bestaudio`)  
✔ **Extract audio** as MP3 (`bestaudio`)  
✔ **Dockerized** for easy setup on **Unraid, Linux, Windows, or macOS**  
✔ **FFmpeg support** for video/audio merging  
✔ **Web UI** for easy usage  
✔ **Real-time logs** for download progress  

---

## 📦 Installation & Setup


### **1️⃣ Clone the Repository**

````sh
git clone https://github.com/irrelevant-bg/yt-downloader.git
cd YOUR_REPOSITORY
````


### 2️⃣ Build the Docker Image

````sh
docker build -t yt-downloader .
````

### 3️⃣ Run the Docker Container
```sh
docker run -d \
  --name yt-downloader \
  -p 5000:5000 \
  -v /mnt/user/YT-Downloads:/app/downloads \
  -e PUID=1000 -e PGID=100 -e UMASK=022 \
  yt-downloader
```
---

## 🖥️ Usage

### 1️⃣ Access the Web UI
- Open http://localhost:5000 (or replace localhost with your server's IP)
- Enter a YouTube URL and choose a format (Video + Audio or Audio Only)
- Click Download and watch the progress in the log section

## ⚙️ Environment Variables (Optional)
|Variable|Default|Description|
|----- | -----|-----|
|PUID|1000|Set user ID for file permissions|
|PGID|100|Set group ID for file permissions|
|UMASK|022|Set file permission mask|

---
## 🛠️ Troubleshooting

### 1️⃣ yt-dlp Not Found

If you see:
```
FileNotFoundError: [Errno 2] No such file or directory: '/app/yt-dlp'
```
Fix: Manually install yt-dlp inside the running container:
```
docker exec -it yt-downloader /bin/sh
wget -O /app/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x /app/yt-dlp
exit
```
Then restart the container.

### 2️⃣ FFmpeg Not Found

If merging video/audio fails:

```
You have requested merging of multiple formats but ffmpeg is not installed.
```

Fix: Make sure FFmpeg is installed in /app/ffmpeg:
```
docker exec -it yt-downloader /app/ffmpeg -version
```
