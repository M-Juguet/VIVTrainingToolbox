import 'dart:convert';

class AppSettings {
  final bool isFullScreen;

  AppSettings({
    this.isFullScreen = false,
  });

  AppSettings copyWith({
    bool? isFullScreen,
  }) {
    return AppSettings(
      isFullScreen: isFullScreen ?? this.isFullScreen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isFullScreen': isFullScreen,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isFullScreen: map['isFullScreen'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) => AppSettings.fromMap(json.decode(source));
}
