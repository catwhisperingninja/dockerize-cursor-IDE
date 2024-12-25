FROM ubuntu:22.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies including SSL certificates
RUN apt-get update && apt-get install -y \
    wget \
    libfuse2 \
    ca-certificates \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

# Download Cursor AppImage
WORKDIR /app
RUN curl -L "https://www.cursor.com/api/dashboard/get-download-link" -o cursor.AppImage
RUN chmod +x cursor.AppImage

CMD ["./cursor.AppImage", "--version"]s