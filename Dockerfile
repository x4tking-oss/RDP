FROM ubuntu:22.04 [cite: 1]

ENV DEBIAN_FRONTEND=noninteractive \
    VNC_PASSWORD=Change_Me_123! \
    RESOLUTION=1280x720

# Alapvető csomagok és a VNC szerver telepítése
RUN apt-get update && apt-get install -y --no-install-recommends \
        xfce4 \
        xfce4-terminal \
        xfce4-taskmanager \
        dbus-x11 \
        x11-utils \
        x11-xserver-utils \
        tightvncserver \
        novnc \
        python3-websockify \
        sudo \
        curl \
        wget \
        git \
        nano \
        htop \
        procps \
        net-tools \
        ca-certificates \
        locales \
        unzip \
        xz-utils \
        thunar \
        firefox [cite: 2, 3] \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Felhasználó létrehozása
RUN useradd -m -s /bin/bash user && \
    echo "user:user" | chpasswd && \
    adduser user sudo && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers [cite: 4]

# Munkakönyvtárak és jogosultságok
RUN mkdir -p /home/user/Desktop /home/user/Documents /home/user/Downloads /home/user/persist && \
    chown -R user:user /home/user

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
