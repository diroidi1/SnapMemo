import 'dart:convert';

class Memo {
  final String id;
  final String filePath;
  final String? note;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Memo({
    required this.id,
    required this.filePath,
    this.note,
    required this.createdAt,
    required this.expiresAt,
  });

  Duration get timeLeft => expiresAt.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Memo copyWith({
    String? id,
    String? filePath,
    String? note,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Memo(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'filePath': filePath,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] as String,
      filePath: map['filePath'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Memo.fromJson(String source) => Memo.fromMap(jsonDecode(source));
}
