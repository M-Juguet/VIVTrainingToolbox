import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'workspace_model.dart';

class WorkspaceState {
  final List<Workspace> workspaces;
  final String? activeWorkspaceId;
  final bool hasSkippedSetup;
  final bool isLoaded;

  WorkspaceState({
    this.workspaces = const [],
    this.activeWorkspaceId,
    this.hasSkippedSetup = false,
    this.isLoaded = false,
  });

  Workspace? get activeWorkspace {
    if (activeWorkspaceId == null) return null;
    try {
      return workspaces.firstWhere((w) => w.id == activeWorkspaceId);
    } catch (_) {
      return null;
    }
  }

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    String? activeWorkspaceId,
    bool? hasSkippedSetup,
    bool? isLoaded,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      activeWorkspaceId: activeWorkspaceId ?? this.activeWorkspaceId,
      hasSkippedSetup: hasSkippedSetup ?? this.hasSkippedSetup,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

final workspaceProvider = NotifierProvider<WorkspaceNotifier, WorkspaceState>(() {
  return WorkspaceNotifier();
});

class WorkspaceNotifier extends Notifier<WorkspaceState> {
  static const _workspacesKey = 'viv_workspaces';
  static const _activeKey = 'viv_active_workspace';
  static const _skippedKey = 'viv_skipped_setup';

  @override
  WorkspaceState build() {
    // Initial state is not loaded
    _loadState();
    return WorkspaceState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    final workspacesJson = prefs.getStringList(_workspacesKey) ?? [];
    final workspaces = workspacesJson.map((w) => Workspace.fromJson(w)).toList();
    
    final activeId = prefs.getString(_activeKey);
    final skipped = prefs.getBool(_skippedKey) ?? false;

    state = WorkspaceState(
      workspaces: workspaces,
      activeWorkspaceId: activeId,
      hasSkippedSetup: skipped,
      isLoaded: true,
    );
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final workspacesJson = state.workspaces.map((w) => w.toJson()).toList();
    await prefs.setStringList(_workspacesKey, workspacesJson);
    
    if (state.activeWorkspaceId != null) {
      await prefs.setString(_activeKey, state.activeWorkspaceId!);
    } else {
      await prefs.remove(_activeKey);
    }
    
    await prefs.setBool(_skippedKey, state.hasSkippedSetup);
  }

  Future<Workspace> addWorkspace(String name, String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final registryFile = File(path.join(dir.path, 'registry.json'));
    if (!await registryFile.exists()) {
      await registryFile.writeAsString('[]');
    }

    final newWorkspace = Workspace(
      id: const Uuid().v4(),
      name: name,
      path: dirPath,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      workspaces: [...state.workspaces, newWorkspace],
      activeWorkspaceId: newWorkspace.id,
      hasSkippedSetup: false,
    );
    await _saveState();
    return newWorkspace;
  }

  Future<void> setActiveWorkspace(String id) async {
    state = state.copyWith(activeWorkspaceId: id);
    await _saveState();
  }

  Future<void> removeWorkspace(String id) async {
    final newWorkspaces = state.workspaces.where((w) => w.id != id).toList();
    String? newActiveId = state.activeWorkspaceId;
    if (newActiveId == id) {
      newActiveId = newWorkspaces.isNotEmpty ? newWorkspaces.first.id : null;
    }
    state = state.copyWith(
      workspaces: newWorkspaces,
      activeWorkspaceId: newActiveId,
    );
    await _saveState();
  }

  Future<void> skipSetup() async {
    state = state.copyWith(hasSkippedSetup: true);
    await _saveState();
  }

  Future<bool> checkActiveWorkspaceExists() async {
    final active = state.activeWorkspace;
    if (active == null) return false;
    
    final dir = Directory(active.path);
    if (!await dir.exists()) return false;
    
    final registryFile = File(path.join(active.path, 'registry.json'));
    return await registryFile.exists();
  }

  Future<void> repairActiveWorkspace() async {
    final active = state.activeWorkspace;
    if (active == null) return;
    
    final dir = Directory(active.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final registryFile = File(path.join(active.path, 'registry.json'));
    if (!await registryFile.exists()) {
      await registryFile.writeAsString('[]');
    }
  }
}
