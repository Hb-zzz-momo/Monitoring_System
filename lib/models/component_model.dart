class ComponentMetricModel {
  final String name;
  final String value;
  final String unit;

  const ComponentMetricModel({
    required this.name,
    required this.value,
    required this.unit,
  });

  factory ComponentMetricModel.fromJson(Map<String, dynamic> json) {
    return ComponentMetricModel(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'unit': unit,
      };
}

class ComponentModel {
  final String id;
  final String name;
  final double healthIndex;
  final int rul;
  final String rulRange;
  final List<String> suggestions;
  final List<ComponentMetricModel> metrics;
  final String deviceId;
  final String deviceName;
  final Map<String, dynamic> extra;

  const ComponentModel({
    required this.id,
    required this.name,
    required this.healthIndex,
    required this.rul,
    required this.rulRange,
    this.suggestions = const [],
    this.metrics = const [],
    this.deviceId = '',
    this.deviceName = '',
    this.extra = const {},
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'];
    final rawMetrics = json['metrics'];
    return ComponentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      healthIndex: (json['healthIndex'] as num?)?.toDouble() ?? 0.0,
      rul: (json['rul'] as num?)?.toInt() ?? 0,
      rulRange: json['rulRange']?.toString() ?? '',
      suggestions: rawSuggestions is List
          ? rawSuggestions.map((item) => item.toString()).toList()
          : const [],
      metrics: rawMetrics is List
          ? rawMetrics
              .whereType<Map<String, dynamic>>()
              .map(ComponentMetricModel.fromJson)
              .toList()
          : const [],
      deviceId: json['deviceId']?.toString() ??
          json['device_id']?.toString() ??
          '',
      deviceName: json['device']?.toString() ??
          json['deviceName']?.toString() ??
          json['device_name']?.toString() ??
          '',
      extra: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'healthIndex': healthIndex,
        'rul': rul,
        'rulRange': rulRange,
        'suggestions': suggestions,
        'metrics': metrics.map((metric) => metric.toJson()).toList(),
        'deviceId': deviceId,
        'deviceName': deviceName,
      };
}
