# Text-to-Speech (TTS) Setup

HASI uses a **hybrid TTS approach** to provide the best experience across all platforms.

## Platform Support

| Platform    | TTS Engine                        | Status      |
| ----------- | --------------------------------- | ----------- |
| **Linux**   | espeak-ng / espeak / festival     | ✅ Native    |
| **Windows** | flutter_tts (SAPI)                | ✅ Supported |
| **macOS**   | flutter_tts (AVSpeechSynthesizer) | ✅ Supported |
| **Android** | flutter_tts (Android TTS)         | ✅ Supported |
| **iOS**     | flutter_tts (AVSpeechSynthesizer) | ✅ Supported |

## Linux Setup

### Automatic Installation

Run the installation script:

```bash
./scripts/install_linux_tts.sh
```

This will:
1. Detect your package manager (apt, dnf, pacman, zypper)
2. Install espeak-ng
3. Test the TTS functionality

### Manual Installation

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install espeak-ng
```

#### Fedora
```bash
sudo dnf install espeak-ng
```

#### Arch Linux
```bash
sudo pacman -S espeak-ng
```

#### openSUSE
```bash
sudo zypper install espeak-ng
```

### Testing TTS

Test espeak-ng directly:
```bash
espeak-ng -v en-us "Hello, this is a test"
```

## How It Works

The `VoiceService` class automatically detects the platform and uses the appropriate TTS engine:

1. **On Linux**: 
   - Checks for `espeak-ng`, `espeak`, or `festival`
   - Uses the first available engine via process execution
   - Falls back to flutter_tts if no native engine is found

2. **On Other Platforms**:
   - Uses `flutter_tts` package directly
   - Leverages platform-native TTS APIs

## Advanced Configuration

### Adjusting Speech Parameters (Linux)

Edit `/home/erik/projects/flutter/hasi/lib/services/voice_service.dart`:

```dart
// For espeak-ng/espeak:
args = [
  '-v', 'en-us',     // Voice (try: en-gb, en-scottish, etc.)
  '-s', '150',       // Speed in words per minute (default: 175)
  '-a', '100',       // Amplitude/volume (0-200, default: 100)
  '-p', '50',        // Pitch (0-99, default: 50)
  text
];
```

### Available Voices

List available espeak-ng voices:
```bash
espeak-ng --voices
```

## Troubleshooting

### No sound on Linux

1. **Check if espeak-ng is installed:**
   ```bash
   which espeak-ng
   ```

2. **Test audio output:**
   ```bash
   espeak-ng "test"
   ```

3. **Check system volume:**
   ```bash
   amixer get Master
   ```

4. **Install PulseAudio (if needed):**
   ```bash
   sudo apt install pulseaudio
   ```

### TTS not working in app

Check the Flutter console for debug messages:
- "Using native Linux TTS engine: espeak-ng" ✅ Good
- "No native Linux TTS engine found" ❌ Install espeak-ng
- "Using flutter_tts" ⚠️ Fallback mode (limited Linux support)

## Alternative Engines

### Festival (More Natural Voice)

Install:
```bash
sudo apt install festival festvox-kallpc16k
```

The app will automatically detect and use Festival if espeak-ng is not available.

Test:
```bash
echo "Hello from Festival" | festival --tts
```

### Piper (Neural TTS - Highest Quality)

For the best quality, you can manually integrate [Piper](https://github.com/rhasspy/piper):

```bash
# Install piper
wget https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_amd64.tar.gz
tar -xzf piper_amd64.tar.gz

# Download a voice model
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json

# Test
echo "Hello from Piper" | ./piper --model en_US-lessac-medium.onnx --output_file test.wav
aplay test.wav
```

To integrate Piper into the app, modify `_detectLinuxTtsEngine()` to include it in the detection list.

## Performance Notes

- **espeak-ng**: Fast, lightweight, robotic voice
- **festival**: Slower, more natural voice
- **piper**: Highest quality, requires model download (~50MB per voice)

## API Usage

```dart
// Get the voice service
final voiceService = Provider.of<VoiceService>(context, listen: false);

// Speak text
await voiceService.speak("Hello, world!");

// Stop speaking
await voiceService.stop();

// Check which engine is being used
if (voiceService.useNativeTts) {
  print("Using native Linux TTS: ${voiceService.linuxTtsEngine}");
}
```

## Contributing

If you'd like to add support for additional TTS engines, modify the `_detectLinuxTtsEngine()` and `_speakLinux()` methods in `voice_service.dart`.
