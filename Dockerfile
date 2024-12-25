FROM ubuntu:22.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# System configuration
ENV DISPLAY=:0
ENV XDG_RUNTIME_DIR=/tmp
ENV GDK_BACKEND=x11
ENV DBUS_SESSION_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl wget fuse libfuse2 \
    ca-certificates openssl \
    squashfs-tools \
    libgtk-3-0 libglib2.0-0 libnss3 \
    xvfb x11-apps \
    libdrm2 libgbm1 \
    libgl1-mesa-dri mesa-utils \
    libasound2 dbus dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# Configure system services
RUN mkdir -p /var/run/dbus && \
    dbus-uuidgen > /etc/machine-id && \
    ln -sf /etc/machine-id /var/lib/dbus/machine-id && \
    update-ca-certificates

# Download and setup Cursor
WORKDIR /app
RUN wget --no-check-certificate -O cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64" && \
    chmod +x cursor.AppImage && \
    ./cursor.AppImage --appimage-extract

# Runtime environment
ENV APPDIR="/app/squashfs-root"
ENV PATH="${APPDIR}:${APPDIR}/usr/sbin:${PATH}"
ENV LD_LIBRARY_PATH="${APPDIR}/usr/lib:/usr/lib/x86_64-linux-gnu"
ENV XDG_DATA_DIRS="${APPDIR}/usr/share/:/usr/local/share/:/usr/share/"

WORKDIR ${APPDIR}

# Start services and application
CMD ["sh", "-c", "service dbus start && Xvfb :0 -screen 0 1280x720x24 & sleep 1 && ./AppRun --no-sandbox"]