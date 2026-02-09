import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/theme_service.dart';
import '../l10n/app_localizations.dart';
import 'logs_screen.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearance)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.darkMode),
            secondary: Icon(
              themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeService.isDarkMode,
            onChanged: (val) => themeService.toggleDarkMode(),
          ),
          SwitchListTile(
            title: Text(l10n.glassmorphism),
            subtitle: Text(l10n.glassmorphismSub),
            secondary: const Icon(Icons.blur_on),
            value: themeService.useGlassmorphism,
            onChanged: (val) => themeService.toggleGlassmorphism(),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.language),
            leading: const Icon(Icons.language),
            trailing: DropdownButton<String>(
              value: themeService.locale?.languageCode,
              underline: const SizedBox(),
              hint: Text(l10n.systemDefault),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.systemDefault)),
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                DropdownMenuItem(value: 'de', child: Text(l10n.german)),
                DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
              ],
              onChanged: (code) {
                themeService.setLocale(code == null ? null : Locale(code));
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.accentColor,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ColorPicker(
              pickerColor: themeService.seedColor,
              onColorChanged: (color) => themeService.setSeedColor(color),
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              labelTypes: const [],
              paletteType: PaletteType.hsvWithHue,
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Troubleshooting',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('HA Communication Logs'),
            subtitle: const Text('View raw requests and responses'),
            leading: const Icon(Icons.history),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
