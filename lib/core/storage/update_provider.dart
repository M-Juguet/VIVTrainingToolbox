import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_release.dart';
import '../services/update_service.dart';

enum UpdateStatus {
  initial,
  checking,
  upToDate,
  available,
  downloading,
  readyToInstall,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final GithubRelease? release;
  final String? localVersion;
  final double progress;
  final String? localFilePath;
  final String? errorMessage;

  UpdateState({
    this.status = UpdateStatus.initial,
    this.release,
    this.localVersion,
    this.progress = 0.0,
    this.localFilePath,
    this.errorMessage,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    GithubRelease? release,
    String? localVersion,
    double? progress,
    String? localFilePath,
    String? errorMessage,
  }) {
    return UpdateState(
      status: status ?? this.status,
      release: release ?? this.release,
      localVersion: localVersion ?? this.localVersion,
      progress: progress ?? this.progress,
      localFilePath: localFilePath ?? this.localFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Configuré spécifiquement pour le dépôt VIV Formation Toolbox
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(
    owner: 'M-Juguet',
    repo: 'VIVTrainingToolbox',
  );
});

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(() {
  return UpdateNotifier();
});

class UpdateNotifier extends Notifier<UpdateState> {
  static const String _ignoredVersionKey = 'ignored_update_version';

  @override
  UpdateState build() {
    return UpdateState();
  }

  Future<void> checkForUpdates({bool silent = false}) async {
    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    try {
      final updateService = ref.read(updateServiceProvider);
      
      // 1. Récupérer la version locale de l'application
      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;
      state = state.copyWith(localVersion: localVersion);

      // 2. Récupérer les informations de la release sur GitHub
      final release = await updateService.getLatestRelease();
      
      if (release == null) {
        state = state.copyWith(
          status: silent ? UpdateStatus.initial : UpdateStatus.error,
          errorMessage: "Impossible de récupérer les informations de mise à jour.",
        );
        return;
      }

      // 3. Comparaison de version sémantique
      final remoteVersion = release.semanticVersion;
      
      if (_isNewerVersion(localVersion, remoteVersion)) {
        // Vérifier si cette version spécifique a été configurée pour être ignorée
        final prefs = await SharedPreferences.getInstance();
        final ignoredVersion = prefs.getString(_ignoredVersionKey);

        if (silent && ignoredVersion == remoteVersion) {
          state = state.copyWith(status: UpdateStatus.initial);
        } else {
          state = state.copyWith(status: UpdateStatus.available, release: release);
        }
      } else {
        state = state.copyWith(status: UpdateStatus.upToDate);
      }
    } catch (e) {
      state = state.copyWith(
        status: silent ? UpdateStatus.initial : UpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> ignoreVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ignoredVersionKey, version);
    state = state.copyWith(status: UpdateStatus.initial);
  }

  Future<void> downloadUpdate() async {
    if (state.release == null || state.release!.downloadUrl.isEmpty) return;

    state = state.copyWith(status: UpdateStatus.downloading, progress: 0.0);

    final updateService = ref.read(updateServiceProvider);

    final localPath = await updateService.downloadUpdate(
      state.release!.downloadUrl,
      (count, total) {
        if (total != -1) {
          state = state.copyWith(progress: count / total);
        }
      },
    );

    if (localPath != null) {
      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        localFilePath: localPath,
        progress: 1.0,
      );
      // Installation immédiate et transparente suite au téléchargement
      await runInstaller();
    } else {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: "Échec du téléchargement de la mise à jour.",
      );
    }
  }

  Future<void> runInstaller() async {
    if (state.localFilePath == null) return;
    final updateService = ref.read(updateServiceProvider);
    await updateService.runInstaller(state.localFilePath!);
  }

  // Comparaison sémantique stricte de version
  bool _isNewerVersion(String local, String remote) {
    final localParts = local.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remoteParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final l = i < localParts.length ? localParts[i] : 0;
      final r = i < remoteParts.length ? remoteParts[i] : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }
}

final updateDiagnosticProvider = NotifierProvider<UpdateDiagnosticNotifier, AsyncValue<Map<String, dynamic>?>>(() {
  return UpdateDiagnosticNotifier();
});

class UpdateDiagnosticNotifier extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncValue.data(null); // Aucun diagnostic lancé par défaut
  }

  Future<void> runDiagnostic() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(updateServiceProvider);
      final result = await service.diagnoseConnection();
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
