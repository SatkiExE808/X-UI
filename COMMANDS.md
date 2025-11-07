# X-UI Installation Commands Reference

Quick reference for all installation and management commands.

## Installation Commands

### One-Line Install (Always Latest)

**Using curl (recommended):**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

**Using wget:**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

**Latest development version:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/install-xui.sh)
```

### Download and Run

**Method 1: Using curl**
```bash
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh -o install-xui.sh
chmod +x install-xui.sh
./install-xui.sh
```

**Method 2: Using wget**
```bash
wget https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh
chmod +x install-xui.sh
./install-xui.sh
```

**Method 3: Clone repository**
```bash
git clone https://github.com/SatkiExE808/X-UI.git
cd X-UI
chmod +x install-xui.sh
./install-xui.sh
```

---

## Uninstallation Commands

### One-Line Uninstall (Always Latest)

**Using curl:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh)
```

**Using wget:**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh)
```

**Latest development version:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/uninstall-xui.sh)
```

### Download and Run

```bash
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh -o uninstall-xui.sh
chmod +x uninstall-xui.sh
./uninstall-xui.sh
```

---

## X-UI Management Commands

### Service Management
```bash
x-ui start          # Start X-UI service
x-ui stop           # Stop X-UI service
x-ui restart        # Restart X-UI service
x-ui status         # Check service status
x-ui               # Open management menu
```

### System Information
```bash
systemctl status x-ui         # Check systemd service status
journalctl -u x-ui -f        # View live logs
cat /root/xui-info.txt       # View installation info
```

---

## SSL Certificate Management

### View Certificate Info
```bash
certbot certificates
```

### Manual Certificate Renewal
```bash
certbot renew
x-ui restart
```

### Revoke Certificate
```bash
certbot revoke --cert-path /etc/letsencrypt/live/YOUR-DOMAIN/fullchain.pem
certbot delete --cert-name YOUR-DOMAIN
```

---

## Firewall Commands

### UFW (Ubuntu/Debian)
```bash
# Check status
ufw status

# Allow ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow YOUR_PORT/tcp

# Remove ports
ufw delete allow YOUR_PORT/tcp
```

### FirewallD (CentOS/RHEL)
```bash
# Check status
firewall-cmd --list-all

# Allow ports
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=YOUR_PORT/tcp
firewall-cmd --reload

# Remove ports
firewall-cmd --permanent --remove-port=YOUR_PORT/tcp
firewall-cmd --reload
```

---

## Update Scripts

### Update installation script
```bash
# Re-download latest version
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh -o install-xui.sh
chmod +x install-xui.sh
```

### Update uninstall script
```bash
# Re-download latest version
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh -o uninstall-xui.sh
chmod +x uninstall-xui.sh
```

### Update cloned repository
```bash
cd X-UI
git pull origin main
chmod +x *.sh
```

---

## Quick Troubleshooting

### Cannot access panel
```bash
# Check if service is running
systemctl status x-ui

# Check firewall
ufw status  # or: firewall-cmd --list-all

# Check logs
journalctl -u x-ui -n 50
```

### SSL errors
```bash
# Check certificate
certbot certificates

# Test renewal
certbot renew --dry-run

# Check DNS
dig YOUR-DOMAIN
```

### Port conflicts
```bash
# Check what's using a port
lsof -i :PORT_NUMBER
netstat -tulpn | grep PORT_NUMBER
```

---

## Branch URLs

### Stable (Main Branch)
```
https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh
https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh
```

### Development (Latest Features)
```
https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/install-xui.sh
https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/uninstall-xui.sh
```

---

## Notes

- All commands that fetch from GitHub will **always download the latest version**
- Use `main` branch for stable releases
- Use development branch for latest features and fixes
- `-sL` flag in curl: silent mode with location following
- `-qO-` flag in wget: quiet mode with output to stdout
