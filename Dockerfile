# Use an official lightweight Python image
FROM python:3.11

# Set the working directory inside the container
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y yt-dlp ffmpeg && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Set up user permissions
ARG PUID=1000
ARG PGID=100
RUN groupadd -g $PGID appgroup && useradd -u $PUID -g $PGID -m appuser

# Ensure the download directory exists with correct permissions
RUN mkdir -p /app/downloads && chown -R appuser:appgroup /app/downloads

# Switch to non-root user
USER appuser

EXPOSE 5000

CMD ["python", "yt_dl_docker.py"]


# Add Unraid Web UI label
LABEL net.unraid.docker.webui="http://[IP]:5000"

# Run the Flask application
CMD ["python", "yt_dl_docker.py"]
