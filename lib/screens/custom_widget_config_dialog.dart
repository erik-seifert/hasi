import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/custom_widget.dart';
import '../l10n/app_localizations.dart';

class CustomWidgetConfigDialog extends StatefulWidget {
  final CustomWidget? existingWidget;
  final CustomWidgetType? initialType;

  const CustomWidgetConfigDialog({
    super.key,
    this.existingWidget,
    this.initialType,
  });

  @override
  State<CustomWidgetConfigDialog> createState() =>
      _CustomWidgetConfigDialogState();
}

class _CustomWidgetConfigDialogState extends State<CustomWidgetConfigDialog> {
  late CustomWidgetType _selectedType;
  late Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();
    _selectedType =
        widget.existingWidget?.type ??
        widget.initialType ??
        CustomWidgetType.text;
    _config = Map.from(widget.existingWidget?.config ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        widget.existingWidget == null
            ? 'Add Custom Widget'
            : 'Edit Custom Widget',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.existingWidget == null) ...[
                Text(
                  'Widget Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<CustomWidgetType>(
                  segments: const [
                    ButtonSegment(
                      value: CustomWidgetType.text,
                      label: Text('Text'),
                      icon: Icon(Icons.text_fields),
                    ),
                    ButtonSegment(
                      value: CustomWidgetType.image,
                      label: Text('Image'),
                      icon: Icon(Icons.image),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<CustomWidgetType> newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                      _config.clear();
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
              if (_selectedType == CustomWidgetType.text)
                _buildTextWidgetConfig(l10n)
              else
                _buildImageWidgetConfig(l10n),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _saveWidget, child: Text(l10n.save)),
      ],
    );
  }

  Widget _buildTextWidgetConfig(AppLocalizations l10n) {
    final text = _config[TextWidgetConfig.text] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Markdown Content',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: text)
            ..selection = TextSelection.collapsed(offset: text.length),
          maxLines: 8,
          decoration: const InputDecoration(
            hintText:
                'Enter your markdown text here...\n\nExample:\n# Title\n**Bold text**\n* Italic text\n- List item',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _config[TextWidgetConfig.text] = value;
          },
        ),
      ],
    );
  }

  Widget _buildImageWidgetConfig(AppLocalizations l10n) {
    final imagePath = _config[ImageWidgetConfig.imagePath] as String? ?? '';
    final fit = _config[ImageWidgetConfig.fit] as String? ?? 'cover';
    final height = _config[ImageWidgetConfig.height] as double? ?? 200.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Image File', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.folder_open),
          label: Text(imagePath.isEmpty ? 'Select Image' : 'Change Image'),
        ),
        if (imagePath.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            imagePath.split('/').last,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 16),
        Text('Image Fit', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: fit,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'cover', child: Text('Cover')),
            DropdownMenuItem(value: 'contain', child: Text('Contain')),
            DropdownMenuItem(value: 'fill', child: Text('Fill')),
            DropdownMenuItem(value: 'fitWidth', child: Text('Fit Width')),
            DropdownMenuItem(value: 'fitHeight', child: Text('Fit Height')),
            DropdownMenuItem(value: 'none', child: Text('None')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _config[ImageWidgetConfig.fit] = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Height: ${height.toInt()}px',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: height,
          min: 100,
          max: 600,
          divisions: 50,
          label: '${height.toInt()}px',
          onChanged: (value) {
            setState(() {
              _config[ImageWidgetConfig.height] = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _config[ImageWidgetConfig.imagePath] = result.files.single.path!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _saveWidget() {
    // Validate based on type
    if (_selectedType == CustomWidgetType.image) {
      final imagePath = _config[ImageWidgetConfig.imagePath] as String?;
      if (imagePath == null || imagePath.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an image')));
        return;
      }
    }

    final customWidget = CustomWidget(
      id:
          widget.existingWidget?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      type: _selectedType,
      config: _config,
    );

    Navigator.pop(context, customWidget);
  }
}
