#!/bin/bash

# X-UI Panel Uninstallation Script
# This script completely removes X-UI panel and cleans up all related configurations

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

# Get domain from installation info
get_domain_from_info() {
    if [ -f /root/xui-info.txt ]; then
        DOMAIN=$(grep "Domain:" /root/xui-info.txt | awk '{print $2}')
        PANEL_PORT=$(grep "Port:" /root/xui-info.txt | awk '{print $2}')
        print_info "Found installation info: Domain=$DOMAIN, Port=$PANEL_PORT"
    else
        print_warning "Installation info file not found at /root/xui-info.txt"
        read -p "Enter your domain name (or press Enter to skip SSL removal): " DOMAIN
        read -p "Enter your panel port (default: 54321): " PANEL_PORT
        PANEL_PORT=${PANEL_PORT:-54321}
    fi
}

# Stop X-UI service
stop_xui() {
    print_info "Stopping X-UI service..."

    if systemctl is-active --quiet x-ui; then
        systemctl stop x-ui 2>/dev/null || true
        print_success "X-UI service stopped"
    else
        print_info "X-UI service is not running"
    fi
}

# Uninstall X-UI
uninstall_xui() {
    print_info "Uninstalling X-UI panel..."

    # Try the official uninstall command first
    if command -v x-ui &> /dev/null; then
        x-ui uninstall 2>/dev/null || true
    fi

    # Manual cleanup
    systemctl disable x-ui 2>/dev/null || true
    systemctl stop x-ui 2>/dev/null || true

    rm -f /etc/systemd/system/x-ui.service
    rm -f /usr/local/x-ui/x-ui
    rm -rf /usr/local/x-ui
    rm -f /usr/bin/x-ui
    rm -rf /etc/x-ui

    systemctl daemon-reload

    print_success "X-UI panel uninstalled"
}

# Remove SSL certificates
remove_ssl() {
    if [ -z "$DOMAIN" ]; then
        print_warning "No domain specified, skipping SSL certificate removal"
        return
    fi

    print_info "Removing SSL certificates for $DOMAIN..."

    if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
        # Stop any renewal timers
        systemctl stop certbot.timer 2>/dev/null || true

        # Revoke and delete certificate
        certbot revoke --cert-path "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" --non-interactive 2>/dev/null || true
        certbot delete --cert-name "$DOMAIN" --non-interactive 2>/dev/null || true

        # Manual cleanup if certbot fails
        rm -rf "/etc/letsencrypt/live/$DOMAIN"
        rm -rf "/etc/letsencrypt/archive/$DOMAIN"
        rm -rf "/etc/letsencrypt/renewal/$DOMAIN.conf"

        print_success "SSL certificates removed"
    else
        print_info "No SSL certificates found for $DOMAIN"
    fi
}

# Remove cron jobs
remove_cron_jobs() {
    print_info "Removing cron jobs..."

    # Remove SSL renewal cron job
    crontab -l 2>/dev/null | grep -v "certbot renew" | grep -v "x-ui restart" | crontab - 2>/dev/null || true

    print_success "Cron jobs cleaned up"
}

# Remove firewall rules
remove_firewall_rules() {
    if [ -z "$PANEL_PORT" ]; then
        PANEL_PORT=54321
    fi

    print_info "Removing firewall rules..."

    if command -v ufw &> /dev/null; then
        ufw delete allow 80/tcp 2>/dev/null || true
        ufw delete allow 443/tcp 2>/dev/null || true
        ufw delete allow ${PANEL_PORT}/tcp 2>/dev/null || true
        print_success "UFW firewall rules removed"
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --remove-port=80/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=443/tcp 2>/dev/null || true
        firewall-cmd --permanent --remove-port=${PANEL_PORT}/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        print_success "Firewalld rules removed"
    else
        print_warning "No firewall detected, skipping firewall cleanup"
    fi
}

# Remove installation info
remove_info_file() {
    print_info "Removing installation info file..."

    if [ -f /root/xui-info.txt ]; then
        rm -f /root/xui-info.txt
        print_success "Installation info file removed"
    fi

    # Remove backup DNS config if exists
    if [ -f /etc/resolv.conf.backup ]; then
        print_info "Restoring original DNS configuration..."
        mv /etc/resolv.conf.backup /etc/resolv.conf 2>/dev/null || true
    fi
}

# Remove dependencies (optional)
remove_dependencies() {
    read -p "Do you want to remove installed dependencies (socat, certbot)? (y/n): " remove_deps

    if [[ "$remove_deps" =~ ^[Yy]$ ]]; then
        print_info "Removing dependencies..."

        if command -v apt-get &> /dev/null; then
            apt-get remove -y socat certbot python3-certbot 2>/dev/null || true
            apt-get autoremove -y 2>/dev/null || true
        elif command -v yum &> /dev/null; then
            yum remove -y socat certbot 2>/dev/null || true
        fi

        print_success "Dependencies removed"
    else
        print_info "Keeping installed dependencies"
    fi
}

# Display summary
display_summary() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}           X-UI Panel Uninstallation Complete!            ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Removed:${NC}"
    echo -e "  ✓ X-UI panel and service"
    echo -e "  ✓ SSL certificates (if domain was provided)"
    echo -e "  ✓ Firewall rules"
    echo -e "  ✓ Cron jobs"
    echo -e "  ✓ Configuration files"
    echo -e "  ✓ Installation info"
    echo ""
    echo -e "${BLUE}Your system has been cleaned up!${NC}"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Confirmation prompt
confirm_uninstall() {
    echo -e "${RED}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           X-UI Panel Uninstallation Script               ║
║                                                           ║
║   ⚠️  WARNING: This will completely remove X-UI panel   ║
║      and all related configurations!                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo ""
    print_warning "This script will remove:"
    print_warning "  • X-UI panel installation"
    print_warning "  • SSL certificates"
    print_warning "  • Firewall rules"
    print_warning "  • Cron jobs for SSL renewal"
    print_warning "  • All configuration files"
    echo ""

    read -p "Are you sure you want to continue? (yes/no): " confirm

    if [[ "$confirm" != "yes" ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
}

# Main uninstallation process
main() {
    clear
    check_root
    confirm_uninstall

    echo ""
    print_info "Starting uninstallation process..."
    echo ""

    get_domain_from_info
    stop_xui
    uninstall_xui
    remove_ssl
    remove_cron_jobs
    remove_firewall_rules
    remove_info_file
    remove_dependencies
    display_summary

    print_success "Uninstallation completed successfully!"
}

# Run main function
main
