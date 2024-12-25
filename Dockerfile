FROM ubuntu:22.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# System configuration
ENV DISPLAY=:0
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV GDK_BACKEND=x11
ENV DBUS_SESSION_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
ENV HOME=/root

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
    x11vnc \
    libxcb1 libxcb-keysyms1 \
    libxcb-render0 libxcb-shm0 \
    && rm -rf /var/lib/apt/lists/*

# Configure system services and directories
RUN mkdir -p /var/run/dbus /run/user/1000 && \
    chmod 700 /run/user/1000 && \
    dbus-uuidgen > /etc/machine-id && \
    ln -sf /etc/machine-id /var/lib/dbus/machine-id && \
    update-ca-certificates

# Download and setup Cursor
WORKDIR /app
RUN wget --no-check-certificate -O cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64" && \
    chmod +x cursor.AppImage && \
    ./cursor.AppImage --appimage-extract && \
    chown -R root:root squashfs-root

# Runtime environment
ENV APPDIR="/app/squashfs-root"
ENV PATH="${APPDIR}:${APPDIR}/usr/sbin:${PATH}"
ENV LD_LIBRARY_PATH="${APPDIR}/usr/lib:${APPDIR}/usr/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu"
ENV XDG_DATA_DIRS="${APPDIR}/usr/share/:/usr/local/share/:/usr/share/"

WORKDIR ${APPDIR}

# Create startup script
RUN echo '#!/bin/bash\n\
service dbus start\n\
Xvfb :0 -screen 0 1920x1080x24 &\n\
sleep 2\n\
x11vnc -display :0 -forever -passwd cursor &\n\
./AppRun --no-sandbox' > /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]