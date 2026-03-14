#!/bin/bash
set -e

export HOME=/home/user
export DISPLAY=:1
export LANG=en_US.UTF-8
PORT=${PORT:-10000}

echo "Starting Remote Desktop..."

# VNC jelszó beállítása
mkdir -p /home/user/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/user/.vnc/passwd
chmod 600 /home/user/.vnc/passwd
chown -R user:user /home/user/.vnc

# XFCE indító fájl létrehozása
cat > /home/user/.vnc/xstartup << 'XSTARTUP'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_CURRENT_DESKTOP=XFCE
exec startxfce4
XSTARTUP
chmod +x /home/user/.vnc/xstartup
chown user:user /home/user/.vnc/xstartup

# Esetleges korábbi lock fájlok törlése
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# VNC szerver indítása a 'user' nevében
su - user -c "vncserver :1 -geometry ${RESOLUTION} -depth 24"

# noVNC index fájl beállítása
if [ ! -f /usr/share/novnc/index.html ]; then
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html
fi

echo "Szerver aktív a $PORT porton!"

# Websockify indítása (ez köti össze a VNC-t a böngészővel)
websockify --web=/usr/share/novnc/ ${PORT} localhost:5901
