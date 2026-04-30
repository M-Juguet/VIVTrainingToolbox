import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/program.dart';

class PdfService {
  // Couleurs opaques calculées pour éviter la rastérisation et garantir le rendu "pixel-perfect"
  static const PdfColor tyrianPurple = PdfColor.fromInt(0xFF6C2D48);
  static const PdfColor pinkLavender = PdfColor.fromInt(0xFFDAA5BC);
  static const PdfColor borderSoft = PdfColor.fromInt(0xFFD5C8D0);
  static const PdfColor foreground = PdfColor.fromInt(0xFF252525);
  static const PdfColor mutedForeground = PdfColor.fromInt(0xFF8E8E8E);
  static const PdfColor footerBg = PdfColor.fromInt(0xFFFAF7FB);
  static const PdfColor footerBorder = PdfColor.fromInt(0xFFEEE7F0);
  static const PdfColor footerText = PdfColor.fromInt(0xFF777777);

  // Couleurs calculées par mélange (Alpha Blending sur Blanc ou Tyrian Purple)
  static const PdfColor pinkLavender5Opaque = PdfColor.fromInt(
    0xFFFDFBFC,
  ); // #DAA5BC @ 5% sur Blanc
  static const PdfColor white60OnTyrian = PdfColor.fromInt(
    0xFFC4ABB6,
  ); // Blanc @ 60% sur #6C2D48
  static const PdfColor border35OnTyrian = PdfColor.fromInt(
    0xFF9F7788,
  ); // Blanc @ 35% sur #6C2D48
  static const PdfColor subtitleOnGradient = PdfColor.fromInt(
    0xFFDAC3CD,
  ); // Blanc @ 60% sur mélange Header

  Future<Uint8List> generateProgramPdf(ProgramModel program) async {
    final pdf = pw.Document();

    final regularFont = await PdfGoogleFonts.interRegular();
    final mediumFont = await PdfGoogleFonts.interMedium();
    final semiBoldFont = await PdfGoogleFonts.interSemiBold();
    final boldFont = await PdfGoogleFonts.interBold();
    final materialIcons = await PdfGoogleFonts.materialIcons();

    final logoImage = await imageFromAssetBundle(
      'assets/images/viv-formation-couleur.png',
    );

    // Page 1
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (context) {
          return pw.Column(
            children: [
              _buildHeader(program, logoImage, semiBoldFont, regularFont),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(24, 15, 24, 12),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Sidebar
                      pw.Container(
                        width: 172.5,
                        child: _buildSidebar(
                          program,
                          boldFont,
                          regularFont,
                          mediumFont,
                          semiBoldFont,
                          materialIcons,
                        ),
                      ),
                      pw.SizedBox(width: 18),
                      // Main Content
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              'Objectif général de la formation',
                              boldFont,
                              fontSize: 9.75,
                              mb: 4.5,
                            ),
                            pw.Text(
                              program.generalObjective,
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 9,
                                color: foreground,
                              ),
                            ),
                            _buildSeparator(),
                            _buildListSection(
                              'Compétences visées',
                              program.targetedSkills,
                              boldFont,
                              regularFont,
                              titleColor: tyrianPurple,
                            ),
                            _buildSeparator(),
                            _buildSectionTitle(
                              'À qui s\'adresse cette formation',
                              boldFont,
                              fontSize: 9.75,
                              mb: 4.5,
                            ),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Expanded(
                                  flex: 11,
                                  child: _buildListSection(
                                    'Pour qui',
                                    program.audience,
                                    boldFont,
                                    regularFont,
                                  ),
                                ),
                                pw.SizedBox(width: 18),
                                pw.Expanded(
                                  flex: 10,
                                  child: _buildListSection(
                                    'Prérequis',
                                    program.prerequisites,
                                    boldFont,
                                    regularFont,
                                  ),
                                ),
                              ],
                            ),
                            _buildSeparator(),
                            _buildListSection(
                              'Objectifs pédagogiques',
                              program.pedagogicalObjectives,
                              boldFont,
                              regularFont,
                              titleColor: tyrianPurple,
                            ),
                            _buildSeparator(),
                            _buildSectionTitle(
                              'Programme détaillé',
                              boldFont,
                              fontSize: 9.75,
                              mb: 4.5,
                            ),
                            _buildModuleColumn(
                              program.modules.take(2).toList(),
                              regularFont,
                              boldFont,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(context, program, regularFont),
            ],
          );
        },
      ),
    );

    // Page 2
    if (program.modules.length > 2) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
          build: (context) {
            final remaining = program.modules.skip(2).toList();
            return pw.Column(
              children: [
                _buildHeader(program, logoImage, semiBoldFont, regularFont),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(24, 15, 24, 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Programme détaillé (suite)',
                          boldFont,
                          fontSize: 9.75,
                          mb: 4.5,
                        ),
                        pw.Expanded(
                          child: _buildTwoColumnModules(
                            remaining,
                            regularFont,
                            boldFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildFooter(context, program, regularFont),
              ],
            );
          },
        ),
      );
    }

    // Page 3
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (context) {
          return pw.Column(
            children: [
              _buildHeader(program, logoImage, semiBoldFont, regularFont),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(24, 15, 24, 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // _buildSectionTitle('Modalités de la formation', boldFont, fontSize: 13.5, mb: 12),
                      _buildModalityCard(
                        'Méthodes pédagogiques',
                        'Nous utilisons des exposés théoriques, et appliquons la méthode active : les connaissances liées à cette formation ne s\'apprennent pas, elles s\'appliquent.\nL\'organisation de la formation comprend :\n- Documents supports de formation projetés\n- Étude de cas concrets\n- Quiz\n- Mise à disposition en ligne de documents supports téléchargeables à la suite de la formation',
                        regularFont,
                        boldFont,
                      ),
                      _buildModalityCard(
                        'Moyens techniques',
                        'Pour suivre la formation, les apprenants devront obligatoirement être munis de (non fourni par VIV) :\n${program.technicalMeans.map((e) => "- $e").join("\n")}',
                        regularFont,
                        boldFont,
                      ),
                      _buildModalityCard(
                        'Modalités d\'animation',
                        'Nombre maximum d\'apprenants par session : 8.\nLa formation est réalisée en salle de façon synchrone, en présentiel, dans les locaux de VIV au 14 rue de Mantes, à Colombes.\nConscient des impératifs liés au monde de la production, nous proposons un rythme d\'apprentissage flexible. La répartition et l\'intensité des sessions peuvent être adaptées pour s\'ajuster au mieux aux besoins et aux disponibilités de vos équipes.',
                        regularFont,
                        boldFont,
                      ),
                      _buildModalityCard(
                        'Modalités d\'évaluation',
                        'Une évaluation des connaissances en début de parcours.\nLa vérification des compétences acquises se fera via ${program.evaluationModalities} en fin de parcours.',
                        regularFont,
                        boldFont,
                      ),
                      _buildModalityCard(
                        'Sanction / Validation',
                        'Certificat de réalisation de formation',
                        regularFont,
                        boldFont,
                      ),
                      _buildModalityCard(
                        'Modalités & délais d\'accès',
                        'La formation peut être mise en place à tout moment, à compter d\'un délai minimal de 11 jours ouvrés suivant la date de demande.\nLa demande d\'informations ou d\'inscription s\'effectue par mail (formation@viv-formation.com).\nLe démarrage de la formation ne pourra avoir lieu qu\'au minimum 2 semaines après réception de la convention signée.',
                        regularFont,
                        boldFont,
                      ),
                      _buildModalityCard(
                        'Accessibilité aux personnes handicapées',
                        'Nous sommes sensibles aux enjeux de l\'inclusion et investis sur la thématique du handicap.\nMerci de nous contacter afin de pouvoir vous accompagner dans les meilleures conditions.\nResponsable handicap : Mme Chaufournais (m.chaufournais@viv-formation.com).',
                        regularFont,
                        boldFont,
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(context, program, regularFont),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    ProgramModel program,
    pw.ImageProvider logo,
    pw.Font semiBold,
    pw.Font regular,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [pinkLavender, tyrianPurple],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  program.title,
                  style: pw.TextStyle(
                    font: semiBold,
                    fontSize: 13.5,
                    color: PdfColors.white,
                  ),
                ),
                if (program.subtitle != null)
                  pw.Text(
                    program.subtitle!,
                    style: pw.TextStyle(
                      font: regular,
                      fontSize: 10.5,
                      color: subtitleOnGradient,
                    ),
                  ),
              ],
            ),
          ),
          pw.Image(logo, height: 24),
        ],
      ),
    );
  }

  pw.Widget _buildSidebar(
    ProgramModel program,
    pw.Font bold,
    pw.Font regular,
    pw.Font medium,
    pw.Font semiBold,
    pw.Font icons,
  ) {
    return pw.Column(
      children: [
        _buildSidebarContainer(tyrianPurple, [
          _buildSidebarBlock(
            'NIVEAU',
            program.level,
            bold,
            medium,
            icons,
            0xe24b,
            textColor: PdfColors.white,
            isBloc1: true,
          ),
          _buildSidebarBlock(
            'DURÉE',
            program.duration,
            bold,
            medium,
            icons,
            0xe192,
            textColor: PdfColors.white,
            isBloc1: true,
          ),
          _buildSidebarBlock(
            'LOGICIELS',
            '',
            bold,
            medium,
            icons,
            0xe30c,
            textColor: PdfColors.white,
            isBloc1: true,
            isLast: true,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: program.software
                  .map(
                    (s) => pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        '• $s',
                        style: pw.TextStyle(
                          font: medium,
                          fontSize: 9,
                          color: PdfColors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ]),
        pw.SizedBox(height: 12),
        _buildSidebarContainer(pinkLavender5Opaque, [
          _buildSidebarBlock(
            'TARIFS',
            '',
            bold,
            medium,
            icons,
            0xe263,
            textColor: tyrianPurple,
            isLast: true,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 3),
                pw.Text(
                  'Inter entreprise',
                  style: pw.TextStyle(
                    font: medium,
                    fontSize: 9,
                    color: tyrianPurple,
                    height: 1.4,
                  ),
                ),
                pw.Text(
                  program.interPrice,
                  style: pw.TextStyle(
                    font: medium,
                    fontSize: 9,
                    color: tyrianPurple,
                    height: 1.4,
                  ),
                ),
                pw.Text(
                  '* prix constitué à partir d\'un effectif minimum',
                  style: pw.TextStyle(
                    font: regular,
                    fontSize: 7.5,
                    color: footerText,
                  ),
                ),
                pw.SizedBox(height: 9),
                pw.Text(
                  'Intra entreprise',
                  style: pw.TextStyle(
                    font: medium,
                    fontSize: 9,
                    color: tyrianPurple,
                    height: 1.4,
                  ),
                ),
                pw.Text(
                  'sur devis.',
                  style: pw.TextStyle(
                    font: medium,
                    fontSize: 9,
                    color: tyrianPurple,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ], borderColor: borderSoft),
        pw.SizedBox(height: 12),
        _buildSidebarContainer(pinkLavender5Opaque, [
          _buildSidebarBlock(
            'CALENDRIER',
            '',
            bold,
            medium,
            icons,
            0xe916,
            textColor: tyrianPurple,
            isLast: true,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Text(
                'Mise en place sur demande.\nContacter formation@viv-formation.com.',
                style: pw.TextStyle(
                  font: regular,
                  fontSize: 8.25,
                  color: tyrianPurple,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ], borderColor: borderSoft),
      ],
    );
  }

  pw.Widget _buildSidebarContainer(
    PdfColor bg,
    List<pw.Widget> children, {
    PdfColor? borderColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(13.5),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10.5)),
        border: borderColor != null
            ? pw.Border.all(color: borderColor, width: 0.75)
            : null,
      ),
      child: pw.Column(children: children),
    );
  }

  pw.Widget _buildSidebarBlock(
    String label,
    String value,
    pw.Font bold,
    pw.Font valueFont,
    pw.Font iconsFont,
    int iconCode, {
    required PdfColor textColor,
    pw.Widget? child,
    bool isLast = false,
    bool isBloc1 = false,
  }) {
    final labelColor = isBloc1 ? white60OnTyrian : tyrianPurple;
    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 7.5),
      margin: pw.EdgeInsets.only(bottom: isLast ? 0 : 7.5),
      decoration: isLast
          ? null
          : pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: isBloc1 ? border35OnTyrian : borderSoft,
                  width: 0.75,
                ),
              ),
            ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                String.fromCharCode(iconCode),
                style: pw.TextStyle(
                  font: iconsFont,
                  fontSize: 10.5,
                  color: labelColor,
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text(
                label.toUpperCase(),
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 8.25,
                  color: labelColor,
                  letterSpacing: 0.99,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          if (value.isNotEmpty)
            pw.Text(
              value,
              style: pw.TextStyle(
                font: valueFont,
                fontSize: 9,
                color: textColor,
                height: 1.4,
              ),
            ),
          ?child,
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(
    String title,
    pw.Font bold, {
    required double fontSize,
    required double mb,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: mb),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: bold,
          fontSize: fontSize,
          color: tyrianPurple,
        ),
      ),
    );
  }

  pw.Widget _buildListSection(
    String title,
    List<String> items,
    pw.Font bold,
    pw.Font regular, {
    PdfColor titleColor = foreground,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: bold, fontSize: 9.75, color: titleColor),
        ),
        pw.SizedBox(height: 3),
        ...items.map(
          (i) => _buildCustomBullet(i, foreground, regular, mb: 1.5),
        ),
      ],
    );
  }

  pw.Widget _buildCustomBullet(
    String text,
    PdfColor color,
    pw.Font font, {
    double mb = 1.5,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(left: 13.5, bottom: mb),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 4, right: 6),
            width: 2.25,
            height: 2.25,
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: font, fontSize: 9, color: color),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTwoColumnModules(
    List<ProgramModule> modules,
    pw.Font regular,
    pw.Font bold,
  ) {
    final mid = (modules.length / 2).ceil();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildModuleColumn(modules.sublist(0, mid), regular, bold),
        ),
        pw.SizedBox(width: 36),
        pw.Expanded(
          child: _buildModuleColumn(modules.sublist(mid), regular, bold),
        ),
      ],
    );
  }

  pw.Widget _buildModuleColumn(
    List<ProgramModule> modules,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Column(
      children: modules
          .map(
            (m) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3, bottom: 1.5),
                    child: pw.Text(
                      m.title,
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 9,
                        color: foreground,
                      ),
                    ),
                  ),
                  ...m.items.map(
                    (i) => _buildCustomBullet(
                      i,
                      mutedForeground,
                      regular,
                      mb: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildModalityCard(
    String title,
    String content,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 9),
      padding: const pw.EdgeInsets.fromLTRB(12, 10.5, 12, 9),
      decoration: pw.BoxDecoration(
        color: pinkLavender5Opaque,
        border: pw.Border.all(color: borderSoft, width: 0.75),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10.5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4.5),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                font: bold,
                fontSize: 9.75,
                color: tyrianPurple,
              ),
            ),
          ),
          pw.Text(
            content,
            style: pw.TextStyle(
              font: regular,
              fontSize: 7.5,
              color: mutedForeground,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSeparator() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 7),
    child: pw.Divider(color: borderSoft, thickness: 0.75),
  );

  pw.Widget _buildFooter(pw.Context context, ProgramModel program, pw.Font regular) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 7.5, horizontal: 24),
      decoration: const pw.BoxDecoration(
        color: footerBg,
        border: pw.Border(top: pw.BorderSide(color: footerBorder, width: 0.75)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
              'Version : ${program.version}',
              style: pw.TextStyle(
                font: regular,
                fontSize: 7.25,
                color: footerText,
              ),
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(
              font: regular,
              fontSize: 7.25,
              color: footerText,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Date de mise à jour : ${program.date}',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: regular,
                fontSize: 7.25,
                color: footerText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
