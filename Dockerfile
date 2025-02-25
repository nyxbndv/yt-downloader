# Use an official lightweight Python image
FROM python:3.11

# Set the working directory inside the container
WORKDIR /app

# Create a non-root user (appuser)
RUN useradd -m appuser

# Copy application files before setting ownership
COPY . /app

# Ensure logs.txt and downloads directory exist, then set ownership & permissions
RUN touch /app/logs.txt && \
    mkdir -p /app/downloads && \
    chown -R appuser:appuser /app && \
    chmod 664 /app/logs.txt && \
    chmod 775 /app/downloads

# Set PATH to include the local bin for Python user packages
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Switch to non-root user before installing dependencies
USER appuser

# Install Python dependencies without root access
RUN pip install --no-cache-dir --user -r requirements.txt
RUN pip install --user yt-dlp  

# Switch back to root for installing system dependencies
USER root

# 🔹 Manually Install `ffmpeg` in `/app`
RUN apt-get update && \
    apt-get install -y wget && \
    wget -O /app/ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-i686-static.tar.xz && \
    tar -xvf /app/ffmpeg.tar.xz -C /app --strip-components=1 && \
    rm /app/ffmpeg.tar.xz

# Ensure `ffmpeg` is executable
RUN chmod +x /app/ffmpeg

# Ensure `appuser` retains correct ownership after installations
RUN chown -R appuser:appuser /app

# Switch back to appuser before running the application
USER appuser

# Expose Flask's default port
EXPOSE 5000

# Run the Flask application
CMD ["python", "yt_dl_docker.py"]
