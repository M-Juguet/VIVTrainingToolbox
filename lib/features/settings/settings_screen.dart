import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';


import '../../core/theme/viv_colors.dart';
import '../../core/theme/viv_spacing.dart';
import '../../core/theme/viv_typography.dart';
import '../../core/storage/settings_provider.dart';
import '../../core/storage/workspace_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(VivSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Application', LucideIcons.monitor),
          const SizedBox(height: VivSpacing.space4),
          _buildCard([
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Afficher en plein écran', style: VivTypography.small.copyWith(fontWeight: FontWeight.bold)),
                    Text('Bascule l\'application en mode plein écran immersif.', style: VivTypography.small.copyWith(color: VivColors.gray500)),
                  ],
                ),
                ShadSwitch(
                  value: settings.isFullScreen,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setFullScreen(val),
                ),
              ],
            ),
          ]),
          const SizedBox(height: VivSpacing.space8),
          
          _buildSectionHeader('Espaces de travail', LucideIcons.folder),
          const SizedBox(height: VivSpacing.space4),
          _buildWorkspacesSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: VivColors.lime),
        const SizedBox(width: VivSpacing.space3),
        Text(title, style: VivTypography.h4.copyWith(color: VivColors.black)),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(VivSpacing.space6),
      decoration: BoxDecoration(
        color: VivColors.paper,
        borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
        border: Border.all(color: VivColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildWorkspacesSection(BuildContext context, WidgetRef ref) {
    final wsState = ref.watch(workspaceProvider);

    return _buildCard([
      if (wsState.workspaces.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: VivSpacing.space4),
          child: Text(
            'Aucun espace de travail configuré. Veuillez en ajouter un pour pouvoir utiliser les fonctionnalités de génération.',
            style: VivTypography.body.copyWith(color: VivColors.gray500),
          ),
        ),
      ...wsState.workspaces.map((w) {
        final isActive = w.id == wsState.activeWorkspaceId;
        return Padding(
          padding: const EdgeInsets.only(bottom: VivSpacing.space4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(w.name, style: VivTypography.small.copyWith(fontWeight: FontWeight.bold)),
                        if (isActive) ...[
                          const SizedBox(width: VivSpacing.space2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: VivColors.lime.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Actif', style: TextStyle(color: VivColors.lime, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(w.path, style: VivTypography.small.copyWith(color: VivColors.gray500), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isActive)
                    ShadButton.outline(
                      onPressed: () => ref.read(workspaceProvider.notifier).setActiveWorkspace(w.id),
                      child: const Text('Activer'),
                    ),
                  const SizedBox(width: VivSpacing.space2),
                  IconButton(
                    onPressed: () => ref.read(workspaceProvider.notifier).removeWorkspace(w.id),
                    icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      
      const SizedBox(height: VivSpacing.space2),
      ShadButton(
        onPressed: () {
          // Open setup screen to add a new workspace
          context.push('/setup');
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(LucideIcons.folderPlus, size: 16),
            ),
            Text('Ajouter un espace'),
          ],
        ),
      ),
    ]);
  }
}
