import 'dart:convert';

class Settings {
  final Duration defaultTtl;
  final bool showNoteInput;

  const Settings({
    required this.defaultTtl,
    required this.showNoteInput,
  });

  Settings copyWith({Duration? defaultTtl, bool? showNoteInput}) => Settings(
        defaultTtl: defaultTtl ?? this.defaultTtl,
        showNoteInput: showNoteInput ?? this.showNoteInput,
      );

  Map<String, dynamic> toMap() => {
        'defaultTtlHours': defaultTtl.inHours,
        'showNoteInput': showNoteInput,
      };

  factory Settings.fromMap(Map<String, dynamic> map) => Settings(
        defaultTtl: Duration(hours: (map['defaultTtlHours'] as num?)?.toInt() ?? 24 * 14),
        showNoteInput: (map['showNoteInput'] as bool?) ?? true,
      );

  String toJson() => jsonEncode(toMap());
  factory Settings.fromJson(String source) => Settings.fromMap(jsonDecode(source));
}
