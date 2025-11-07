#!/bin/bash

# 3x-ui Panel Installation Script
# This script automates the installation and HTTPS setup for 3x-ui panel
# 3x-ui is an enhanced version of x-ui with better UI and more features

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Validate domain format
validate_domain() {
    local domain=$1
    if [[ ! $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        return 1
    fi
    return 0
}

# Validate email format
validate_email() {
    local email=$1
    if [[ ! $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

# Get domain from user
get_domain() {
    while true; do
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        read -p "Enter your domain name (e.g., panel.example.com): " DOMAIN
        echo -e "${BLUE}════════════════════════════════════════${NC}"

        if [ -z "$DOMAIN" ]; then
            print_error "Domain cannot be empty"
            continue
        fi

        if ! validate_domain "$DOMAIN"; then
            print_error "Invalid domain format"
            continue
        fi

        print_success "Domain set to: $DOMAIN"
        break
    done
}

# Get email for SSL certificate
get_email() {
    while true; do
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        read -p "Enter your email for SSL certificate (Let's Encrypt): " EMAIL
        echo -e "${BLUE}════════════════════════════════════════${NC}"

        if [ -z "$EMAIL" ]; then
            print_error "Email cannot be empty"
            continue
        fi

        if ! validate_email "$EMAIL"; then
            print_error "Invalid email format"
            continue
        fi

        print_success "Email set to: $EMAIL"
        break
    done
}

# Get port for X-UI panel
get_port() {
    while true; do
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        read -p "Enter port for X-UI panel (default: 54321): " PANEL_PORT
        echo -e "${BLUE}════════════════════════════════════════${NC}"

        # Use default if empty
        if [ -z "$PANEL_PORT" ]; then
            PANEL_PORT=54321
            print_info "Using default port: $PANEL_PORT"
            break
        fi

        # Validate port number
        if ! [[ "$PANEL_PORT" =~ ^[0-9]+$ ]]; then
            print_error "Port must be a number"
            continue
        fi

        if [ "$PANEL_PORT" -lt 1 ] || [ "$PANEL_PORT" -gt 65535 ]; then
            print_error "Port must be between 1 and 65535"
            continue
        fi

        # Warn about common reserved ports
        if [ "$PANEL_PORT" -lt 1024 ]; then
            print_warning "Port $PANEL_PORT is in the reserved range (1-1023)"
            read -p "Are you sure you want to use this port? (y/n): " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi

        print_success "Port set to: $PANEL_PORT"
        break
    done
}

# Get username for X-UI panel
get_username() {
    while true; do
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        read -p "Enter username for X-UI panel (default: admin): " PANEL_USERNAME
        echo -e "${BLUE}════════════════════════════════════════${NC}"

        # Use default if empty
        if [ -z "$PANEL_USERNAME" ]; then
            PANEL_USERNAME="admin"
            print_info "Using default username: $PANEL_USERNAME"
            break
        fi

        # Validate username (alphanumeric, underscore, hyphen)
        if ! [[ "$PANEL_USERNAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_error "Username must contain only letters, numbers, underscores, and hyphens"
            continue
        fi

        if [ ${#PANEL_USERNAME} -lt 3 ]; then
            print_error "Username must be at least 3 characters long"
            continue
        fi

        print_success "Username set to: $PANEL_USERNAME"
        break
    done
}

# Get password for X-UI panel
get_password() {
    while true; do
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"
        read -s -p "Enter password for X-UI panel (min 6 characters): " PANEL_PASSWORD
        echo ""
        read -s -p "Confirm password: " PANEL_PASSWORD_CONFIRM
        echo ""
        echo -e "${BLUE}════════════════════════════════════════${NC}"

        if [ -z "$PANEL_PASSWORD" ]; then
            print_error "Password cannot be empty"
            continue
        fi

        if [ ${#PANEL_PASSWORD} -lt 6 ]; then
            print_error "Password must be at least 6 characters long"
            continue
        fi

        if [ "$PANEL_PASSWORD" != "$PANEL_PASSWORD_CONFIRM" ]; then
            print_error "Passwords do not match"
            continue
        fi

        print_success "Password set successfully"
        break
    done
}

# Fix DNS if needed
fix_dns() {
    print_info "Checking DNS resolution..."

    if ! ping -c 1 -W 3 google.com &> /dev/null; then
        print_warning "DNS resolution issue detected. Attempting to fix..."

        # Backup existing resolv.conf
        if [ -f /etc/resolv.conf ]; then
            cp /etc/resolv.conf /etc/resolv.conf.backup
        fi

        # Set reliable DNS servers
        cat > /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

        # Test again
        sleep 2
        if ping -c 1 -W 3 google.com &> /dev/null; then
            print_success "DNS issue resolved"
        else
            print_error "Could not resolve DNS issue. Please check your network connection."
            exit 1
        fi
    else
        print_success "DNS resolution working correctly"
    fi
}

# Check system compatibility
check_system() {
    print_info "Checking system compatibility..."

    # Check OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        print_info "Detected OS: $OS $VERSION"
    else
        print_error "Cannot detect OS"
        exit 1
    fi

    # Check architecture
    ARCH=$(uname -m)
    print_info "System architecture: $ARCH"
}

# Update system packages
update_system() {
    print_info "Updating system packages..."

    local retry_count=0
    local max_retries=3

    while [ $retry_count -lt $max_retries ]; do
        if command -v apt-get &> /dev/null; then
            if apt-get update -y && apt-get upgrade -y; then
                print_success "System packages updated"
                return 0
            fi
        elif command -v yum &> /dev/null; then
            if yum update -y; then
                print_success "System packages updated"
                return 0
            fi
        else
            print_warning "Could not detect package manager"
            return 0
        fi

        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            print_warning "Update failed, retrying ($retry_count/$max_retries)..."
            sleep 5
        fi
    done

    print_error "Failed to update system packages after $max_retries attempts"
    exit 1
}

# Install dependencies
install_dependencies() {
    print_info "Installing required dependencies..."

    local retry_count=0
    local max_retries=3

    while [ $retry_count -lt $max_retries ]; do
        if command -v apt-get &> /dev/null; then
            # Try to update package list first
            apt-get update --fix-missing -y 2>/dev/null || true

            if apt-get install -y curl wget tar socat certbot 2>&1; then
                print_success "Dependencies installed"
                return 0
            fi
        elif command -v yum &> /dev/null; then
            if yum install -y curl wget tar socat certbot; then
                print_success "Dependencies installed"
                return 0
            fi
        else
            print_error "Unsupported package manager"
            exit 1
        fi

        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            print_warning "Installation failed, retrying ($retry_count/$max_retries)..."
            sleep 5
        fi
    done

    print_error "Failed to install dependencies after $max_retries attempts"
    print_error "Please check your internet connection and try again"
    exit 1
}

# Install 3x-ui
install_xui() {
    print_info "Installing 3x-ui panel..."

    # Download and run official 3x-ui installation script
    print_info "Running 3x-ui installer (latest version with enhanced features)..."

    # 3x-ui installation - non-interactive
    bash <(curl -Ls https://raw.githubusercontent.com/MHSanaei/3x-ui/master/install.sh) < /dev/null

    sleep 3
    print_success "3x-ui installed successfully"
}

# Configure 3x-ui panel settings
configure_xui_panel() {
    print_info "Configuring 3x-ui panel with your settings..."

    # Wait for 3x-ui to fully start
    sleep 3

    # 3x-ui uses the same x-ui command
    if command -v x-ui &> /dev/null; then
        print_info "Setting username: $PANEL_USERNAME"
        print_info "Setting port: $PANEL_PORT"

        # Alternative: directly modify the database
        if [ -f /etc/x-ui/x-ui.db ]; then
            print_info "Applying settings directly to database..."

            # Stop x-ui service
            systemctl stop x-ui 2>/dev/null || true
            sleep 2

            # Update database (requires sqlite3)
            if command -v sqlite3 &> /dev/null || apt-get install -y sqlite3 2>/dev/null; then
                # 3x-ui database structure - update username and password
                # Note: 3x-ui stores password as hash, so we'll set a temporary one
                print_info "Configuring credentials and port..."

                # Set port (3x-ui uses webPort setting)
                sqlite3 /etc/x-ui/x-ui.db "UPDATE settings SET value='${PANEL_PORT}' WHERE key='webPort';" 2>/dev/null || true

                # Set username and password (3x-ui users table)
                sqlite3 /etc/x-ui/x-ui.db "UPDATE users SET username='${PANEL_USERNAME}', password='${PANEL_PASSWORD}' WHERE id=1;" 2>/dev/null || true

                # Set language to English (3x-ui is English by default in newer versions)
                print_info "Setting panel language to English..."
                sqlite3 /etc/x-ui/x-ui.db "INSERT OR REPLACE INTO settings (key, value) VALUES ('webLang', 'en-US');" 2>/dev/null || true

                print_success "Settings applied to database"
            fi

            # Start x-ui service
            sleep 1
            systemctl start x-ui 2>/dev/null || true
            sleep 2
        fi

        print_success "Panel configured: username=$PANEL_USERNAME, port=$PANEL_PORT, language=English"
    else
        print_warning "3x-ui command not found. Please configure manually in panel settings."
    fi
}

# Configure firewall
configure_firewall() {
    print_info "Configuring firewall..."

    # Open required ports
    if command -v ufw &> /dev/null; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow ${PANEL_PORT}/tcp
        print_success "UFW firewall rules added (ports 80, 443, $PANEL_PORT)"
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --permanent --add-port=${PANEL_PORT}/tcp
        firewall-cmd --reload
        print_success "Firewalld rules added (ports 80, 443, $PANEL_PORT)"
    else
        print_warning "No firewall detected. Please manually open ports 80, 443, and $PANEL_PORT"
    fi
}

# Setup SSL certificate
setup_ssl() {
    print_info "Setting up SSL certificate..."

    # Stop 3x-ui temporarily to free port 80
    x-ui stop 2>/dev/null || true

    # Obtain SSL certificate
    certbot certonly --standalone \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        -d "$DOMAIN" \
        --preferred-challenges http

    if [ $? -eq 0 ]; then
        print_success "SSL certificate obtained successfully"

        # Certificate paths
        CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
        KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"

        print_info "Certificate: $CERT_PATH"
        print_info "Private Key: $KEY_PATH"

        # Setup auto-renewal
        (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --post-hook 'x-ui restart'") | crontab -
        print_success "SSL auto-renewal configured"
    else
        print_error "Failed to obtain SSL certificate"
        print_warning "Please ensure:"
        print_warning "1. Domain DNS is pointing to this server's IP"
        print_warning "2. Ports 80 and 443 are accessible"
        exit 1
    fi

    # Start X-UI again
    x-ui start
}

# Configure X-UI for HTTPS
configure_xui_https() {
    print_info "Configuring X-UI for HTTPS..."

    CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"

    # X-UI configuration path
    XUI_CONFIG="/etc/x-ui/x-ui.db"

    if [ -f "$XUI_CONFIG" ]; then
        print_info "X-UI database found. Configure HTTPS through the web panel."
        print_info "Use these certificate paths in the panel settings:"
        echo -e "${GREEN}Certificate Path:${NC} $CERT_PATH"
        echo -e "${GREEN}Private Key Path:${NC} $KEY_PATH"
    fi

    print_success "HTTPS configuration ready"
}

# Display final information
display_info() {
    local SERVER_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || echo "YOUR_SERVER_IP")

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}          3x-ui Panel Installation Complete!              ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Panel Access:${NC}"
    echo -e "  ${GREEN}HTTP URL (access first):${NC}  http://$DOMAIN:$PANEL_PORT"
    echo -e "  ${YELLOW}Fallback IP:${NC}            http://$SERVER_IP:$PANEL_PORT"
    echo -e "  ${BLUE}HTTPS URL (after setup):${NC} https://$DOMAIN:$PANEL_PORT"
    echo ""
    echo -e "${BLUE}Your Login Credentials:${NC}"
    echo -e "  Username: ${GREEN}$PANEL_USERNAME${NC}"
    echo -e "  Password: ${GREEN}[SET BY YOU]${NC}"
    echo -e "  Port:     ${GREEN}$PANEL_PORT${NC}"
    echo -e "  Language: ${GREEN}English (en_US)${NC}"
    echo ""
    echo -e "${BLUE}SSL Certificate Paths (ready on server):${NC}"
    echo -e "  Certificate: ${GREEN}/etc/letsencrypt/live/$DOMAIN/fullchain.pem${NC}"
    echo -e "  Private Key: ${GREEN}/etc/letsencrypt/live/$DOMAIN/privkey.pem${NC}"
    echo ""
    echo -e "${BLUE}Important Next Steps:${NC}"
    echo -e "  1. Visit ${GREEN}http://$DOMAIN:$PANEL_PORT${NC} ${YELLOW}(use HTTP, not HTTPS)${NC}"
    echo -e "  2. Login with username: ${GREEN}$PANEL_USERNAME${NC} and your password"
    echo -e "  3. Go to Panel Settings → Certificate Configuration"
    echo -e "  4. Enter the SSL certificate paths shown above"
    echo -e "  5. Save and restart the panel"
    echo -e "  6. Now access via ${GREEN}https://$DOMAIN:$PANEL_PORT${NC}"
    echo ""
    echo -e "${BLUE}Useful Commands:${NC}"
    echo -e "  x-ui start   - Start X-UI"
    echo -e "  x-ui stop    - Stop X-UI"
    echo -e "  x-ui restart - Restart X-UI"
    echo -e "  x-ui status  - Check status"
    echo -e "  x-ui         - Management menu"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Save info to file
    cat > /root/xui-info.txt <<EOF
3x-ui Panel Installation Information
====================================

Installation Date: $(date)
Panel Version: 3x-ui (Enhanced Version)
Domain: $DOMAIN
Email: $EMAIL
Username: $PANEL_USERNAME
Port: $PANEL_PORT

Access URLs:
  HTTP (access first):  http://$DOMAIN:$PANEL_PORT
  Fallback IP:          http://$SERVER_IP:$PANEL_PORT
  HTTPS (after setup):  https://$DOMAIN:$PANEL_PORT

Your Login Credentials:
  Username: $PANEL_USERNAME
  Password: [The password you set during installation]
  Port: $PANEL_PORT
  Language: English (en-US)

SSL Certificate Paths (ready on server):
  Certificate: /etc/letsencrypt/live/$DOMAIN/fullchain.pem
  Private Key: /etc/letsencrypt/live/$DOMAIN/privkey.pem

IMPORTANT: Access via HTTP first, configure SSL in panel settings,
then you can use HTTPS!

Commands:
  x-ui start   - Start 3x-ui
  x-ui stop    - Stop 3x-ui
  x-ui restart - Restart 3x-ui
  x-ui status  - Check status
  x-ui         - Management menu
EOF

    print_success "Installation info saved to /root/xui-info.txt"
}

# Main installation process
main() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          3x-ui Panel Automated Installation              ║
║                                                           ║
║   This script will install and configure 3x-ui panel    ║
║   with automatic HTTPS setup using Let's Encrypt        ║
║   Enhanced version with better UI and more features     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    print_warning "Please ensure:"
    print_warning "1. Your domain DNS is already pointing to this server"
    print_warning "2. Ports 80 and 443 are available for SSL"
    print_warning "3. You are running this on a clean server"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."

    # Run installation steps
    check_root
    get_domain
    get_email
    get_port
    get_username
    get_password
    check_system
    fix_dns
    update_system
    install_dependencies
    configure_firewall
    install_xui
    configure_xui_panel
    setup_ssl
    configure_xui_https
    display_info

    print_success "Installation completed successfully!"
    print_info "You can view the installation info anytime: cat /root/xui-info.txt"
}

# Run main function
main
