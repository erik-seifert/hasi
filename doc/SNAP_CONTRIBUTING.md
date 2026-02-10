# Contributing to Hasi Snap Package

Thank you for your interest in contributing to the Hasi snap package! This guide will help you get started with snap development and testing.

## Prerequisites

### Required Tools

1. **Snapcraft** - The snap building tool
   ```bash
   sudo snap install snapcraft --classic
   ```

2. **LXD** - For clean, isolated builds (recommended)
   ```bash
   sudo snap install lxd
   sudo lxd init --auto
   sudo usermod -a -G lxd $USER
   newgrp lxd
   ```

3. **Flutter** - For development
   ```bash
   # Follow official Flutter installation guide
   # https://docs.flutter.dev/get-started/install/linux
   ```

### Optional Tools

- **yamllint** - For YAML validation
  ```bash
  sudo apt install yamllint
  ```

- **imagemagick** - For icon validation
  ```bash
  sudo apt install imagemagick
  ```

## Development Workflow

### 1. Make Changes

Edit the relevant files:
- `snap/snapcraft.yaml` - Main snap configuration
- `snap/gui/hasi.desktop` - Desktop entry
- `snap/gui/hasi.png` - Application icon

### 2. Validate Configuration

Run the validation script:
```bash
./snap/validate-snap.sh
```

This checks for:
- Required fields in snapcraft.yaml
- Version consistency with pubspec.yaml
- Desktop file validity
- Icon presence
- Common configuration issues

### 3. Build the Snap

#### Quick Build (Development)
```bash
./snap/build-snap.sh build
```

#### Clean Build
```bash
./snap/build-snap.sh build --clean
```

#### Manual Build
```bash
snapcraft
```

#### Build with LXD (Recommended for Production)
```bash
snapcraft --use-lxd
```

### 4. Test Locally

#### Install and Test
```bash
./snap/build-snap.sh install
./snap/build-snap.sh run
```

#### Test in DevMode (for debugging)
```bash
./snap/build-snap.sh install-dev
```

#### Manual Testing
```bash
# Install
sudo snap install hasi_*.snap --dangerous

# Run
hasi

# Check logs
snap logs hasi -f

# Check connections
snap connections hasi
```

### 5. Test Permissions

Verify all required permissions work:

```bash
# Network connectivity
# - Try connecting to Home Assistant
# - Test auto-discovery

# Audio (if using voice features)
# - Test speech-to-text
# - Test text-to-speech

# Camera (if viewing camera entities)
# - Test camera feed display

# Storage
# - Verify settings are saved
# - Check dashboard persistence
```

### 6. Clean Up

```bash
./snap/build-snap.sh clean
```

## Common Tasks

### Updating Version

1. Update `pubspec.yaml`:
   ```yaml
   version: 1.1.0+2
   ```

2. Update `snap/snapcraft.yaml`:
   ```yaml
   version: '1.1.0'
   ```

3. Validate and rebuild:
   ```bash
   ./snap/validate-snap.sh
   ./snap/build-snap.sh build --clean
   ```

### Adding New Permissions

1. Edit `snap/snapcraft.yaml`
2. Add the plug under `apps.hasi.plugs`:
   ```yaml
   apps:
     hasi:
       plugs:
         - new-permission
   ```

3. Document the permission in `doc/SNAP_SETUP.md`
4. Test the permission works

### Updating Dependencies

1. Update `build-packages` in snapcraft.yaml:
   ```yaml
   build-packages:
     - new-dev-package
   ```

2. Update `stage-packages` if needed:
   ```yaml
   stage-packages:
     - new-runtime-package
   ```

3. Clean build and test:
   ```bash
   snapcraft clean
   snapcraft
   ```

### Changing Desktop Integration

1. Edit `snap/gui/hasi.desktop`
2. Update icon if needed: `snap/gui/hasi.png`
3. Rebuild and test:
   ```bash
   snapcraft
   sudo snap install hasi_*.snap --dangerous
   # Check application menu
   ```

## Testing Checklist

Before submitting changes, verify:

- [ ] Validation script passes: `./snap/validate-snap.sh`
- [ ] Snap builds successfully: `snapcraft`
- [ ] Snap installs without errors
- [ ] Application launches from menu
- [ ] Application launches from terminal
- [ ] All required permissions work
- [ ] Settings persist across restarts
- [ ] Auto-discovery works (if applicable)
- [ ] Voice features work (if applicable)
- [ ] Camera viewing works (if applicable)
- [ ] No errors in logs: `snap logs hasi`
- [ ] Desktop file is valid
- [ ] Icon displays correctly
- [ ] Version numbers match

## Debugging

### Build Issues

```bash
# Clean everything
snapcraft clean

# Build with debug output
snapcraft --debug

# Build in shell (for manual debugging)
snapcraft --shell

# Use LXD for clean environment
snapcraft --use-lxd --debug
```

### Runtime Issues

```bash
# Install in devmode
sudo snap install hasi_*.snap --dangerous --devmode

# Check logs
snap logs hasi -f

# Run in shell to check environment
snap run --shell hasi
env | grep SNAP

# Check file permissions
ls -la ~/snap/hasi/current/
```

### Permission Issues

```bash
# List all connections
snap connections hasi

# Manually connect interface
sudo snap connect hasi:interface-name

# Check interface availability
snap interface interface-name
```

## Submitting Changes

### Pull Request Guidelines

1. **Test thoroughly** using the checklist above
2. **Update documentation** if adding features
3. **Update version** if appropriate
4. **Describe changes** clearly in PR description
5. **Include test results** from validation script

### PR Description Template

```markdown
## Changes
- Brief description of changes

## Testing
- [ ] Validation script passes
- [ ] Built and tested locally
- [ ] All features work as expected

## Checklist
- [ ] Version updated (if needed)
- [ ] Documentation updated
- [ ] Desktop file updated (if needed)
- [ ] Permissions updated (if needed)

## Test Results
```
[paste validation script output]
```
```

## Release Process

### For Maintainers

1. **Update version** in both pubspec.yaml and snapcraft.yaml
2. **Test thoroughly** with clean build
3. **Tag release** in git:
   ```bash
   git tag -a v1.1.0 -m "Release 1.1.0"
   git push origin v1.1.0
   ```
4. **GitHub Actions** will automatically build and publish
5. **Verify** snap appears in store

### Manual Release

```bash
# Build
snapcraft --use-lxd

# Login to store
snapcraft login

# Upload to edge for testing
snapcraft upload hasi_*.snap --release=edge

# Test edge release
sudo snap install hasi --edge

# Promote to stable when ready
snapcraft release hasi <revision> stable
```

## Resources

- [Snapcraft Documentation](https://snapcraft.io/docs)
- [Flutter Plugin for Snapcraft](https://snapcraft.io/docs/flutter-plugin)
- [Snap Interfaces](https://snapcraft.io/docs/supported-interfaces)
- [Snapcraft Forum](https://forum.snapcraft.io/)
- [Flutter Desktop](https://docs.flutter.dev/platform-integration/linux/building)

## Getting Help

- **Snap Issues**: [Snapcraft Forum](https://forum.snapcraft.io/)
- **Flutter Issues**: [Flutter GitHub](https://github.com/flutter/flutter/issues)
- **Hasi Issues**: [Project Issues](../../issues)

## Code of Conduct

Please be respectful and constructive in all interactions. We're all here to make Hasi better!
