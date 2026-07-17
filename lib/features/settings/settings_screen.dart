import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/viv_colors.dart';
import '../../core/theme/viv_spacing.dart';
import '../../core/theme/viv_typography.dart';
import '../../core/storage/settings_provider.dart';
import '../../core/storage/workspace_provider.dart';
import '../../core/storage/update_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final updateState = ref.watch(updateProvider);
    final localVersion = updateState.localVersion ?? '0.1.0';
    final diagnosticState = ref.watch(updateDiagnosticProvider);

    ref.listen<UpdateState>(updateProvider, (previous, next) {
      if (previous?.status == UpdateStatus.checking) {
        if (next.status == UpdateStatus.upToDate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous disposez déjà de la dernière version.'),
              backgroundColor: VivColors.limeDeep,
            ),
          );
        } else if (next.status == UpdateStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Erreur de vérification.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(VivSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Application Settings
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
          
          // 2. Workspaces Settings
          _buildSectionHeader('Espaces de travail', LucideIcons.folder),
          const SizedBox(height: VivSpacing.space4),
          _buildWorkspacesSection(context, ref),
          const SizedBox(height: VivSpacing.space8),

          // 3. Update Settings
          _buildSectionHeader('Mise à jour', LucideIcons.refreshCw),
          const SizedBox(height: VivSpacing.space4),
          _buildCard([
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rechercher une mise à jour', style: VivTypography.small.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      updateState.status == UpdateStatus.checking
                          ? 'Vérification en cours sur GitHub...'
                          : 'Vérifier manuellement si une nouvelle version est disponible.',
                      style: VivTypography.small.copyWith(color: VivColors.gray500),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VivColors.black,
                    foregroundColor: VivColors.lime,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
                    ),
                  ),
                  onPressed: updateState.status == UpdateStatus.checking
                      ? null
                      : () => ref.read(updateProvider.notifier).checkForUpdates(silent: false),
                  child: Text(
                    updateState.status == UpdateStatus.checking ? 'Recherche...' : 'Vérifier',
                    style: VivTypography.small.copyWith(fontWeight: FontWeight.bold, color: VivColors.lime),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: VivSpacing.space8),

          // 4. Connection Diagnostic Settings
          _buildSectionHeader('Diagnostic de connexion', LucideIcons.activity),
          const SizedBox(height: VivSpacing.space4),
          _buildCard([
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tester la communication GitHub', style: VivTypography.small.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      'Vérifier la connectivité avec l\'API de release pour diagnostiquer les mises à jour.',
                      style: VivTypography.small.copyWith(color: VivColors.gray500),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VivColors.black,
                    foregroundColor: VivColors.lime,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
                    ),
                  ),
                  onPressed: diagnosticState.isLoading
                      ? null
                      : () => ref.read(updateDiagnosticProvider.notifier).runDiagnostic(),
                  child: Text(
                    diagnosticState.isLoading ? 'Diagnostic...' : 'Lancer le test',
                    style: VivTypography.small.copyWith(fontWeight: FontWeight.bold, color: VivColors.lime),
                  ),
                ),
              ],
            ),
            if (diagnosticState.hasValue && diagnosticState.value != null) ...[
              const Divider(height: VivSpacing.space6, color: VivColors.gray100),
              _buildDiagnosticResult(diagnosticState.value!),
            ] else if (diagnosticState.hasError) ...[
              const Divider(height: VivSpacing.space6, color: VivColors.gray100),
              Text(
                'Erreur lors du test : ${diagnosticState.error}',
                style: VivTypography.small.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ]),
          const SizedBox(height: VivSpacing.space8),

          // 5. About Section Settings
          _buildSectionHeader('À propos', LucideIcons.info),
          const SizedBox(height: VivSpacing.space4),
          _buildCard([
            _buildInfoRow('Nom de l\'application', 'VIV Formation Toolbox'),
            const Divider(height: VivSpacing.space6, color: VivColors.gray100),
            _buildInfoRow('Version de l\'application', localVersion),
            const Divider(height: VivSpacing.space6, color: VivColors.gray100),
            _buildInfoRow('Copyright', '© 2026 VIV. Tous droits réservés.'),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: VivTypography.small.copyWith(
            fontWeight: FontWeight.w500,
            color: VivColors.gray500,
          ),
        ),
        Text(
          value,
          style: VivTypography.small.copyWith(
            fontWeight: FontWeight.bold,
            color: VivColors.black,
          ),
        ),
      ],
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

  Widget _buildDiagnosticResult(Map<String, dynamic> report) {
    final hasError = report['error'] != null || report['statusCode'] != 200 || !report['releaseFound'] || !report['hasExeAsset'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasError ? 'Rapport : Problème détecté' : 'Rapport : Connexion établie avec succès',
          style: VivTypography.small.copyWith(
            fontWeight: FontWeight.bold,
            color: hasError ? Colors.redAccent : VivColors.green600,
          ),
        ),
        const SizedBox(height: VivSpacing.space4),
        _buildDiagnosticRow('URL ciblée', report['targetUrl'] ?? ''),
        const SizedBox(height: VivSpacing.space2),
        _buildDiagnosticRow('Token d\'accès configuré', report['hasToken'] == true ? 'Oui' : 'Non'),
        const SizedBox(height: VivSpacing.space2),
        _buildDiagnosticRow(
          'Code HTTP retourné',
          report['statusCode'] != null ? '${report['statusCode']}' : 'Aucun (Échec réseau)',
          color: report['statusCode'] == 200 ? VivColors.green600 : Colors.redAccent,
        ),
        const SizedBox(height: VivSpacing.space2),
        _buildDiagnosticRow('Release GitHub trouvée', report['releaseFound'] == true ? 'Oui (tag: ${report['tagName']})' : 'Non'),
        const SizedBox(height: VivSpacing.space2),
        _buildDiagnosticRow('Installeur (.exe) détecté', report['hasExeAsset'] == true ? 'Oui' : 'Non'),
        if (report['error'] != null) ...[
          const SizedBox(height: VivSpacing.space4),
          Text(
            'Message d\'erreur technique :',
            style: VivTypography.small.copyWith(fontWeight: FontWeight.bold, color: VivColors.gray500),
          ),
          const SizedBox(height: VivSpacing.space2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(VivSpacing.space3),
            decoration: BoxDecoration(
              color: VivColors.gray100,
              borderRadius: BorderRadius.circular(VivSpacing.radiusSm),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                '${report['error']}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiagnosticRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: VivTypography.small.copyWith(color: VivColors.gray500, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: VivTypography.small.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? VivColors.black,
          ),
        ),
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
