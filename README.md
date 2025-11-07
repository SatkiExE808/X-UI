# X-UI Panel Automated Installer

A comprehensive, automated installation script for X-UI panel with built-in HTTPS setup using Let's Encrypt SSL certificates.

## Features

✅ **Interactive Installation** - Prompts for domain and email during setup
✅ **Automatic HTTPS** - Configures Let's Encrypt SSL certificates automatically
✅ **Firewall Configuration** - Sets up firewall rules automatically
✅ **SSL Auto-Renewal** - Configures automatic certificate renewal
✅ **Security Focused** - Includes security best practices and warnings
✅ **User-Friendly** - Color-coded output and clear instructions

## Prerequisites

Before running the installation script, ensure:

1. ✅ **Clean Linux Server** (Ubuntu 18.04+, Debian 10+, CentOS 7+)
2. ✅ **Root Access** to the server
3. ✅ **Domain Name** pointing to your server's IP address
4. ✅ **Ports Open**: 80, 443, and 54321
5. ✅ **Valid Email** for Let's Encrypt notifications

## Quick Start

### One-Line Installation (Always Latest)

**Install from main branch (stable):**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

**Or using wget:**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

**Install from development branch (latest features):**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/install-xui.sh)
```

### Manual Installation

**Method 1: Direct download (always gets latest)**
```bash
# Download latest version
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh -o install-xui.sh

# Make executable
chmod +x install-xui.sh

# Run installer
./install-xui.sh
```

**Method 2: Clone repository**
```bash
# Clone the repository (gets all files)
git clone https://github.com/SatkiExE808/X-UI.git
cd X-UI

# Make scripts executable
chmod +x install-xui.sh uninstall-xui.sh

# Run installer
./install-xui.sh
```

**Method 3: Using wget**
```bash
# Download latest version
wget https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh

# Make executable
chmod +x install-xui.sh

# Run installer
./install-xui.sh
```

## Installation Process

The script will guide you through:

1. **Domain Input** - Enter your fully qualified domain name (e.g., `panel.example.com`)
2. **Email Input** - Provide an email for SSL certificate notifications
3. **Port Selection** - Choose your panel port (default: 54321, or specify custom port)
4. **Automatic Setup** - Sit back while the script:
   - Updates system packages
   - Installs dependencies
   - Installs X-UI panel
   - Configures firewall rules for your chosen port
   - Obtains SSL certificate
   - Sets up HTTPS
   - Configures auto-renewal

## After Installation

### Accessing Your Panel

Once installation completes, you'll see:

```
═══════════════════════════════════════════════════════════
           X-UI Panel Installation Complete!
═══════════════════════════════════════════════════════════

Panel Access:
  HTTP URL (access first):  http://your-domain.com:YOUR_PORT
  HTTPS URL (after setup):  https://your-domain.com:YOUR_PORT

Default Credentials:
  Username: admin
  Password: admin
  ⚠ CHANGE THESE IMMEDIATELY AFTER LOGIN!
```

### Important First Steps

**⚠️ IMPORTANT: Use HTTP first, not HTTPS! SSL is not configured in the panel yet.**

1. **Access the panel** at `http://your-domain.com:YOUR_PORT` (use HTTP, not HTTPS)
2. **Login** with default credentials (admin/admin)
3. **Change default credentials immediately!**
4. **Change the port** (if you selected a custom port) in Panel Settings
5. **Configure SSL in panel settings:**
   - Go to: Panel Settings → Certificate Configuration
   - Certificate Path: `/etc/letsencrypt/live/your-domain.com/fullchain.pem`
   - Private Key Path: `/etc/letsencrypt/live/your-domain.com/privkey.pem`
   - Save and restart the panel
6. **Now access via HTTPS:** `https://your-domain.com:YOUR_PORT`

## X-UI Management Commands

```bash
x-ui start    # Start X-UI service
x-ui stop     # Stop X-UI service
x-ui restart  # Restart X-UI service
x-ui status   # Check service status
x-ui         # Open management menu
```

## SSL Certificate Information

### Certificate Locations
- **Certificate**: `/etc/letsencrypt/live/your-domain.com/fullchain.pem`
- **Private Key**: `/etc/letsencrypt/live/your-domain.com/privkey.pem`

### Auto-Renewal
The script automatically configures SSL certificate renewal via cron:
```bash
# Runs daily at 3 AM
0 3 * * * certbot renew --quiet --post-hook 'x-ui restart'
```

### Manual Certificate Renewal
```bash
certbot renew
x-ui restart
```

## Troubleshooting

### SSL Certificate Issues

**Problem**: Certificate generation fails
**Solution**:
```bash
# Verify DNS is pointing to server
dig your-domain.com

# Check if ports are accessible
netstat -tulpn | grep -E ':(80|443|54321)'

# Try manual certificate generation
certbot certonly --standalone -d your-domain.com
```

### Panel Access Issues

**Problem**: Cannot access panel
**Solution**:
```bash
# Check X-UI status
x-ui status

# Check firewall rules
ufw status        # For UFW
firewall-cmd --list-all  # For FirewallD

# Restart X-UI
x-ui restart
```

### Port Already in Use

**Problem**: Port 80 or 443 is already in use
**Solution**:
```bash
# Find what's using the port
lsof -i :80
lsof -i :443

# Stop conflicting service (e.g., Apache/Nginx)
systemctl stop apache2
systemctl stop nginx
```

## Security Best Practices

1. ✅ **Change default credentials** immediately after installation
2. ✅ **Use strong passwords** for admin account
3. ✅ **Keep system updated**: `apt update && apt upgrade`
4. ✅ **Enable firewall** and only allow necessary ports
5. ✅ **Monitor access logs** regularly
6. ✅ **Backup configuration** periodically

## Uninstallation

### Complete Uninstallation (Recommended)

Use the comprehensive uninstall script to remove everything.

**One-line uninstall (always latest):**

Using curl:
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/uninstall-xui.sh)
```

Using wget:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh)
```

**Development branch (latest features):**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/uninstall-xui.sh)
```

**Or download and run:**

```bash
# Download latest uninstall script
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh -o uninstall-xui.sh

# Make executable
chmod +x uninstall-xui.sh

# Run uninstaller
./uninstall-xui.sh
```

**If you have the repository cloned:**

```bash
cd X-UI
./uninstall-xui.sh
```

This script will remove:
- ✓ X-UI panel and service
- ✓ SSL certificates
- ✓ Firewall rules
- ✓ Cron jobs for SSL renewal
- ✓ All configuration files
- ✓ Installation info

### Manual Uninstallation

If you prefer to uninstall manually:

```bash
# Stop and remove X-UI
x-ui uninstall

# Remove SSL certificates
certbot revoke --cert-path /etc/letsencrypt/live/your-domain.com/fullchain.pem
certbot delete --cert-name your-domain.com

# Remove firewall rules (replace YOUR_PORT with your actual port)
ufw delete allow 80/tcp
ufw delete allow 443/tcp
ufw delete allow YOUR_PORT/tcp

# Remove cron jobs
crontab -e  # manually remove certbot renewal entries

# Remove installation info
rm -f /root/xui-info.txt
```

## Support & Resources

- **X-UI GitHub**: https://github.com/vaxilu/x-ui
- **Installation Info**: Saved at `/root/xui-info.txt` after installation
- **Certbot Documentation**: https://certbot.eff.org/

## License

This installation script is provided as-is for educational and authorized use only.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**⚠️ Important Security Notice**: This panel should only be used on authorized servers. Always follow your local laws and regulations. Change default credentials immediately after installation.
