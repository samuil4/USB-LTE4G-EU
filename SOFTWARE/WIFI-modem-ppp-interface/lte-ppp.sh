#!/bin/sh

LOG="/var/log/lte-ppp.log"
SERVICE="/etc/systemd/system/lte-ppp.service"
PEER="/etc/ppp/peers/eg800k"
CHAT="/etc/chatscripts/eg800k"
DEV="/dev/ttyUSB1"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

install_files() {

    log "Installing LTE PPP system..."

    # Disable ModemManager permanently
    systemctl stop ModemManager 2>/dev/null
    systemctl disable ModemManager 2>/dev/null

    # Chat script
    if [ ! -f "$CHAT" ]; then
        mkdir -p /etc/chatscripts
        cat > "$CHAT" << 'EOF'
ABORT "BUSY"
ABORT "NO CARRIER"
ABORT "ERROR"
ABORT "NO DIALTONE"
TIMEOUT 15

"" AT
OK ATE0
OK AT+CGDCONT=1,"IP","internet.vivacom.bg"
OK ATD*99#
CONNECT ""
EOF
        log "Created chat script"
    fi

    # PPP peer config
    if [ ! -f "$PEER" ]; then
        mkdir -p /etc/ppp/peers
        cat > "$PEER" << 'EOF'
/dev/ttyUSB1 115200
connect "/usr/sbin/chat -v -f /etc/chatscripts/eg800k"
noauth
defaultroute
replacedefaultroute
usepeerdns
persist
holdoff 5
maxfail 0
lcp-echo-interval 20
lcp-echo-failure 6
noccp
noipv6
EOF
        log "Created PPP config"
    fi

    # systemd service generated dynamically
    cat > "$SERVICE" << 'EOF'
[Unit]
Description=LTE PPP Auto Connection
After=network.target

[Service]
ExecStart=/usr/local/sbin/lte-ppp.sh run
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable lte-ppp.service

    log "Installation complete"
}

start_ppp() {
    log "Starting PPP..."

    echo -1 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null

    pppd call eg800k >> "$LOG" 2>&1 &
}

monitor() {
    while true; do
        if ip link show ppp0 >/dev/null 2>&1; then
            sleep 10
        else
            log "PPP down → restarting"
            start_ppp
            sleep 10
        fi
    done
}

case "$1" in
    install)
        install_files
        ;;
    run)
        monitor
        ;;
    start)
        start_ppp
        ;;
    *)
        echo "Usage: $0 install | start | run"
        ;;
esac