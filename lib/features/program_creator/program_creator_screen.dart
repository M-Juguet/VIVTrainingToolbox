import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/models/program.dart';
import '../../core/services/pdf_service.dart';
import '../../core/theme/viv_colors.dart';
import '../../core/theme/viv_spacing.dart';
import '../../core/theme/viv_typography.dart';

class ProgramCreatorScreen extends StatefulWidget {
  const ProgramCreatorScreen({super.key});

  @override
  State<ProgramCreatorScreen> createState() => _ProgramCreatorScreenState();
}

class _ProgramCreatorScreenState extends State<ProgramCreatorScreen> {
  // Cat 1 : Informations Générales
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _versionController = TextEditingController(text: 'V1-${DateTime.now().year}');
  final _dateController = TextEditingController(text: '${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}');

  // Cat 2 : Modalités Pratiques
  String _selectedLevel = 'Intermédiaire';
  final _durationDaysController = TextEditingController(); // En jours
  final _priceController = TextEditingController(); // Montant total
  final List<String> _softwares = [];
  final _softwareInputController = TextEditingController();

  // Cat 3 : Cadrage Pédagogique
  final _generalObjectiveController = TextEditingController();
  final List<String> _audience = [];
  final _audienceInputController = TextEditingController();
  final List<String> _prerequisites = [];
  final _prerequisitesInputController = TextEditingController();
  final List<String> _pedagogicalObjectives = [];
  final _pedagogicalObjectivesInputController = TextEditingController();
  final List<String> _targetedSkills = [];
  final _targetedSkillsInputController = TextEditingController();

  // Cat 4 : Programme Détaillé
  final List<_ModuleState> _modules = [];

  // Cat 5 : Modalités Techniques & Évaluation
  final List<String> _technicalMeans = [];
  final _technicalMeansInputController = TextEditingController();
  final _evaluationModalitiesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _versionController.dispose();
    _dateController.dispose();
    _durationDaysController.dispose();
    _priceController.dispose();
    _softwareInputController.dispose();
    _generalObjectiveController.dispose();
    _audienceInputController.dispose();
    _prerequisitesInputController.dispose();
    _pedagogicalObjectivesInputController.dispose();
    _targetedSkillsInputController.dispose();
    _technicalMeansInputController.dispose();
    _evaluationModalitiesController.dispose();
    for (var m in _modules) {
      m.dispose();
    }
    super.dispose();
  }

  Widget _buildSectionHeader(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VivSpacing.space4, top: VivSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VivTypography.h3.copyWith(color: VivColors.black)),
          const SizedBox(height: VivSpacing.space1),
          Text(description, style: VivTypography.body.copyWith(color: VivColors.gray500)),
          const SizedBox(height: VivSpacing.space2),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDynamicList(
    String label, 
    List<String> items, 
    TextEditingController controller, 
    VoidCallback onAdd, 
    Function(int) onRemove
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: VivSpacing.space2),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: VivSpacing.space2),
            child: Wrap(
              spacing: VivSpacing.space2,
              runSpacing: VivSpacing.space2,
              children: items.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                  onDeleted: () => onRemove(entry.key),
                  deleteIcon: const Icon(LucideIcons.x, size: 14),
                  backgroundColor: VivColors.gray100,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ShadInput(
                controller: controller,
                placeholder: const Text('Ajouter un élément...'),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: VivSpacing.space2),
            ShadButton.outline(
              onPressed: onAdd,
              child: const Icon(LucideIcons.plus, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Création de programme', style: VivTypography.h2),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: VivSpacing.space4),
            child: ShadButton(
              onPressed: () async {
                final durationDays = _durationDaysController.text.trim();
                final durationHours = (int.tryParse(durationDays) ?? 0) * 7;
                final formattedDuration = '$durationHours h. ($durationDays jours)';

                final program = ProgramModel(
                  title: _titleController.text.trim(),
                  subtitle: _subtitleController.text.trim().isEmpty ? null : _subtitleController.text.trim(),
                  version: _versionController.text.trim(),
                  date: _dateController.text.trim(),
                  level: _selectedLevel,
                  duration: formattedDuration,
                  interPrice: '${_priceController.text.trim()}€ HT/pers*',
                  software: _softwares,
                  generalObjective: _generalObjectiveController.text.trim(),
                  audience: _audience,
                  prerequisites: _prerequisites,
                  pedagogicalObjectives: _pedagogicalObjectives,
                  targetedSkills: _targetedSkills,
                  modules: _modules.map((m) => ProgramModule(
                    title: m.titleController.text.trim(),
                    items: m.items,
                  )).toList(),
                  technicalMeans: _technicalMeans,
                  evaluationModalities: _evaluationModalitiesController.text.trim(),
                );

                final pdfService = PdfService();
                final pdfData = await pdfService.generateProgramPdf(program);
                
                final String? outputFile = await FilePicker.saveFile(
                  dialogTitle: 'Enregistrer le programme PDF',
                  fileName: '${_titleController.text.replaceAll(' ', '_').toLowerCase()}.pdf',
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                
                if (outputFile != null) {
                  final file = File(outputFile);
                  await file.writeAsBytes(pdfData);
                  if (context.mounted) {
                    ShadToaster.of(context).show(
                      const ShadToast(description: Text('Programme enregistré avec succès !')),
                    );
                  }
                }
              },
              child: const Text('Générer le PDF'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(VivSpacing.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Informations Générales
            _buildSectionHeader(
              '1. Informations Générales', 
              'Définissez l\'identité globale de la formation.'
            ),
            Row(
              children: [
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Titre de la formation'),
                    controller: _titleController,
                    placeholder: const Text('Ex: Formation Flutter Expert'),
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Sous-titre (Optionnel)'),
                    controller: _subtitleController,
                    placeholder: const Text('Ex: Maîtriser le développement multi-plateforme'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VivSpacing.space4),
            Row(
              children: [
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Version du document'),
                    controller: _versionController,
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Date de mise à jour'),
                    controller: _dateController,
                  ),
                ),
              ],
            ),

            // 2. Modalités Pratiques
            _buildSectionHeader(
              '2. Modalités Pratiques', 
              'Paramètres de durée, niveau, tarifs et outils.'
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Niveau', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: VivSpacing.space2),
                      ShadSelect<String>(
                        placeholder: const Text('Sélectionner le niveau'),
                        initialValue: _selectedLevel,
                        onChanged: (v) => setState(() => _selectedLevel = v ?? _selectedLevel),
                        options: ['Débutant', 'Intermédiaire', 'Avancé']
                            .map((level) => ShadOption(value: level, child: Text(level)))
                            .toList(),
                        selectedOptionBuilder: (context, value) => Text(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Durée (en jours)'),
                    controller: _durationDaysController,
                    keyboardType: TextInputType.number,
                    placeholder: const Text('Ex: 3'),
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Tarif total (HT)'),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    placeholder: const Text('Ex: 1500'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VivSpacing.space4),
            _buildDynamicList(
              'Logiciels abordés', 
              _softwares, 
              _softwareInputController, 
              () {
                if (_softwareInputController.text.trim().isNotEmpty) {
                  setState(() {
                    _softwares.add(_softwareInputController.text.trim());
                    _softwareInputController.clear();
                  });
                }
              }, 
              (index) => setState(() => _softwares.removeAt(index))
            ),

            // 3. Cadrage Pédagogique
            _buildSectionHeader(
              '3. Cadrage Pédagogique', 
              'Objectifs, compétences et public cible.'
            ),
            ShadInputFormField(
              label: const Text('Objectif général de la formation'),
              controller: _generalObjectiveController,
              maxLines: 4,
              placeholder: const Text('Cette formation permet de...'),
            ),
            const SizedBox(height: VivSpacing.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDynamicList(
                    'Public visé (Pour qui)', 
                    _audience, 
                    _audienceInputController, 
                    () {
                      if (_audienceInputController.text.trim().isNotEmpty) {
                        setState(() {
                          _audience.add(_audienceInputController.text.trim());
                          _audienceInputController.clear();
                        });
                      }
                    }, 
                    (index) => setState(() => _audience.removeAt(index))
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: _buildDynamicList(
                    'Prérequis', 
                    _prerequisites, 
                    _prerequisitesInputController, 
                    () {
                      if (_prerequisitesInputController.text.trim().isNotEmpty) {
                        setState(() {
                          _prerequisites.add(_prerequisitesInputController.text.trim());
                          _prerequisitesInputController.clear();
                        });
                      }
                    }, 
                    (index) => setState(() => _prerequisites.removeAt(index))
                  ),
                ),
              ],
            ),
            const SizedBox(height: VivSpacing.space4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDynamicList(
                    'Objectifs pédagogiques', 
                    _pedagogicalObjectives, 
                    _pedagogicalObjectivesInputController, 
                    () {
                      if (_pedagogicalObjectivesInputController.text.trim().isNotEmpty) {
                        setState(() {
                          _pedagogicalObjectives.add(_pedagogicalObjectivesInputController.text.trim());
                          _pedagogicalObjectivesInputController.clear();
                        });
                      }
                    }, 
                    (index) => setState(() => _pedagogicalObjectives.removeAt(index))
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: _buildDynamicList(
                    'Compétences visées', 
                    _targetedSkills, 
                    _targetedSkillsInputController, 
                    () {
                      if (_targetedSkillsInputController.text.trim().isNotEmpty) {
                        setState(() {
                          _targetedSkills.add(_targetedSkillsInputController.text.trim());
                          _targetedSkillsInputController.clear();
                        });
                      }
                    }, 
                    (index) => setState(() => _targetedSkills.removeAt(index))
                  ),
                ),
              ],
            ),
            const SizedBox(height: VivSpacing.space8),

            // 4. Programme Détaillé
            _buildSectionHeader(
              '4. Programme Détaillé', 
              'Définissez les modules de formation et les notions abordées.'
            ),
            if (_modules.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _modules.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _modules.removeAt(oldIndex);
                    _modules.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final module = _modules[index];
                  return Card(
                    key: module.key,
                    margin: const EdgeInsets.only(bottom: VivSpacing.space4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: VivColors.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(VivSpacing.space4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.gripVertical, size: 20, color: VivColors.gray400),
                              const SizedBox(width: VivSpacing.space2),
                              Expanded(
                                child: ShadInputFormField(
                                  label: Text('Titre du module ${index + 1}'),
                                  controller: module.titleController,
                                  placeholder: const Text('Ex: Module 1 : Architecture Profonde'),
                                ),
                              ),
                              const SizedBox(width: VivSpacing.space2),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    module.dispose();
                                    _modules.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: VivSpacing.space4),
                          Padding(
                            padding: const EdgeInsets.only(left: VivSpacing.space6),
                            child: _buildDynamicList(
                              'Notions abordées',
                              module.items,
                              module.itemInputController,
                              () {
                                if (module.itemInputController.text.trim().isNotEmpty) {
                                  setState(() {
                                    module.items.add(module.itemInputController.text.trim());
                                    module.itemInputController.clear();
                                  });
                                }
                              },
                              (i) => setState(() => module.items.removeAt(i)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            Padding(
              padding: const EdgeInsets.only(top: VivSpacing.space2),
              child: ShadButton.outline(
                onPressed: () {
                  setState(() {
                    _modules.add(_ModuleState(
                      titleController: TextEditingController(),
                      items: [],
                      itemInputController: TextEditingController(),
                    ));
                  });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 16),
                    SizedBox(width: 8),
                    Text('Ajouter un module'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: VivSpacing.space8),

            // 5. Modalités Techniques & Évaluation
            _buildSectionHeader(
              '5. Modalités Techniques & Évaluation', 
              'Précisez les moyens mis en œuvre et le mode d\'évaluation.'
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDynamicList(
                    'Moyens techniques', 
                    _technicalMeans, 
                    _technicalMeansInputController, 
                    () {
                      if (_technicalMeansInputController.text.trim().isNotEmpty) {
                        setState(() {
                          _technicalMeans.add(_technicalMeansInputController.text.trim());
                          _technicalMeansInputController.clear();
                        });
                      }
                    }, 
                    (index) => setState(() => _technicalMeans.removeAt(index))
                  ),
                ),
                const SizedBox(width: VivSpacing.space4),
                Expanded(
                  child: ShadInputFormField(
                    label: const Text('Modalités d\'évaluation'),
                    controller: _evaluationModalitiesController,
                    maxLines: 4,
                    placeholder: const Text('Ex: QCM de fin de formation et projet pratique.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: VivSpacing.space8),
          ],
        ),
      ),
    );
  }
}

class _ModuleState {
  final Key key;
  final TextEditingController titleController;
  final List<String> items;
  final TextEditingController itemInputController;

  _ModuleState({
    Key? key,
    required this.titleController,
    required this.items,
    required this.itemInputController,
  }) : key = key ?? UniqueKey();

  void dispose() {
    titleController.dispose();
    itemInputController.dispose();
  }
}
