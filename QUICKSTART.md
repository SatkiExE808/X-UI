# 3x-ui Panel - Quick Start Guide

## What You Need

1. A Linux server (Ubuntu/Debian/CentOS)
2. Root access to the server
3. A domain name (e.g., `panel.yourdomain.com`)
4. Domain DNS pointing to your server IP
5. An email address for SSL certificates

## Installation Steps

### Step 1: Prepare Your Domain

Before running the script, make sure your domain's DNS A record points to your server's IP address:

```
Type: A
Name: panel (or your subdomain)
Value: YOUR_SERVER_IP
TTL: Auto or 3600
```

**Wait 5-10 minutes** for DNS propagation after making changes.

### Step 2: Run the Installation Script

SSH into your server and run one of these commands:

**Option 1: Using curl (recommended)**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

**Option 2: Using wget**
```bash
bash <(wget -qO- https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

**Option 3: Latest development version**
```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/claude/x-ui-panel-setup-011CUsYrmmfVeqB3WxdFdhFT/install-xui.sh)
```

**Option 4: Download first, then run**
```bash
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh -o install-xui.sh
chmod +x install-xui.sh
./install-xui.sh
```

### Step 3: Follow the Prompts

The script will ask you:

1. **Domain Name**: Enter your full domain (e.g., `panel.yourdomain.com`)
2. **Email Address**: Enter your email for SSL certificate notifications
3. **Port Number**: Choose your panel port (default: 54321, or enter custom port)
4. **Username**: Create your admin username (default: admin, min 3 chars)
5. **Password**: Create your secure password (min 6 chars, with confirmation)

Example interaction:
```
════════════════════════════════════════
Enter your domain name (e.g., panel.example.com): panel.yourdomain.com
════════════════════════════════════════
[SUCCESS] Domain set to: panel.yourdomain.com

════════════════════════════════════════
Enter your email for SSL certificate (Let's Encrypt): you@email.com
════════════════════════════════════════
[SUCCESS] Email set to: you@email.com

════════════════════════════════════════
Enter port for X-UI panel (default: 54321): 8443
════════════════════════════════════════
[SUCCESS] Port set to: 8443

════════════════════════════════════════
Enter username for X-UI panel (default: admin): myuser
════════════════════════════════════════
[SUCCESS] Username set to: myuser

════════════════════════════════════════
Enter password for X-UI panel (min 6 characters): ******
Confirm password: ******
════════════════════════════════════════
[SUCCESS] Password set successfully
```

### Step 4: Wait for Installation

The script will automatically:
- ✅ Install all required packages
- ✅ Install 3x-ui panel (enhanced version with better UI/UX and more features)
- ✅ Configure your username, password, and port
- ✅ Set panel language to English
- ✅ Configure firewall
- ✅ Obtain SSL certificate
- ✅ Setup HTTPS
- ✅ Configure auto-renewal

**This takes about 5-10 minutes.**

### Step 5: Access Your Panel

After installation, you'll see:

```
═══════════════════════════════════════════════════════════
          3x-ui Panel Installation Complete!
═══════════════════════════════════════════════════════════

Panel Access:
  HTTP URL (access first):  http://panel.yourdomain.com:YOUR_PORT
  HTTPS URL (after setup):  https://panel.yourdomain.com:YOUR_PORT

Your Login Credentials:
  Username: myuser
  Password: [SET BY YOU]
  Port:     8443
  Language: English (en-US)
```

### Step 6: First Login

**⚠️ IMPORTANT: Use HTTP first, not HTTPS!**

1. Open your browser and visit: `http://panel.yourdomain.com:8443` **(use HTTP, not HTTPS)**
2. Login with your username and password (already configured!)
3. The panel is already in English - no language change needed!

### Step 7: Configure SSL Certificate

**Configure SSL Certificate**:
   - Go to **Panel Settings** → **Certificate Configuration**
   - Enter the certificate paths shown during installation:
     - **Public Key File Path**: `/etc/letsencrypt/live/panel.yourdomain.com/fullchain.pem`
     - **Private Key File Path**: `/etc/letsencrypt/live/panel.yourdomain.com/privkey.pem`
   - Click **Save**
   - Restart the panel

3. **Now you can use HTTPS**: Visit `https://panel.yourdomain.com:8443`

## Common Issues

### "Failed to obtain SSL certificate"

**Cause**: DNS not pointing to server or ports blocked

**Fix**:
1. Check DNS: `dig panel.yourdomain.com` should show your server IP
2. Check ports: Make sure 80 and 443 are open
3. Wait longer for DNS propagation (up to 24 hours)

### "Cannot access panel"

**Cause**: Firewall blocking your chosen port

**Fix**:
```bash
# For UFW (replace YOUR_PORT with your actual port)
ufw allow YOUR_PORT/tcp

# For FirewallD (replace YOUR_PORT with your actual port)
firewall-cmd --permanent --add-port=YOUR_PORT/tcp
firewall-cmd --reload
```

### "ERR_SSL_PROTOCOL_ERROR" or "Connection not secure" warning

**Cause**: Trying to access HTTPS before SSL is configured in the panel

**Fix**:
1. Use HTTP instead: `http://panel.yourdomain.com:YOUR_PORT`
2. Login and configure SSL in Panel Settings (Step 7 above)
3. After SSL is configured, you can use HTTPS

## Useful Commands

```bash
x-ui              # Open management menu
x-ui start        # Start the panel
x-ui stop         # Stop the panel
x-ui restart      # Restart the panel
x-ui status       # Check panel status
```

## What's Next?

After installation:

1. ✅ Change admin password
2. ✅ Configure SSL in panel settings
3. ✅ Create your first inbound
4. ✅ Configure users
5. ✅ Set up monitoring

## Uninstallation

If you need to completely remove 3x-ui, use one of these commands:

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

**Download and run:**
```bash
curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/uninstall-xui.sh -o uninstall-xui.sh
chmod +x uninstall-xui.sh
./uninstall-xui.sh
```

This will remove:
- 3x-ui panel and all services
- SSL certificates
- Firewall rules
- Cron jobs
- Configuration files

## Need Help?

- Installation info saved at: `/root/xui-info.txt`
- View anytime: `cat /root/xui-info.txt`

---

**Note**: The panel uses port `54321` by default. You can change this in the panel settings after login.
