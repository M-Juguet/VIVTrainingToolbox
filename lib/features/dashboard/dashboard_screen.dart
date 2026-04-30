import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:printing/printing.dart';
import '../../core/models/program.dart';
import '../../core/services/pdf_service.dart';
import '../../core/theme/viv_colors.dart';
import '../../core/theme/viv_spacing.dart';
import '../../core/theme/viv_typography.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VivSpacing.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: VivTypography.h2,
          ),
          const SizedBox(height: VivSpacing.space2),
          Text(
            'Gérez vos programmes de formation et vos exports.',
            style: VivTypography.body.copyWith(color: VivColors.gray500),
          ),
          const SizedBox(height: VivSpacing.space8),
          
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: VivSpacing.space4,
      runSpacing: VivSpacing.space4,
      children: [
        _buildActionCard(
          context,
          title: 'Nouveau Programme',
          description: 'Créer un programme de formation de zéro ou avec l\'aide de Gemini.',
          icon: LucideIcons.plus,
          onTap: () {
            context.go('/create');
          },
        ),
        _buildActionCard(
          context,
          title: 'Test de Génération PDF',
          description: 'Générer un PDF de démonstration pour valider la mise en page.',
          icon: LucideIcons.fileText,
          onTap: () async {
            final pdfService = PdfService();
            final testProgram = ProgramModel(
              title: 'Formation Flutter Expert',
              subtitle: 'Maîtriser le développement multi-plateforme',
              level: 'Avancé',
              duration: '21 h. (3 jours)',
              software: ['Flutter SDK', 'Dart', 'VS Code'],
              interPrice: '1500€ HT/pers*',
              generalObjective: 'Cette formation permet de maîtriser les concepts avancés de Flutter, incluant la gestion d\'état complexe et l\'optimisation des performances.',
              audience: ['Développeurs Mobile', 'Architectes Logiciels'],
              prerequisites: ['Maîtriser les bases de Dart', 'Avoir déjà publié une application'],
              pedagogicalObjectives: [
                'Comprendre l\'architecture interne de Flutter',
                'Maîtriser Riverpod et la gestion d\'état asynchrone',
                'Optimiser le rendu et réduire le poids des builds'
              ],
              targetedSkills: [
                'Concevoir des architectures Flutter scalables',
                'Debugger des problèmes de performance complexes',
                'Mettre en place une stratégie de tests automatisés'
              ],
              modules: [
                ProgramModule(
                  title: 'Module 1 : Architecture Profonde',
                  items: ['Widgets, Elements et RenderObjects', 'Le cycle de vie du framework', 'Patterns de navigation avancés'],
                ),
                ProgramModule(
                  title: 'Module 2 : State Management Pro',
                  items: ['Riverpod : Providers, Notifiers et AsyncValue', 'Gestion des effets de bord', 'Tests unitaires et de widgets'],
                ),
              ],
              technicalMeans: ['Connexion Fibre', 'Poste avec 16Go RAM'],
              evaluationModalities: 'QCM de fin de formation et projet pratique.',
              version: 'V1-FLUTTER-2025',
              date: '05/2025',
            );

            final pdfData = await pdfService.generateProgramPdf(testProgram);
            
            if (context.mounted) {
              await Printing.layoutPdf(
                onLayout: (format) => pdfData,
                name: 'test_program.pdf',
              );
            }
          },
        ),
        _buildActionCard(
          context,
          title: 'Enregistrer le PDF',
          description: 'Sauvegarder le programme directement sur votre ordinateur (sans passer par l\'impression).',
          icon: LucideIcons.save,
          onTap: () async {
            final pdfService = PdfService();
            final testProgram = ProgramModel(
              title: 'Formation Flutter Expert',
              subtitle: 'Maîtriser le développement multi-plateforme',
              level: 'Avancé',
              duration: '21 h. (3 jours)',
              software: ['Flutter SDK', 'Dart', 'VS Code'],
              interPrice: '1500€ HT/pers*',
              generalObjective: 'Cette formation permet de maîtriser les concepts avancés de Flutter, incluant la gestion d\'état complexe et l\'optimisation des performances.',
              audience: ['Développeurs Mobile', 'Architectes Logiciels'],
              prerequisites: ['Maîtriser les bases de Dart', 'Avoir déjà publié une application'],
              pedagogicalObjectives: [
                'Comprendre l\'architecture interne de Flutter',
                'Maîtriser Riverpod et la gestion d\'état asynchrone',
                'Optimiser le rendu et réduire le poids des builds'
              ],
              targetedSkills: [
                'Concevoir des architectures Flutter scalables',
                'Debugger des problèmes de performance complexes',
                'Mettre en place une stratégie de tests automatisés'
              ],
              modules: [
                ProgramModule(
                  title: 'Module 1 : Architecture Profonde',
                  items: ['Widgets, Elements et RenderObjects', 'Le cycle de vie du framework', 'Patterns de navigation avancés'],
                ),
                ProgramModule(
                  title: 'Module 2 : State Management Pro',
                  items: ['Riverpod : Providers, Notifiers et AsyncValue', 'Gestion des effets de bord', 'Tests unitaires et de widgets'],
                ),
              ],
              technicalMeans: ['Connexion Fibre', 'Poste avec 16Go RAM'],
              evaluationModalities: 'QCM de fin de formation et projet pratique.',
              version: 'V1-FLUTTER-2025',
              date: '05/2025',
            );

            final pdfData = await pdfService.generateProgramPdf(testProgram);
            
            final String? outputFile = await FilePicker.saveFile(
              dialogTitle: 'Enregistrer le programme PDF',
              fileName: 'programme-formation-test.pdf',
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );

            if (outputFile != null) {
              final file = File(outputFile);
              await file.writeAsBytes(pdfData);
              if (context.mounted) {
                ShadToaster.of(context).show(
                  const ShadToast(
                    description: Text('Le PDF a été enregistré avec succès !'),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(VivSpacing.space6),
          decoration: BoxDecoration(
            color: VivColors.paper,
            borderRadius: BorderRadius.circular(VivSpacing.radiusMd),
            border: Border.all(color: VivColors.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: VivColors.lime, size: 28),
              const SizedBox(height: VivSpacing.space4),
              Text(title, style: VivTypography.h4),
              const SizedBox(height: VivSpacing.space2),
              Text(
                description,
                style: VivTypography.small.copyWith(color: VivColors.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
