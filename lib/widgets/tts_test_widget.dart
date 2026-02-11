import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/voice_service.dart';

/// A simple widget to test TTS functionality
class TtsTestWidget extends StatefulWidget {
  const TtsTestWidget({super.key});

  @override
  State<TtsTestWidget> createState() => _TtsTestWidgetState();
}

class _TtsTestWidgetState extends State<TtsTestWidget> {
  final TextEditingController _textController = TextEditingController(
    text: "Hello from HASI. Text to speech is working perfectly on Linux!",
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = Provider.of<VoiceService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ttsTest)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Engine info card
            Card(
              color: voiceService.useNativeTts
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ttsEngineStatus,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          voiceService.useNativeTts
                              ? Icons.check_circle
                              : Icons.info,
                          color: voiceService.useNativeTts
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            voiceService.useNativeTts
                                ? l10n.ttsUsingNative.replaceAll(
                                    '{engine}',
                                    voiceService.linuxTtsEngine,
                                  )
                                : l10n.ttsUsingFallback,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Text input
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.ttsTextToSpeak,
                border: const OutlineInputBorder(),
                hintText: l10n.ttsEnterText,
              ),
            ),
            const SizedBox(height: 16),

            // Speak button
            ElevatedButton.icon(
              onPressed: voiceService.isSpeaking
                  ? null
                  : () async {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        await voiceService.speak(text);
                      }
                    },
              icon: Icon(
                voiceService.isSpeaking ? Icons.volume_up : Icons.play_arrow,
              ),
              label: Text(
                voiceService.isSpeaking ? l10n.ttsSpeaking : l10n.ttsSpeak,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            // Stop button
            ElevatedButton.icon(
              onPressed: voiceService.isSpeaking
                  ? () async {
                      await voiceService.stop();
                    }
                  : null,
              icon: const Icon(Icons.stop),
              label: Text(l10n.stop),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Quick test buttons
            Text(
              l10n.ttsQuickTests,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickTestButton(
                  label: l10n.ttsTestHello,
                  text: l10n.ttsTestHelloText,
                  voiceService: voiceService,
                ),
                _QuickTestButton(
                  label: l10n.ttsTestNumbers,
                  text: l10n.ttsTestNumbersText,
                  voiceService: voiceService,
                ),
                _QuickTestButton(
                  label: l10n.ttsTestLongText,
                  text: l10n.ttsTestLongTextContent,
                  voiceService: voiceService,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTestButton extends StatelessWidget {
  final String label;
  final String text;
  final VoiceService voiceService;

  const _QuickTestButton({
    required this.label,
    required this.text,
    required this.voiceService,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: voiceService.isSpeaking
          ? null
          : () => voiceService.speak(text),
      child: Text(label),
    );
  }
}
