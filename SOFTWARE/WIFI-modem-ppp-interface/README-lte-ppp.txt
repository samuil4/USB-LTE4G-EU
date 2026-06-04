LTE PPP AUTO-CONNECT SYSTEM (2-file version)
===========================================

OVERVIEW
--------
This system provides automatic LTE internet using:
Quectel EG800K modem via PPP over /dev/ttyUSB1.

It is designed for embedded Linux systems (A20, etc.).

WHAT IT DOES
------------
- Installs PPP configuration (if missing)
- Disables ModemManager (prevents conflicts)
- Creates systemd service automatically
- Starts PPP connection
- Automatically reconnects if dropped
- Sets LTE as default internet route
- Logs everything to /var/log/lte-ppp.log

WHAT IT DOES NOT DO
-------------------
- Does NOT modify Ethernet (LAN)
- Does NOT modify WiFi
- Does NOT remove existing routes except default via PPP

FILES USED
----------
/etc/chatscripts/eg800k   → modem dial script
/etc/ppp/peers/eg800k     → PPP configuration
/var/log/lte-ppp.log      → runtime logs

INSTALLATION
------------
1. Copy script:
   chmod +x lte-ppp.sh

2. Install system:
   ./lte-ppp.sh install

3. Start service:
   systemctl start lte-ppp.service

ENABLE ON BOOT
--------------
systemctl enable lte-ppp.service

STOP SERVICE
------------
systemctl stop lte-ppp.service

DISABLE SERVICE
---------------
systemctl disable lte-ppp.service

LOGS
----
tail -f /var/log/lte-ppp.log

CHECK STATUS
------------
ip addr show ppp0
ip route

NOTES
-----
ModemManager is disabled automatically because it interferes with PPP.