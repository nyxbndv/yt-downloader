# Use an official lightweight Python image
FROM python:3.11

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y wget curl

# 🔹 Install yt-dlp in /app and make it globally accessible
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /app/yt-dlp \
    && chmod a+rx /app/yt-dlp \
    && ln -s /app/yt-dlp /usr/local/bin/yt-dlp \
    && ls -l /app/yt-dlp \
    && file /app/yt-dlp

# Verify yt-dlp installation
RUN /app/yt-dlp --version || (echo "ERROR: yt-dlp failed to install!" && exit 1)

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

# Set PATH so yt-dlp can be found in /app
ENV PATH="/app:$PATH"

# Switch to non-root user before installing dependencies
USER appuser

# Install Python dependencies without root access
RUN pip install --no-cache-dir --user -r requirements.txt

# Switch back to root for installing system dependencies
USER root

# Ensure `appuser` retains correct ownership after installations
RUN chown -R appuser:appuser /app

# Switch back to appuser before running the application
USER appuser

# Expose Flask's default port
EXPOSE 5000

# Add Unraid Web UI label
LABEL net.unraid.docker.webui="http://[IP]:5000"

# Run the Flask application
CMD ["python", "yt_dl_docker.py"]
