# Use an official lightweight Python image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y wget curl

# Install yt-dlp into /usr/local/bin
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && yt-dlp --version

# Install FFmpeg from a reliable source (GitHub static builds)
RUN curl -L https://github.com/eugeneware/ffmpeg-static/releases/latest/download/linux-x64 -o /usr/local/bin/ffmpeg \
    && chmod +x /usr/local/bin/ffmpeg \
    && /usr/local/bin/ffmpeg -version

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
