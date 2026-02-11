# Snap Quick Reference Guide

## Installation Commands

```bash
# Install from Snap Store (when published)
sudo snap install hasi

# Install local snap file
sudo snap install hasi_1.0.0_amd64.snap --dangerous

# Install in devmode (for debugging, disables confinement)
sudo snap install hasi_1.0.0_amd64.snap --dangerous --devmode

# Install from edge channel (development builds)
sudo snap install hasi --edge

# Install from beta channel
sudo snap install hasi --beta
```

## Running the App

```bash
# Run from terminal
hasi

# Or find it in your application menu
# Look for "Hasi" in your app launcher
```

## Managing the Snap

```bash
# List installed snaps
snap list

# Show detailed info about hasi
snap info hasi

# Check version
snap list hasi

# Refresh (update) to latest version
sudo snap refresh hasi

# Refresh from specific channel
sudo snap refresh hasi --channel=edge

# Revert to previous version
sudo snap revert hasi

# Remove/uninstall
sudo snap remove hasi
```

## Permissions & Connections

```bash
# List all connections
snap connections hasi

# Connect a specific interface
sudo snap connect hasi:camera
sudo snap connect hasi:audio-record
sudo snap connect hasi:audio-playback

# Disconnect an interface
sudo snap disconnect hasi:camera

# List available interfaces
snap interface
```

## Debugging & Logs

```bash
# View logs (follow mode)
snap logs hasi -f

# View last 100 lines
snap logs hasi -n 100

# View all logs
snap logs hasi --all

# Check snap services status
snap services hasi
```

## Configuration & Data

```bash
# Snap data is stored in:
~/snap/hasi/current/

# View snap environment
snap run --shell hasi
# Then inside the shell:
env | grep SNAP

# Access snap data directory
cd ~/snap/hasi/current/
```

## Updates & Refresh

```bash
# Disable auto-refresh temporarily
sudo snap refresh --hold hasi

# Re-enable auto-refresh
sudo snap refresh --unhold hasi

# Check for updates
snap refresh --list

# Set refresh schedule
sudo snap set system refresh.timer=4:00-7:00,19:00-22:00
```

## Building Locally

```bash
# Using helper script
./snap/build-snap.sh build          # Build snap
./snap/build-snap.sh build --clean  # Clean build
./snap/build-snap.sh install        # Install locally
./snap/build-snap.sh info           # Show info
./snap/build-snap.sh logs           # View logs
./snap/build-snap.sh uninstall      # Remove snap

# Manual build
snapcraft                           # Build snap
snapcraft clean                     # Clean build environment
snapcraft --debug                   # Build with debug output
```

## Publishing (Maintainers Only)

```bash
# Login to Snap Store
snapcraft login

# Register app name
snapcraft register hasi

# Upload to edge channel
snapcraft upload hasi_1.0.0_amd64.snap --release=edge

# Upload to beta channel
snapcraft upload hasi_1.0.0_amd64.snap --release=beta

# Upload to stable channel
snapcraft upload hasi_1.0.0_amd64.snap --release=stable

# Promote from edge to stable
snapcraft release hasi 1 stable

# Check status
snapcraft status hasi

# Logout
snapcraft logout
```

## Troubleshooting

### App won't start
```bash
# Check logs
snap logs hasi -f

# Try devmode
sudo snap install hasi_*.snap --dangerous --devmode

# Check connections
snap connections hasi
```

### Permission denied errors
```bash
# Connect required interfaces
sudo snap connect hasi:home
sudo snap connect hasi:network
sudo snap connect hasi:audio-playback
```

### Can't find Home Assistant
```bash
# Ensure network discovery is enabled
sudo snap connect hasi:avahi-observe
sudo snap connect hasi:network
```

### Audio not working
```bash
# Connect audio interfaces
sudo snap connect hasi:audio-playback
sudo snap connect hasi:audio-record
sudo snap connect hasi:pulseaudio
```

### Build failures
```bash
# Clean and rebuild
snapcraft clean
snapcraft

# Use LXD for clean environment
sudo snap install lxd
sudo lxd init --auto
snapcraft --use-lxd
```

## Useful Snap Commands

```bash
# Find snap in store
snap find hasi

# Download snap without installing
snap download hasi

# Get snap size
snap list --all | grep hasi

# Check snap confinement
snap list hasi

# View snap changes/history
snap changes

# Abort a change
sudo snap abort <change-id>

# Acknowledge snap
snap ack <assertion-file>
```

## Environment Variables

When running the snap, these environment variables are set:

- `$SNAP` - Snap installation directory
- `$SNAP_DATA` - System data directory
- `$SNAP_USER_DATA` - User data directory (~/snap/hasi/current)
- `$SNAP_USER_COMMON` - User common directory (~/snap/hasi/common)
- `$SNAP_NAME` - Name of the snap (hasi)
- `$SNAP_VERSION` - Version of the snap

## Resources

- [Snapcraft Documentation](https://snapcraft.io/docs)
- [Snap Store](https://snapcraft.io/store)
- [Snapcraft Forum](https://forum.snapcraft.io/)
- [Hasi Snap README](SNAP_SETUP.md)
