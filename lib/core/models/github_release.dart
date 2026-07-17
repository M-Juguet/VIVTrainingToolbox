class GithubRelease {
  final String tagName;
  final String body;
  final String downloadUrl;

  GithubRelease({
    required this.tagName,
    required this.body,
    required this.downloadUrl,
  });

  factory GithubRelease.fromJson(Map<String, dynamic> json) {
    String url = '';
    
    // On cherche l'asset qui se termine par .exe
    if (json['assets'] != null) {
      final assets = json['assets'] as List;
      for (var asset in assets) {
        final downloadUrl = asset['browser_download_url'] as String?;
        if (downloadUrl != null && downloadUrl.endsWith('.exe')) {
          url = downloadUrl;
          break; // Prend le premier .exe trouvé
        }
      }
    }

    return GithubRelease(
      tagName: json['tag_name'] ?? '',
      body: json['body'] ?? '',
      downloadUrl: url,
    );
  }

  // Retourne la version sémantique pure sans le "v" (ex: "v1.0.0" -> "1.0.0")
  String get semanticVersion {
    if (tagName.toLowerCase().startsWith('v')) {
      return tagName.substring(1);
    }
    return tagName;
  }
}
