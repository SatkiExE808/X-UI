# X-UI Panel - Quick Start Guide

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

SSH into your server and run:

```bash
bash <(curl -sL https://raw.githubusercontent.com/SatkiExE808/X-UI/main/install-xui.sh)
```

### Step 3: Follow the Prompts

The script will ask you:

1. **Domain Name**: Enter your full domain (e.g., `panel.yourdomain.com`)
2. **Email Address**: Enter your email for SSL certificate notifications

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
```

### Step 4: Wait for Installation

The script will automatically:
- ✅ Install all required packages
- ✅ Install X-UI panel
- ✅ Configure firewall
- ✅ Obtain SSL certificate
- ✅ Setup HTTPS
- ✅ Configure auto-renewal

**This takes about 5-10 minutes.**

### Step 5: Access Your Panel

After installation, you'll see:

```
═══════════════════════════════════════════════════════════
           X-UI Panel Installation Complete!
═══════════════════════════════════════════════════════════

Panel Access:
  HTTPS URL: https://panel.yourdomain.com:54321

Default Credentials:
  Username: admin
  Password: admin
```

### Step 6: First Login

1. Open your browser and visit: `https://panel.yourdomain.com:54321`
2. Login with:
   - Username: `admin`
   - Password: `admin`
3. **IMMEDIATELY CHANGE YOUR PASSWORD!**

### Step 7: Enable HTTPS in Panel

1. Go to **Panel Settings** → **Certificate Configuration**
2. Enter the certificate paths:
   - **Public Key File Path**: `/etc/letsencrypt/live/panel.yourdomain.com/fullchain.pem`
   - **Private Key File Path**: `/etc/letsencrypt/live/panel.yourdomain.com/privkey.pem`
3. Click **Save**
4. Restart the panel

## Common Issues

### "Failed to obtain SSL certificate"

**Cause**: DNS not pointing to server or ports blocked

**Fix**:
1. Check DNS: `dig panel.yourdomain.com` should show your server IP
2. Check ports: Make sure 80 and 443 are open
3. Wait longer for DNS propagation (up to 24 hours)

### "Cannot access panel"

**Cause**: Firewall blocking port 54321

**Fix**:
```bash
# For UFW
ufw allow 54321/tcp

# For FirewallD
firewall-cmd --permanent --add-port=54321/tcp
firewall-cmd --reload
```

### "Connection not secure" warning

**Cause**: SSL not configured in panel yet

**Fix**: Follow Step 7 above to configure SSL in the panel settings

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

## Need Help?

- Installation info saved at: `/root/xui-info.txt`
- View anytime: `cat /root/xui-info.txt`

---

**Note**: The panel uses port `54321` by default. You can change this in the panel settings after login.
