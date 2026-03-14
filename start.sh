#!/bin/bash
set -e

export HOME=/home/user
export DISPLAY=:1
export LANG=en_US.UTF-8
PORT=${PORT:-10000}

echo "╔══════════════════════════════════════════╗"
echo "║     Render Remote Desktop - Inditas      ║"
echo "╚══════════════════════════════════════════╝"

mkdir -p /home/user/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/user/.vnc/passwd
chmod 600 /home/user/.vnc/passwd

cat > /home/user/.vnc/xstartup << 'XSTARTUP'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_CURRENT_DESKTOP=XFCE
exec startxfce4
XSTARTUP
chmod +x /home/user/.vnc/xstartup

chown -R user:user /home/user/.vnc
chown -R user:user /home/user/Desktop
chown -R user:user /home/user/Documents
chown -R user:user /home/user/Downloads
chown -R user:user /home/user/persist

su - user -c "vncserver -kill :1" 2>/dev/null || true
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

su - user -c "vncserver :1 \
    -geometry ${RESOLUTION} \
    -depth 24 \
    -localhost yes \
    -SecurityTypes VncAuth"

echo "[OK] VNC szerver elindult (display :1)"

if [ ! -f /usr/share/novnc/index.html ]; then
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html 2>/dev/null || true
fi

(
    while true; do
        sleep 600
        echo "[$(date)] Szerver aktiv"
    done
) &

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Desktop KESZ!                           ║"
echo "║                                          ║"
echo "║  VNC Jelszo: $VNC_PASSWORD"
echo "║  Felbontas:  $RESOLUTION"
echo "║  Port:       $PORT"
echo "║                                          ║"
echo "║  Bongeszobe nyisd meg a Render URL-t!    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

websockify --web=/usr/share/novnc/ ${PORT} localhost:5901
