import 'dart:convert';

class Workspace {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;

  Workspace({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Workspace.fromMap(Map<String, dynamic> map) {
    return Workspace(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt']) ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Workspace.fromJson(String source) => Workspace.fromMap(json.decode(source));

  Workspace copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
