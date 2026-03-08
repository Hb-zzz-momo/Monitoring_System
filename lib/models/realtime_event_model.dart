class RealtimeEventModel {
  final String type;
  final String icon;
  final String text;
  final String time;
  final Map<String, dynamic> extra;

  const RealtimeEventModel({
    required this.type,
    required this.icon,
    required this.text,
    required this.time,
    this.extra = const {},
  });

  factory RealtimeEventModel.fromJson(Map<String, dynamic> json) {
    return RealtimeEventModel(
      type: json['type']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      extra: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'icon': icon,
        'text': text,
        'time': time,
      };
}
