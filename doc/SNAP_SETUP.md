# Snap Integration for Hasi

This directory contains the configuration files needed to build and distribute Hasi as a snap package for Linux.

## What is Snap?

Snap is a universal Linux package format developed by Canonical. It allows applications to be distributed across many Linux distributions with automatic updates, security sandboxing, and dependency management.

## Files Structure

```
snap/
├── snapcraft.yaml       # Main snap configuration
└── gui/
    ├── hasi.desktop     # Desktop entry file
    └── hasi.png         # Application icon (256x256)
```

## Building the Snap

### Prerequisites

1. Install snapcraft:
   ```bash
   sudo snap install snapcraft --classic
   ```

2. Install LXD (for building in a clean environment):
   ```bash
   sudo snap install lxd
   sudo lxd init --auto
   ```

### Build Process

1. **Build the snap** (from the project root):
   ```bash
   snapcraft
   ```

   This will:
   - Create a clean build environment
   - Install all dependencies
   - Build the Flutter application for Linux
   - Package everything into a `.snap` file

2. **Install locally for testing**:
   ```bash
   sudo snap install hasi_1.0.0_amd64.snap --dangerous
   ```

   The `--dangerous` flag is needed for locally built snaps that aren't signed by the Snap Store.

3. **Run the application**:
   ```bash
   hasi
   ```
   Or find it in your application menu.

## Snap Configuration Details

### Permissions (Plugs)

The snap requests the following permissions:

- **network**: Connect to Home Assistant instances
- **network-bind**: Allow the app to act as a network service
- **audio-playback**: For voice assistant responses
- **audio-record**: For voice commands
- **camera**: For camera entity viewing
- **desktop/wayland/x11**: GUI display
- **opengl**: Hardware acceleration
- **home**: Access to home directory for configuration
- **removable-media**: Access to external drives
- **avahi-observe**: mDNS/Avahi for Home Assistant discovery
- **pulseaudio**: Audio system integration

### Confinement

The snap uses **strict confinement**, which means:
- The app runs in a security sandbox
- It can only access resources through declared interfaces (plugs)
- This provides better security while maintaining functionality

## Publishing to Snap Store

### 1. Create a Snapcraft Account

```bash
snapcraft login
```

### 2. Register the App Name

```bash
snapcraft register hasi
```

### 3. Build and Upload

```bash
# Build the snap
snapcraft

# Upload to the store (edge channel for testing)
snapcraft upload hasi_1.0.0_amd64.snap --release=edge

# Once tested, promote to stable
snapcraft release hasi 1 stable
```

### 4. Channels

Snaps support multiple release channels:
- **stable**: Production-ready releases
- **candidate**: Release candidates for testing
- **beta**: Beta versions
- **edge**: Latest development builds

## Testing the Snap

### Test Installation

```bash
# Install from local file
sudo snap install hasi_1.0.0_amd64.snap --dangerous

# Check if it's running
snap list | grep hasi

# View logs
snap logs hasi

# Check connections
snap connections hasi
```

### Test Permissions

If the app needs additional permissions:

```bash
# Connect a specific interface manually
sudo snap connect hasi:camera

# Disconnect if needed
sudo snap disconnect hasi:camera
```

### Test Auto-Discovery

The snap includes Avahi support for automatic Home Assistant discovery. Ensure the `avahi-observe` plug is connected:

```bash
snap connections hasi | grep avahi
```

## Troubleshooting

### Build Failures

1. **Clean build environment**:
   ```bash
   snapcraft clean
   snapcraft
   ```

2. **Check logs**:
   ```bash
   snapcraft --debug
   ```

### Runtime Issues

1. **Check snap logs**:
   ```bash
   snap logs hasi -f
   ```

2. **Verify permissions**:
   ```bash
   snap connections hasi
   ```

3. **Test in devmode** (for debugging):
   ```bash
   sudo snap install hasi_1.0.0_amd64.snap --dangerous --devmode
   ```

### Common Issues

**Issue**: App can't find Home Assistant instance
- **Solution**: Ensure `avahi-observe` and `network` plugs are connected

**Issue**: No audio for voice commands
- **Solution**: Connect audio plugs:
  ```bash
  sudo snap connect hasi:audio-playback
  sudo snap connect hasi:audio-record
  ```

**Issue**: Can't save settings
- **Solution**: The snap has access to `$HOME/snap/hasi/current/` for persistent data

## Updating the Snap

### Version Updates

1. Update version in `snap/snapcraft.yaml`
2. Update version in `pubspec.yaml`
3. Rebuild and test:
   ```bash
   snapcraft clean
   snapcraft
   ```

### Automatic Updates

Users who install from the Snap Store will receive automatic updates. You can control this with:

```bash
# Disable auto-refresh for testing
sudo snap refresh --hold hasi

# Re-enable
sudo snap refresh --unhold hasi
```

## Additional Resources

- [Snapcraft Documentation](https://snapcraft.io/docs)
- [Flutter Snap Plugin](https://snapcraft.io/docs/flutter-plugin)
- [Publishing to Snap Store](https://snapcraft.io/docs/releasing-your-app)
- [Snap Interfaces Reference](https://snapcraft.io/docs/supported-interfaces)

## Support

For snap-specific issues, check:
- [Snapcraft Forum](https://forum.snapcraft.io/)
- [Flutter Desktop Snaps](https://snapcraft.io/docs/flutter-applications)
