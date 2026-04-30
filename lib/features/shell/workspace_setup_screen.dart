import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart' hide LucideIcons;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/storage/workspace_provider.dart';
import '../../core/theme/viv_colors.dart';
import '../../core/theme/viv_spacing.dart';
import '../../core/theme/viv_typography.dart';

class WorkspaceSetupScreen extends ConsumerStatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  ConsumerState<WorkspaceSetupScreen> createState() => _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends ConsumerState<WorkspaceSetupScreen> {
  final _nameController = TextEditingController();
  String? _selectedPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    String? result = await FilePicker.getDirectoryPath(
      dialogTitle: 'Sélectionner le dossier de l\'espace de travail',
    );

    if (result != null) {
      setState(() {
        _selectedPath = result;
        if (_nameController.text.isEmpty) {
          _nameController.text = 'Mon Espace de Travail';
        }
      });
    }
  }

  Future<void> _save() async {
    if (_selectedPath == null || _nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      await ref.read(workspaceProvider.notifier).addWorkspace(
        _nameController.text, 
        _selectedPath!,
      );
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

  Future<void> _skip() async {
    await ref.read(workspaceProvider.notifier).skipSetup();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: VivColors.gray200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/viv-formation-noir.png',
                      height: 32,
                    ),
                    const SizedBox(height: VivSpacing.space8),
                    Text(
                      'Configuration de l\'espace de travail',
                      style: VivTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VivSpacing.space2),
                    Text(
                      'VIV Formation Toolbox a besoin d\'un dossier sur votre ordinateur pour sauvegarder les programmes et générer les PDF.',
                      style: VivTypography.body.copyWith(color: VivColors.gray500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VivSpacing.space8),
                    
                    // Path Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dossier de stockage', style: VivTypography.small.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: VivSpacing.space2),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: VivSpacing.space3,
                                  vertical: VivSpacing.space3,
                                ),
                                decoration: BoxDecoration(
                                  color: VivColors.gray100.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
                                  border: Border.all(color: VivColors.gray300),
                                ),
                                child: Text(
                                  _selectedPath ?? 'Aucun dossier sélectionné',
                                  style: TextStyle(
                                    color: _selectedPath == null ? VivColors.gray400 : VivColors.black,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: VivSpacing.space3),
                            ShadButton.outline(
                              onPressed: _pickFolder,
                              child: const Icon(LucideIcons.folderSearch, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: VivSpacing.space6),
                    
                    // Name Input
                    if (_selectedPath != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nom de l\'espace', style: VivTypography.small.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: VivSpacing.space2),
                          ShadInput(
                            controller: _nameController,
                            placeholder: const Text('ex: Mon Espace de Travail'),
                          ),
                        ],
                      ),
                      const SizedBox(height: VivSpacing.space8),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShadButton.ghost(
                          onPressed: _skip,
                          child: const Text('Ignorer pour le moment', style: TextStyle(color: VivColors.gray500)),
                        ),
                        ShadButton(
                          onPressed: (_selectedPath != null && _nameController.text.isNotEmpty && !_isLoading) 
                              ? _save 
                              : null,
                          child: _isLoading 
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: VivColors.paper))
                            : const Text('Créer l\'espace'),
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
