import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart' hide LucideIcons;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/storage/workspace_provider.dart';
import '../../core/theme/viv_colors.dart';
import '../../core/theme/viv_spacing.dart';
import '../../core/theme/viv_typography.dart';

class WorkspaceMissingScreen extends ConsumerStatefulWidget {
  const WorkspaceMissingScreen({super.key});

  @override
  ConsumerState<WorkspaceMissingScreen> createState() => _WorkspaceMissingScreenState();
}

class _WorkspaceMissingScreenState extends ConsumerState<WorkspaceMissingScreen> {
  bool _isLoading = false;

  Future<void> _recreateFolder() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(workspaceProvider.notifier).repairActiveWorkspace();
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Erreur'),
            description: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // I will refactor to use a better method in the provider.
  Future<void> _unlink() async {
    final state = ref.read(workspaceProvider);
    final active = state.activeWorkspace;
    if (active != null) {
      await ref.read(workspaceProvider.notifier).removeWorkspace(active.id);
      if (mounted) {
        context.go('/dashboard'); // Router will redirect back to /setup if list is empty
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    final active = state.activeWorkspace;

    return Scaffold(
      backgroundColor: VivColors.offWhite,
      body: Column(
        children: [
          DragToMoveArea(
            child: Container(
              height: 40,
              width: double.infinity,
              color: Colors.transparent,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(VivSpacing.space8),
                decoration: BoxDecoration(
                  color: VivColors.paper,
                  borderRadius: BorderRadius.circular(VivSpacing.radiusLg),
                  border: Border.all(color: VivColors.gray200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.folderX, size: 48, color: Colors.red),
                    const SizedBox(height: VivSpacing.space6),
                    Text(
                      'Dossier introuvable',
                      style: VivTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VivSpacing.space4),
                    Text(
                      'Le dossier configuré pour l\'espace de travail "${active?.name}" n\'existe plus ou est inaccessible.\n\nChemin : ${active?.path}',
                      style: VivTypography.body.copyWith(color: VivColors.gray500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VivSpacing.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShadButton.outline(
                          onPressed: _unlink,
                          child: const Text('Supprimer l\'espace', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: VivSpacing.space3),
                        ShadButton(
                          onPressed: _isLoading ? null : _recreateFolder,
                          child: _isLoading 
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: VivColors.paper))
                              : const Text('Re-créer le dossier vide'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
