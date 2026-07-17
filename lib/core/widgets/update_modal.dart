import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../storage/update_provider.dart';
import '../theme/viv_colors.dart';
import '../theme/viv_spacing.dart';
import '../theme/viv_typography.dart';

class UpdateModal extends ConsumerStatefulWidget {
  const UpdateModal({super.key});

  @override
  ConsumerState<UpdateModal> createState() => _UpdateModalState();
}

class _UpdateModalState extends ConsumerState<UpdateModal> {
  bool _ignoreVersion = false;

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProvider);
    final release = updateState.release;

    if (release == null) return const SizedBox.shrink();

    final isDownloading = updateState.status == UpdateStatus.downloading;
    final isReady = updateState.status == UpdateStatus.readyToInstall;
    final isError = updateState.status == UpdateStatus.error;

    return Dialog(
      backgroundColor: VivColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VivSpacing.radiusLg),
        side: const BorderSide(color: VivColors.gray200, width: 1),
      ),
      elevation: 24,
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(VivSpacing.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VivColors.lime.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.downloadCloud,
                    color: VivColors.limeDeep,
                    size: 24,
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: Text(
                    'Mise à jour disponible',
                    style: VivTypography.h3.copyWith(
                      color: VivColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VivSpacing.space5),
            
            // Version Description
            Text(
              'Une nouvelle version ${release.tagName} est prête. Vous utilisez actuellement la version ${updateState.localVersion ?? "..."}.',
              style: VivTypography.body.copyWith(
                color: VivColors.ink700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: VivSpacing.space4),

            // Release Notes (Markdown list)
            Text(
              'Notes de version :',
              style: VivTypography.small.copyWith(
                fontWeight: FontWeight.bold,
                color: VivColors.gray500,
              ),
            ),
            const SizedBox(height: VivSpacing.space2),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: VivColors.offWhite,
                borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
                border: Border.all(color: VivColors.gray200),
              ),
              clipBehavior: Clip.hardEdge,
              child: Markdown(
                data: release.body.isEmpty ? "*Aucune description fournie pour cette version.*" : release.body,
                styleSheet: MarkdownStyleSheet(
                  p: VivTypography.body.copyWith(color: VivColors.ink, fontSize: 14),
                  h1: VivTypography.h4.copyWith(color: VivColors.black, fontSize: 16),
                  h2: VivTypography.h4.copyWith(color: VivColors.black, fontSize: 15),
                  listBullet: VivTypography.body.copyWith(color: VivColors.ink, fontSize: 14),
                  strong: const TextStyle(fontWeight: FontWeight.bold, color: VivColors.black),
                ),
              ),
            ),
            const SizedBox(height: VivSpacing.space4),
            
            // Error Display
            if (isError)
              Padding(
                padding: const EdgeInsets.only(bottom: VivSpacing.space3),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        updateState.errorMessage ?? 'Une erreur est survenue lors de la mise à jour.',
                        style: VivTypography.small.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            // Download Status / Checkbox Options
            if (isDownloading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Téléchargement en cours...',
                    style: VivTypography.small.copyWith(color: VivColors.gray500, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${(updateState.progress * 100).toStringAsFixed(0)}%',
                    style: VivTypography.small.copyWith(color: VivColors.limeDeep, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: VivSpacing.space2),
              ClipRRect(
                borderRadius: BorderRadius.circular(VivSpacing.radiusSm),
                child: LinearProgressIndicator(
                  value: updateState.progress,
                  minHeight: 6,
                  backgroundColor: VivColors.gray200,
                  valueColor: const AlwaysStoppedAnimation<Color>(VivColors.limeDeep),
                ),
              ),
            ] else if (isReady) ...[
              Row(
                children: [
                  const Icon(LucideIcons.checkCircle2, color: VivColors.limeDeep, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Téléchargement complété. Lancement de l\'installeur...',
                    style: VivTypography.small.copyWith(color: VivColors.limeDeep, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ] else ...[
              // Option to ignore version
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _ignoreVersion,
                      activeColor: VivColors.black,
                      checkColor: VivColors.lime,
                      onChanged: (val) {
                        setState(() => _ignoreVersion = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: VivSpacing.space2),
                  Text(
                    'Ignorer cette version',
                    style: VivTypography.small.copyWith(
                      color: VivColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: VivSpacing.space5),
            
            // Buttons Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDownloading && !isReady)
                  TextButton(
                    onPressed: () {
                      if (_ignoreVersion) {
                        ref.read(updateProvider.notifier).ignoreVersion(release.semanticVersion);
                      }
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: VivColors.gray500,
                      padding: const EdgeInsets.symmetric(horizontal: VivSpacing.space4, vertical: VivSpacing.space3),
                    ),
                    child: Text(
                      'Plus tard',
                      style: VivTypography.small.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: VivSpacing.space3),
                if (!isDownloading && !isReady)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VivColors.black,
                      foregroundColor: VivColors.lime,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: VivSpacing.space5, vertical: VivSpacing.space3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
                      ),
                    ),
                    onPressed: () {
                      ref.read(updateProvider.notifier).downloadUpdate();
                    },
                    child: Text(
                      'Mettre à jour',
                      style: VivTypography.small.copyWith(fontWeight: FontWeight.bold, color: VivColors.lime),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
