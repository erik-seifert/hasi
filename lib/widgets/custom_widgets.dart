import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../models/custom_widget.dart';
import '../utils/date_utils.dart';

class CustomImageWidget extends StatelessWidget {
  final CustomWidget widget;

  const CustomImageWidget({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.config[ImageWidgetConfig.imagePath] as String?;
    final fitName = widget.config[ImageWidgetConfig.fit] as String? ?? 'cover';
    final height = widget.config[ImageWidgetConfig.height] as double? ?? 200.0;

    final fit = BoxFit.values.firstWhere(
      (e) => e.name == fitName,
      orElse: () => BoxFit.cover,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: imagePath == null || imagePath.isEmpty
            ? Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No image selected'),
                    ],
                  ),
                ),
              )
            : Image.file(
                File(imagePath),
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Image not found'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class CustomTextWidget extends StatelessWidget {
  final CustomWidget widget;

  const CustomTextWidget({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    // For text widgets, we primarily use the 'text' field from config.
    // The other fields (style, alignment, fontSize, color) are now handled via Markdown or global theme.
    var text = widget.config[TextWidgetConfig.text] as String? ?? '';
    if (HaDateUtils.isHaTimestamp(text)) {
      text = HaDateUtils.formatHaTimestamp(text);
    }

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: text.isEmpty
            ? Center(
                child: Text(
                  'Tap to edit text',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  Theme.of(context),
                ).copyWith(p: Theme.of(context).textTheme.bodyLarge),
                selectable: true,
              ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Image Widget', type: CustomImageWidget)
Widget buildCustomImageWidgetUseCase(BuildContext context) {
  return CustomImageWidget(
    widget: CustomWidget(
      id: 'test_image',
      type: CustomWidgetType.image,
      config: {
        ImageWidgetConfig.imagePath: '',
        ImageWidgetConfig.fit: 'cover',
        ImageWidgetConfig.height: 200.0,
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Text Widget', type: CustomTextWidget)
Widget buildCustomTextWidgetUseCase(BuildContext context) {
  return CustomTextWidget(
    widget: CustomWidget(
      id: 'test_text',
      type: CustomWidgetType.text,
      config: {
        TextWidgetConfig.text:
            '# Hello Markdown\nThis is a **test** of the text widget.',
      },
    ),
  );
}
