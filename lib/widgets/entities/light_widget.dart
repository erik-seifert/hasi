import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../services/hass_websocket_service.dart';
import '../../controllers/light_controller.dart';

import '../../models/dashboard.dart';

class LightWidget extends StatefulWidget {
  final String entityId;
  final EntityConfig? config;

  const LightWidget({super.key, required this.entityId, this.config});

  @override
  State<LightWidget> createState() => _LightWidgetState();
}

class _LightWidgetState extends State<LightWidget> {
  late LightController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LightController(
      widget.entityId,
      context.read<HassWebSocketService>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entityId = widget.entityId;
    final entity = context.select<HassWebSocketService, Map<String, dynamic>?>(
      (ws) => ws.entitiesMap[entityId],
    );

    if (entity == null) return const SizedBox.shrink();

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<LightController>(
        builder: (context, controller, child) {
          final attributes = entity['attributes'] ?? {};
          final state = entity['state'];
          final isOn = state == 'on';

          final brightness = controller.getBrightness(
            attributes['brightness'] ?? 0,
          );
          final colorTemp = controller.getColorTemp(
            attributes['color_temp'] ?? 250,
          );
          final minMireks = attributes['min_mireks'] ?? 153;
          final maxMireks = attributes['max_mireks'] ?? 500;
          final supportedColorModes = attributes['supported_color_modes'] ?? [];
          final rgbColorList = controller.getRgbColor(
            List<int>.from(attributes['rgb_color'] ?? [255, 255, 255]),
          );

          Color bulbColor = Colors.grey;
          if (isOn) {
            if (attributes['rgb_color'] != null) {
              bulbColor = Color.fromARGB(
                255,
                rgbColorList[0],
                rgbColorList[1],
                rgbColorList[2],
              );
            } else if (attributes['color_temp'] != null) {
              double ratio = (colorTemp - minMireks) / (maxMireks - minMireks);
              bulbColor =
                  Color.lerp(
                    Colors.lightBlue.shade100,
                    Colors.orangeAccent,
                    ratio.clamp(0.0, 1.0),
                  ) ??
                  Colors.yellow;
            } else {
              bulbColor = Colors.yellow;
            }
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: bulbColor.withValues(alpha: isOn ? 0.2 : 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isOn ? 0.1 : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [bulbColor, Colors.transparent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildContent(
                      context,
                      entity,
                      controller,
                      isOn,
                      bulbColor,
                      brightness,
                      colorTemp,
                      minMireks,
                      maxMireks,
                      supportedColorModes,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, dynamic> entity,
    LightController controller,
    bool isOn,
    Color bulbColor,
    int brightness,
    int colorTemp,
    int minMireks,
    int maxMireks,
    List<dynamic> supportedColorModes,
  ) {
    final attributes = entity['attributes'] ?? {};
    final friendlyName =
        widget.config?.nameOverride ??
        attributes['friendly_name'] ??
        widget.entityId;

    final showBrightness = widget.config?.options['show_brightness'] ?? true;
    final showColor = widget.config?.options['show_color'] ?? true;
    final hasControls = showBrightness || showColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: () => controller.toggle(!isOn),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bulbColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                color: bulbColor,
              ),
            ),
          ),
          title: Text(
            friendlyName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isOn ? Colors.grey[700] : Colors.grey,
              fontSize: 12,
            ),
            child: Text(
              isOn
                  ? (showBrightness
                        ? 'Brightness: ${(brightness / 255 * 100).round()}%'
                        : 'On')
                  : 'Off',
            ),
          ),
          trailing: Switch(
            value: isOn,
            activeThumbColor: bulbColor,
            onChanged: (val) => controller.toggle(val),
          ),
        ),
        if (hasControls)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isOn ? 1.0 : 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBrightness)
                    _buildSlider(
                      label: 'Brightness',
                      icon: Icons.brightness_medium,
                      value: brightness.toDouble(),
                      min: 0,
                      max: 255,
                      activeColor: bulbColor,
                      onChanged: isOn ? controller.setBrightness : null,
                    ),
                  if (showColor && supportedColorModes.contains('color_temp'))
                    _buildSlider(
                      label: 'Color Temperature',
                      icon: Icons.wb_sunny,
                      value: colorTemp.toDouble(),
                      min: minMireks.toDouble(),
                      max: maxMireks.toDouble(),
                      activeColor: Colors.orangeAccent,
                      onChanged: isOn ? controller.setColorTemp : null,
                    ),
                  if (showColor &&
                      (supportedColorModes.contains('hs') ||
                          supportedColorModes.contains('rgb')))
                    _buildColorPicker(context, controller, isOn, bulbColor),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required Color activeColor,
    void Function(double)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  activeColor: activeColor,
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    LightController controller,
    bool isOn,
    Color bulbColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Color',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: !isOn,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ColorDot(color: Colors.red, controller: controller),
              _ColorDot(color: Colors.green, controller: controller),
              _ColorDot(color: Colors.blue, controller: controller),
              _ColorDot(color: Colors.yellow, controller: controller),
              _ColorDot(color: Colors.purple, controller: controller),
              _ColorDot(color: Colors.orange, controller: controller),
              IconButton(
                icon: const Icon(Icons.colorize),
                onPressed: isOn
                    ? () => _showColorPickerDial(context, controller, bulbColor)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showColorPickerDial(
    BuildContext context,
    LightController controller,
    Color currentColor,
  ) {
    Color selectedColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => selectedColor = color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.setRgbColor(selectedColor);
              Navigator.pop(context);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final LightController controller;

  const _ColorDot({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.setRgbColor(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'RGB Light', type: LightWidget)
Widget buildLightWidgetRGBUseCase(BuildContext context) {
  return const LightWidget(entityId: 'light.rgb_lamp');
}

@widgetbook.UseCase(name: 'Color Temp Light', type: LightWidget)
Widget buildLightWidgetTempUseCase(BuildContext context) {
  return const LightWidget(entityId: 'light.kitchen');
}
