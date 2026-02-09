# Snap Integration - Quick Start Guide

This guide will get you up and running with Hasi snap package in 5 minutes.

## For Users

### Install from Snap Store (Recommended)

Once published, installation is simple:

```bash
sudo snap install hasi
```

Then launch from your application menu or run:
```bash
hasi
```

### Install from Local File

If you have a `.snap` file:

```bash
sudo snap install hasi_1.0.0_amd64.snap --dangerous
hasi
```

## For Developers

### Quick Build & Test

```bash
# 1. Install snapcraft
sudo snap install snapcraft --classic

# 2. Build the snap
./snap/build-snap.sh build

# 3. Install locally
./snap/build-snap.sh install

# 4. Run the app
hasi
```

### Development Cycle

```bash
# Make changes to code...

# Rebuild
./snap/build-snap.sh build --clean

# Reinstall
./snap/build-snap.sh install

# Test
hasi
```

## Common Commands

```bash
# View logs
snap logs hasi -f

# Check permissions
snap connections hasi

# Uninstall
sudo snap remove hasi

# Get help
./snap/build-snap.sh help
```

## Troubleshooting

### App won't start
```bash
snap logs hasi -f
```

### Can't find Home Assistant
```bash
sudo snap connect hasi:avahi-observe
```

### No audio
```bash
sudo snap connect hasi:audio-playback
sudo snap connect hasi:audio-record
```

## Next Steps

- **Users**: See [snap/README.md](README.md) for detailed usage
- **Developers**: See [snap/CONTRIBUTING.md](CONTRIBUTING.md) for development guide
- **Commands**: See [snap/SNAP_COMMANDS.md](SNAP_COMMANDS.md) for command reference

## File Structure

```
snap/
├── snapcraft.yaml          # Main configuration
├── gui/
│   ├── hasi.desktop       # Desktop entry
│   └── hasi.png           # App icon
├── README.md              # Detailed documentation
├── CONTRIBUTING.md        # Development guide
├── SNAP_COMMANDS.md       # Command reference
├── QUICK_START.md         # This file
├── build-snap.sh          # Build helper script
└── validate-snap.sh       # Validation script
```

## Support

- Issues: [GitHub Issues](../../issues)
- Snap Forum: [forum.snapcraft.io](https://forum.snapcraft.io/)
- Home Assistant: [community.home-assistant.io](https://community.home-assistant.io/)
