#!/bin/bash

# Snapcraft YAML Validator
# Checks for common issues in snapcraft.yaml before building

set -e

YAML_FILE="snap/snapcraft.yaml"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    ((WARNINGS++))
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

echo -e "${BLUE}===================================${NC}"
echo -e "${BLUE}Snapcraft YAML Validator${NC}"
echo -e "${BLUE}===================================${NC}"
echo ""

# Check if file exists
if [ ! -f "$YAML_FILE" ]; then
    print_error "snapcraft.yaml not found at $YAML_FILE"
    exit 1
fi

print_success "Found snapcraft.yaml"

# Check if snapcraft is installed
if ! command -v snapcraft &> /dev/null; then
    print_warning "snapcraft is not installed. Install with: sudo snap install snapcraft --classic"
else
    print_success "snapcraft is installed"
fi

# Validate YAML syntax
print_info "Validating YAML syntax..."
if command -v yamllint &> /dev/null; then
    if yamllint -d relaxed "$YAML_FILE" 2>/dev/null; then
        print_success "YAML syntax is valid"
    else
        print_warning "YAML syntax issues detected (non-critical)"
    fi
else
    print_info "yamllint not installed, skipping syntax check"
fi

# Check required fields
print_info "Checking required fields..."

if grep -q "^name:" "$YAML_FILE"; then
    NAME=$(grep "^name:" "$YAML_FILE" | awk '{print $2}')
    print_success "name: $NAME"
else
    print_error "Missing required field: name"
fi

if grep -q "^version:" "$YAML_FILE"; then
    VERSION=$(grep "^version:" "$YAML_FILE" | awk '{print $2}' | tr -d "'\"")
    print_success "version: $VERSION"
else
    print_error "Missing required field: version"
fi

if grep -q "^summary:" "$YAML_FILE"; then
    print_success "summary field present"
else
    print_error "Missing required field: summary"
fi

if grep -q "^description:" "$YAML_FILE"; then
    print_success "description field present"
else
    print_error "Missing required field: description"
fi

if grep -q "^base:" "$YAML_FILE"; then
    BASE=$(grep "^base:" "$YAML_FILE" | awk '{print $2}')
    print_success "base: $BASE"
else
    print_error "Missing required field: base"
fi

if grep -q "^confinement:" "$YAML_FILE"; then
    CONFINEMENT=$(grep "^confinement:" "$YAML_FILE" | awk '{print $2}')
    print_success "confinement: $CONFINEMENT"
else
    print_error "Missing required field: confinement"
fi

if grep -q "^grade:" "$YAML_FILE"; then
    GRADE=$(grep "^grade:" "$YAML_FILE" | awk '{print $2}')
    print_success "grade: $GRADE"
else
    print_warning "Missing optional field: grade (defaults to 'stable')"
fi

# Check version matches pubspec.yaml
print_info "Checking version consistency..."
if [ -f "pubspec.yaml" ]; then
    PUBSPEC_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
    SNAP_VERSION=$(grep "^version:" "$YAML_FILE" | awk '{print $2}' | tr -d "'\"")
    
    if [ "$PUBSPEC_VERSION" = "$SNAP_VERSION" ]; then
        print_success "Version matches pubspec.yaml: $PUBSPEC_VERSION"
    else
        print_warning "Version mismatch: snapcraft.yaml ($SNAP_VERSION) vs pubspec.yaml ($PUBSPEC_VERSION)"
    fi
else
    print_warning "pubspec.yaml not found, skipping version check"
fi

# Check apps section
print_info "Checking apps section..."
if grep -q "^apps:" "$YAML_FILE"; then
    print_success "apps section present"
    
    # Check for command
    if grep -q "command:" "$YAML_FILE"; then
        print_success "app command defined"
    else
        print_error "No command defined in apps section"
    fi
else
    print_error "Missing apps section"
fi

# Check parts section
print_info "Checking parts section..."
if grep -q "^parts:" "$YAML_FILE"; then
    print_success "parts section present"
    
    # Check for Flutter plugin
    if grep -q "plugin: flutter" "$YAML_FILE"; then
        print_success "Using Flutter plugin"
    else
        print_warning "Not using Flutter plugin"
    fi
else
    print_error "Missing parts section"
fi

# Check for desktop file
print_info "Checking desktop integration..."
if [ -f "snap/gui/hasi.desktop" ]; then
    print_success "Desktop file found"
    
    # Validate desktop file
    if grep -q "^Name=" "snap/gui/hasi.desktop"; then
        print_success "Desktop file has Name field"
    else
        print_warning "Desktop file missing Name field"
    fi
    
    if grep -q "^Exec=" "snap/gui/hasi.desktop"; then
        print_success "Desktop file has Exec field"
    else
        print_warning "Desktop file missing Exec field"
    fi
else
    print_warning "Desktop file not found at snap/gui/hasi.desktop"
fi

# Check for icon
if [ -f "snap/gui/hasi.png" ]; then
    print_success "Icon file found"
    
    # Check icon size
    if command -v identify &> /dev/null; then
        ICON_SIZE=$(identify -format "%wx%h" snap/gui/hasi.png 2>/dev/null)
        print_info "Icon size: $ICON_SIZE"
    fi
else
    print_warning "Icon file not found at snap/gui/hasi.png"
fi

# Check for common plugs
print_info "Checking common plugs..."
COMMON_PLUGS=("network" "home" "desktop" "wayland" "x11" "opengl")
for plug in "${COMMON_PLUGS[@]}"; do
    if grep -q "$plug" "$YAML_FILE"; then
        print_success "Plug declared: $plug"
    fi
done

# Check for Flutter-specific requirements
print_info "Checking Flutter requirements..."
if grep -q "libgtk-3-dev" "$YAML_FILE"; then
    print_success "GTK3 development libraries included"
else
    print_warning "GTK3 development libraries not found in build-packages"
fi

# Lint with snapcraft (if available)
if command -v snapcraft &> /dev/null; then
    print_info "Running snapcraft lint..."
    if snapcraft lint 2>/dev/null; then
        print_success "Snapcraft lint passed"
    else
        print_warning "Snapcraft lint found issues (may not be critical)"
    fi
fi

# Summary
echo ""
echo -e "${BLUE}===================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}===================================${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo -e "${YELLOW}You can proceed with building, but review the warnings${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo -e "${RED}Fix errors before building${NC}"
    exit 1
fi
