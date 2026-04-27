import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ActivityCategory {
  all('Todas'),
  icebreaker('Quebra-gelo'),
  drama('Encenação'),
  reflection('Reflexão'),
  competition('Competição'),
  trust('Confiança'),
  worship('Adoração');

  const ActivityCategory(this.label);
  final String label;

  IconData get icon {
    switch (this) {
      case ActivityCategory.all:
        return LucideIcons.layoutGrid;
      case ActivityCategory.icebreaker:
        return LucideIcons.snowflake;
      case ActivityCategory.drama:
        return LucideIcons.clapperboard;
      case ActivityCategory.reflection:
        return LucideIcons.brain;
      case ActivityCategory.competition:
        return LucideIcons.swords;
      case ActivityCategory.trust:
        return LucideIcons.heartHandshake;
      case ActivityCategory.worship:
        return LucideIcons.music;
    }
  }

  Color get color {
    switch (this) {
      case ActivityCategory.all:
        return const Color(0xFF5B8DEF);
      case ActivityCategory.icebreaker:
        return const Color(0xFF5BC0EB);
      case ActivityCategory.drama:
        return const Color(0xFFE88D5D);
      case ActivityCategory.reflection:
        return const Color(0xFF7EC8A0);
      case ActivityCategory.competition:
        return const Color(0xFFE85D5D);
      case ActivityCategory.trust:
        return const Color(0xFFD4A853);
      case ActivityCategory.worship:
        return const Color(0xFFCB6CE6);
    }
  }
}

enum ActivityDifficulty {
  easy('Fácil'),
  medium('Médio'),
  elaborate('Elaborado');

  const ActivityDifficulty(this.label);
  final String label;
}

enum GroupSize {
  individual('Individual'),
  pairs('Em duplas'),
  smallGroups('Pequenos grupos'),
  medium('Grupos médios'),
  large('Geral');

  const GroupSize(this.label);
  final String label;
}

class DynamicActivity {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> steps;
  final List<String> materials;
  final String bibleVerse;
  final String bibleReference;
  final String leaderTip;
  final String duration;
  final GroupSize groupSize;
  final ActivityCategory category;
  final ActivityDifficulty difficulty;
  final int minParticipants;

  const DynamicActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.steps,
    required this.materials,
    required this.bibleVerse,
    required this.bibleReference,
    required this.leaderTip,
    required this.duration,
    required this.groupSize,
    required this.category,
    required this.difficulty,
    required this.minParticipants,
  });
}
