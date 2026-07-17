import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/github_release.dart';

class UpdateService {
  final Dio _dio = Dio();
  final String owner;
  final String repo;

  // Récupération optionnelle d'un token d'accès via les variables d'environnement (--dart-define=GITHUB_TOKEN=...)
  static const String _githubToken = String.fromEnvironment('GITHUB_TOKEN');

  UpdateService({required this.owner, required this.repo}) {
    if (_githubToken.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $_githubToken';
    }
    _dio.options.headers['Accept'] = 'application/vnd.github.v3+json';
  }

  /// Vérifie la dernière version disponible sur GitHub
  Future<GithubRelease?> getLatestRelease() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$owner/$repo/releases/latest',
      );
      if (response.statusCode == 200) {
        return GithubRelease.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la release : $e');
    }
    return null;
  }

  /// Nettoie les anciens fichiers d'installation dans le répertoire temporaire
  Future<void> cleanOldInstallers() async {
    try {
      final tempDir = Directory.systemTemp;
      final files = tempDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.exe')) {
          try {
            await file.delete();
          } catch (_) {
            // Fichier potentiellement en cours d'utilisation
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des installeurs : $e');
    }
  }

  /// Télécharge la mise à jour et renvoie le chemin du fichier local
  Future<String?> downloadUpdate(
      String url, void Function(int count, int total) onReceiveProgress) async {
    try {
      // Nettoyage préalable
      await cleanOldInstallers();

      final tempDir = Directory.systemTemp;
      final fileName = url.split('/').last.split('?').first;
      // On s'assure d'avoir un nom valide
      final safeFileName = fileName.isEmpty ? 'update.exe' : fileName;
      final savePath = '${tempDir.path}\\$safeFileName';

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {
            'Accept': 'application/octet-stream',
            if (_githubToken.isNotEmpty) 'Authorization': 'Bearer $_githubToken',
          },
        ),
      );

      return savePath;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement : $e');
      return null;
    }
  }

  /// Lance l'installeur en mode détaché et ferme l'application courante
  Future<void> runInstaller(String filePath) async {
    try {
      await Process.start(
        filePath,
        ['/SILENT'], // Argument InnoSetup pour l'installation silencieuse
        mode: ProcessStartMode.detached,
      );
      // On ferme l'application Flutter pour libérer les fichiers afin qu'InnoSetup puisse les écraser
      exit(0);
    } catch (e) {
      debugPrint('Erreur lors du lancement de l\'installeur : $e');
      rethrow;
    }
  }

  /// Diagnostique la connexion à l'API GitHub et renvoie un rapport détaillé
  Future<Map<String, dynamic>> diagnoseConnection() async {
    final Map<String, dynamic> report = {
      'targetUrl': 'https://api.github.com/repos/$owner/$repo/releases/latest',
      'hasToken': _githubToken.isNotEmpty,
      'statusCode': null,
      'error': null,
      'releaseFound': false,
      'tagName': null,
      'hasExeAsset': false,
      'downloadUrl': null,
    };

    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$owner/$repo/releases/latest',
      );
      report['statusCode'] = response.statusCode;
      if (response.statusCode == 200) {
        report['releaseFound'] = true;
        final data = response.data;
        report['tagName'] = data['tag_name'];
        
        String url = '';
        if (data['assets'] != null) {
          final assets = data['assets'] as List;
          for (var asset in assets) {
            final downloadUrl = asset['browser_download_url'] as String?;
            if (downloadUrl != null && downloadUrl.endsWith('.exe')) {
              url = downloadUrl;
              break;
            }
          }
        }
        if (url.isNotEmpty) {
          report['hasExeAsset'] = true;
          report['downloadUrl'] = url;
        }
      }
    } on DioException catch (e) {
      report['statusCode'] = e.response?.statusCode;
      report['error'] = 'DioException: ${e.message}\nType: ${e.type}\nResponse: ${e.response?.data}';
    } catch (e) {
      report['error'] = e.toString();
    }
    return report;
  }
}
