import 'package:uuid/uuid.dart';

class ProgramModule {
  final String title;
  final List<String> items;

  ProgramModule({
    required this.title,
    required this.items,
  });

  factory ProgramModule.fromJson(Map<String, dynamic> json) {
    return ProgramModule(
      title: json['title'] as String,
      items: List<String>.from(json['items'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items,
    };
  }
}

class ProgramModel {
  final String id;
  final String title;
  final String? subtitle;
  final String level;
  final String duration;
  final List<String> software;
  final String interPrice;
  final String generalObjective;
  final List<String> audience;
  final List<String> prerequisites;
  final List<String> pedagogicalObjectives;
  final List<String> targetedSkills;
  final List<ProgramModule> modules;
  final List<String> technicalMeans;
  final String evaluationModalities;
  final String version;
  final String date;
  final bool splitProgram;

  ProgramModel({
    String? id,
    required this.title,
    this.subtitle,
    required this.level,
    required this.duration,
    required this.software,
    required this.interPrice,
    required this.generalObjective,
    required this.audience,
    required this.prerequisites,
    required this.pedagogicalObjectives,
    required this.targetedSkills,
    required this.modules,
    required this.technicalMeans,
    required this.evaluationModalities,
    required this.version,
    required this.date,
    this.splitProgram = false,
  }) : id = id ?? const Uuid().v4();

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      level: json['level'] as String,
      duration: json['duration'] as String,
      software: List<String>.from(json['software'] as List),
      interPrice: json['interPrice'] as String,
      generalObjective: json['generalObjective'] as String,
      audience: List<String>.from(json['audience'] as List),
      prerequisites: List<String>.from(json['prerequisites'] as List),
      pedagogicalObjectives: List<String>.from(json['pedagogicalObjectives'] as List),
      targetedSkills: List<String>.from(json['targetedSkills'] as List? ?? []),
      modules: (json['modules'] as List)
          .map((m) => ProgramModule.fromJson(m as Map<String, dynamic>))
          .toList(),
      technicalMeans: List<String>.from(json['technicalMeans'] as List),
      evaluationModalities: json['evaluationModalities'] as String,
      version: json['version'] as String,
      date: json['date'] as String,
      splitProgram: json['splitProgram'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'level': level,
      'duration': duration,
      'software': software,
      'interPrice': interPrice,
      'generalObjective': generalObjective,
      'audience': audience,
      'prerequisites': prerequisites,
      'pedagogicalObjectives': pedagogicalObjectives,
      'targetedSkills': targetedSkills,
      'modules': modules.map((m) => m.toJson()).toList(),
      'technicalMeans': technicalMeans,
      'evaluationModalities': evaluationModalities,
      'version': version,
      'date': date,
      'splitProgram': splitProgram,
    };
  }

  ProgramModel copyWith({
    String? title,
    String? subtitle,
    String? level,
    String? duration,
    List<String>? software,
    String? interPrice,
    String? generalObjective,
    List<String>? audience,
    List<String>? prerequisites,
    List<String>? pedagogicalObjectives,
    List<String>? targetedSkills,
    List<ProgramModule>? modules,
    List<String>? technicalMeans,
    String? evaluationModalities,
    String? version,
    String? date,
    bool? splitProgram,
  }) {
    return ProgramModel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      software: software ?? this.software,
      interPrice: interPrice ?? this.interPrice,
      generalObjective: generalObjective ?? this.generalObjective,
      audience: audience ?? this.audience,
      prerequisites: prerequisites ?? this.prerequisites,
      pedagogicalObjectives: pedagogicalObjectives ?? this.pedagogicalObjectives,
      targetedSkills: targetedSkills ?? this.targetedSkills,
      modules: modules ?? this.modules,
      technicalMeans: technicalMeans ?? this.technicalMeans,
      evaluationModalities: evaluationModalities ?? this.evaluationModalities,
      version: version ?? this.version,
      date: date ?? this.date,
      splitProgram: splitProgram ?? this.splitProgram,
    );
  }
}
