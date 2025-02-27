# Use an official lightweight Python image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y wget curl && rm -rf /var/lib/apt/lists/*

# Install yt-dlp into /app
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && yt-dlp --version

# Install FFmpeg from a reliable source
RUN curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz \
    && tar -xvf /tmp/ffmpeg.tar.xz -C /usr/local/bin --strip-components=1 --wildcards '*/ffmpeg' \
    && rm /tmp/ffmpeg.tar.xz \
    && chmod +x /usr/local/bin/ffmpeg \
    && ffmpeg -version

# Create a non-root user (appuser)
RUN useradd -m appuser

# Copy application files
COPY . /app

# Ensure logs.txt and downloads directory exist, then set ownership & permissions
RUN touch /app/logs.txt \
    && mkdir -p /app/downloads \
    && chown -R appuser:appuser /app \
    && chmod -R 755 /app

# Switch to non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 5000

# Run the application
CMD ["python", "yt_dl_docker.py"]
