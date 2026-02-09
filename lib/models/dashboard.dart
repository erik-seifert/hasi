import 'dart:convert';

class EntityConfig {
  final String? nameOverride;
  final Map<String, dynamic> options;

  EntityConfig({this.nameOverride, this.options = const {}});

  Map<String, dynamic> toMap() {
    return {'nameOverride': nameOverride, 'options': options};
  }

  factory EntityConfig.fromMap(Map<String, dynamic> map) {
    return EntityConfig(
      nameOverride: map['nameOverride'],
      options: Map<String, dynamic>.from(map['options'] ?? {}),
    );
  }
}

class Dashboard {
  final String id;
  final String name;
  final List<String> entityIds;
  final List<String> orderedEntityIds;
  final List<List<String>> columns;
  final Map<String, EntityConfig> entityConfigs;
  final int columnCount;

  Dashboard({
    required this.id,
    required this.name,
    this.entityIds = const [],
    this.orderedEntityIds = const [],
    this.columns = const [],
    this.entityConfigs = const {},
    this.columnCount = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'entityIds': entityIds,
      'orderedEntityIds': orderedEntityIds,
      'columns': columns,
      'entityConfigs': entityConfigs.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'columnCount': columnCount,
    };
  }

  factory Dashboard.fromMap(Map<String, dynamic> map) {
    final configsMap = map['entityConfigs'] as Map<String, dynamic>? ?? {};
    final entityConfigs = configsMap.map(
      (key, value) =>
          MapEntry(key, EntityConfig.fromMap(Map<String, dynamic>.from(value))),
    );

    final columnsData = map['columns'] as List<dynamic>?;
    List<List<String>> columns = [];
    if (columnsData != null) {
      columns = columnsData.map((c) => List<String>.from(c)).toList();
    }

    return Dashboard(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      entityIds: List<String>.from(map['entityIds'] ?? []),
      orderedEntityIds: List<String>.from(map['orderedEntityIds'] ?? []),
      columns: columns,
      entityConfigs: entityConfigs,
      columnCount: map['columnCount'] ?? 2,
    );
  }

  String toJson() => json.encode(toMap());

  factory Dashboard.fromJson(String source) =>
      Dashboard.fromMap(json.decode(source));

  Dashboard copyWith({
    String? id,
    String? name,
    List<String>? entityIds,
    List<String>? orderedEntityIds,
    List<List<String>>? columns,
    Map<String, EntityConfig>? entityConfigs,
    int? columnCount,
  }) {
    return Dashboard(
      id: id ?? this.id,
      name: name ?? this.name,
      entityIds: entityIds ?? this.entityIds,
      orderedEntityIds: orderedEntityIds ?? this.orderedEntityIds,
      columns: columns ?? this.columns,
      entityConfigs: entityConfigs ?? this.entityConfigs,
      columnCount: columnCount ?? this.columnCount,
    );
  }
}
