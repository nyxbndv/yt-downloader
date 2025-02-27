# Use an official lightweight Python image
FROM python:3.11

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y wget curl

# Install yt-dlp into /app
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /app/yt-dlp \
    && chmod +x /app/yt-dlp \
    && /app/yt-dlp --version

# Install FFmpeg from a reliable source
RUN curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /app/ffmpeg.tar.xz \
    && tar -xvf /app/ffmpeg.tar.xz -C /app --strip-components=1 \
    && rm /app/ffmpeg.tar.xz \
    && chmod +x /app/ffmpeg

# Create a non-root user (appuser)
RUN useradd -m appuser

# Copy application files
COPY . /app

# Ensure logs.txt and downloads directory exist, then set ownership & permissions
#RUN touch /app/logs.txt \
#    && mkdir -p /app/downloads \
#    && chown -R appuser:appuser /app \
#    && chmod -R 755 /app

# Switch to non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 5000

RUN pip install --no-cache-dir --user -r requirements.txt

# Run the application
CMD ["python", "yt_dl_docker.py"]
