#!/bin/bash

# Snap Build and Test Helper Script for Hasi
# This script helps with building, installing, and testing the snap locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}===================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if snapcraft is installed
check_snapcraft() {
    if ! command -v snapcraft &> /dev/null; then
        print_error "snapcraft is not installed"
        echo "Install it with: sudo snap install snapcraft --classic"
        exit 1
    fi
    print_success "snapcraft is installed"
}

# Check if LXD is installed (for clean builds)
check_lxd() {
    if ! command -v lxd &> /dev/null; then
        print_warning "LXD is not installed (recommended for clean builds)"
        echo "Install it with: sudo snap install lxd && sudo lxd init --auto"
        return 1
    fi
    print_success "LXD is installed"
    return 0
}

# Build the snap
build_snap() {
    print_header "Building Snap Package"
    
    # Clean previous builds if requested
    if [ "$1" == "--clean" ]; then
        print_info "Cleaning previous build..."
        snapcraft clean
    fi
    
    # Build
    print_info "Starting build process (this may take several minutes)..."
    if snapcraft; then
        print_success "Snap built successfully"
        
        # Find the snap file
        SNAP_FILE=$(ls -t *.snap 2>/dev/null | head -1)
        if [ -n "$SNAP_FILE" ]; then
            print_success "Snap file: $SNAP_FILE"
            echo "$SNAP_FILE"
        fi
    else
        print_error "Build failed"
        exit 1
    fi
}

# Install the snap locally
install_snap() {
    SNAP_FILE=$(ls -t *.snap 2>/dev/null | head -1)
    
    if [ -z "$SNAP_FILE" ]; then
        print_error "No snap file found. Build first with: $0 build"
        exit 1
    fi
    
    print_header "Installing Snap Locally"
    print_info "Installing $SNAP_FILE..."
    
    # Remove old version if installed
    if snap list | grep -q "^hasi "; then
        print_info "Removing previous installation..."
        sudo snap remove hasi
    fi
    
    # Install with dangerous flag (local snap)
    if sudo snap install "$SNAP_FILE" --dangerous; then
        print_success "Snap installed successfully"
        print_info "Run with: hasi"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Install in devmode for debugging
install_devmode() {
    SNAP_FILE=$(ls -t *.snap 2>/dev/null | head -1)
    
    if [ -z "$SNAP_FILE" ]; then
        print_error "No snap file found. Build first with: $0 build"
        exit 1
    fi
    
    print_header "Installing Snap in DevMode"
    print_warning "DevMode disables security confinement - use only for debugging"
    
    # Remove old version if installed
    if snap list | grep -q "^hasi "; then
        print_info "Removing previous installation..."
        sudo snap remove hasi
    fi
    
    # Install in devmode
    if sudo snap install "$SNAP_FILE" --dangerous --devmode; then
        print_success "Snap installed in devmode"
        print_info "Run with: hasi"
    else
        print_error "Installation failed"
        exit 1
    fi
}

# Show snap info
show_info() {
    print_header "Snap Information"
    
    if snap list | grep -q "^hasi "; then
        snap info hasi --verbose
        echo ""
        print_header "Connections"
        snap connections hasi
    else
        print_warning "Hasi snap is not installed"
    fi
}

# Show logs
show_logs() {
    print_header "Snap Logs"
    
    if snap list | grep -q "^hasi "; then
        snap logs hasi -f
    else
        print_error "Hasi snap is not installed"
        exit 1
    fi
}

# Run the app
run_app() {
    print_header "Running Hasi"
    
    if snap list | grep -q "^hasi "; then
        hasi
    else
        print_error "Hasi snap is not installed"
        print_info "Install first with: $0 install"
        exit 1
    fi
}

# Uninstall the snap
uninstall_snap() {
    print_header "Uninstalling Snap"
    
    if snap list | grep -q "^hasi "; then
        if sudo snap remove hasi; then
            print_success "Snap uninstalled successfully"
        else
            print_error "Uninstallation failed"
            exit 1
        fi
    else
        print_warning "Hasi snap is not installed"
    fi
}

# Clean build artifacts
clean_build() {
    print_header "Cleaning Build Artifacts"
    
    print_info "Removing snap files..."
    rm -f *.snap
    
    print_info "Cleaning snapcraft cache..."
    snapcraft clean
    
    print_success "Clean complete"
}

# Show help
show_help() {
    cat << EOF
Hasi Snap Build and Test Helper

Usage: $0 [command] [options]

Commands:
    build [--clean]     Build the snap package
                        --clean: Clean before building
    
    install             Install the snap locally (strict confinement)
    
    install-dev         Install the snap in devmode (for debugging)
    
    info                Show snap information and connections
    
    logs                Show snap logs (follow mode)
    
    run                 Run the installed snap
    
    uninstall           Remove the installed snap
    
    clean               Clean build artifacts
    
    check               Check if required tools are installed
    
    help                Show this help message

Examples:
    $0 build            # Build the snap
    $0 build --clean    # Clean build
    $0 install          # Install locally
    $0 info             # Show snap info
    $0 logs             # View logs

EOF
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    check_snapcraft
    check_lxd
    print_success "All checks complete"
}

# Main script logic
case "$1" in
    build)
        check_snapcraft
        build_snap "$2"
        ;;
    install)
        install_snap
        ;;
    install-dev)
        install_devmode
        ;;
    info)
        show_info
        ;;
    logs)
        show_logs
        ;;
    run)
        run_app
        ;;
    uninstall)
        uninstall_snap
        ;;
    clean)
        clean_build
        ;;
    check)
        check_prerequisites
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
