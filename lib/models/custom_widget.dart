import 'dart:convert';

enum CustomWidgetType { image, text }

class CustomWidget {
  final String id;
  final CustomWidgetType type;
  final Map<String, dynamic> config;

  CustomWidget({required this.id, required this.type, required this.config});

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type.name, 'config': config};
  }

  factory CustomWidget.fromJson(Map<String, dynamic> json) {
    return CustomWidget(
      id: json['id'] as String,
      type: CustomWidgetType.values.firstWhere((e) => e.name == json['type']),
      config: Map<String, dynamic>.from(json['config'] as Map),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CustomWidget.fromJsonString(String jsonStr) {
    return CustomWidget.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  CustomWidget copyWith({
    String? id,
    CustomWidgetType? type,
    Map<String, dynamic>? config,
  }) {
    return CustomWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      config: config ?? this.config,
    );
  }
}

// Image widget config keys
class ImageWidgetConfig {
  static const String imagePath = 'imagePath';
  static const String fit = 'fit'; // BoxFit value name
  static const String height = 'height';
}

// Text widget config keys
class TextWidgetConfig {
  static const String text = 'text';
  static const String style = 'style'; // headline, body, bold, italic
  static const String alignment = 'alignment'; // left, center, right
  static const String fontSize = 'fontSize';
  static const String color = 'color'; // hex color string
}
