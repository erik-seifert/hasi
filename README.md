# Hasi - Home Assistant Interface

A modern, cross-platform Home Assistant client built with Flutter. Hasi provides a beautiful and intuitive interface to control your smart home devices, view dashboards, and interact with your Home Assistant instance.

![Hasi Icon](snap/gui/hasi.png)

## Features

- 🏠 **Connect to Home Assistant** via WebSocket
- 🔍 **Auto-discovery** of Home Assistant instances using mDNS/Avahi
- 📊 **Customizable dashboards** with drag-and-drop support
- 💡 **Control devices**: Lights, climate, sensors, cameras, media players, and more
- 🎤 **Voice control** integration with speech-to-text and text-to-speech
- 🔔 **Notifications and alerts** for important events
- 🌍 **Multi-language support** with localization
- 🎨 **Theme customization** with light and dark modes
- 🔐 **Secure storage** for credentials and settings

## Installation

### Linux (Snap Package)

The easiest way to install Hasi on Linux is via Snap:

```bash
# Install from the Snap Store (when published)
sudo snap install hasi

# Or install a local build
sudo snap install hasi_1.0.0_amd64.snap --dangerous
```

After installation, launch from your application menu or run:
```bash
hasi
```

For more details on building and testing the snap, see [snap/README.md](snap/README.md).

### Build from Source

#### Prerequisites

- Flutter SDK (3.10.8 or higher)
- For Linux: GTK 3.0 development libraries
  ```bash
  sudo apt-get install libgtk-3-dev libsecret-1-dev libsqlite3-dev libavahi-client-dev
  ```

#### Build Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd hasi
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   # For Linux
   flutter run -d linux
   
   # For other platforms
   flutter run -d <device>
   ```

4. **Build for production**:
   ```bash
   # Linux
   flutter build linux
   
   # Android
   flutter build apk
   
   # iOS
   flutter build ios
   ```

## Development

### Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── services/                 # Business logic and services
├── widgets/                  # Reusable widgets
└── l10n/                     # Localization files

snap/                         # Snap packaging configuration
├── snapcraft.yaml           # Snap build configuration
├── gui/                     # Desktop integration files
└── README.md                # Snap documentation
```

### Running Tests

```bash
flutter test
```

### Code Generation

This project uses code generation for some features:

```bash
# Generate localization files
flutter gen-l10n

# Generate widget book (for UI component testing)
flutter pub run build_runner build
```

## Configuration

On first launch, Hasi will:
1. Attempt to auto-discover Home Assistant instances on your network
2. Prompt you to enter your Home Assistant URL and credentials
3. Connect via WebSocket and load your entities

### Manual Configuration

If auto-discovery doesn't work, you can manually configure:
- **Home Assistant URL**: `http://your-ha-instance:8123`
- **Long-Lived Access Token**: Generate in Home Assistant Profile → Security

## Snap Development

To build and test the snap package locally:

```bash
# Use the helper script
./snap/build-snap.sh build
./snap/build-snap.sh install
./snap/build-snap.sh run

# Or manually
snapcraft
sudo snap install hasi_1.0.0_amd64.snap --dangerous
```

See [snap/README.md](snap/README.md) for detailed snap development instructions.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## Support

For issues and questions:
- Open an issue on GitHub
- Check the [Home Assistant Community](https://community.home-assistant.io/)

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Integrates with [Home Assistant](https://www.home-assistant.io/)
- Icons and design inspired by modern Material Design principles
