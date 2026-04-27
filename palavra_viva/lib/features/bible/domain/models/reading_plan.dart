import 'package:uuid/uuid.dart';

class ReadingPlan {
  final String id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime targetDate;
  final bool isActive;
  final int chaptersAtStart;
  final DateTime createdAt;

  const ReadingPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.targetDate,
    this.isActive = true,
    this.chaptersAtStart = 0,
    required this.createdAt,
  });

  factory ReadingPlan.create({
    required String userId,
    required String title,
    required DateTime targetDate,
    int chaptersAtStart = 0,
  }) {
    return ReadingPlan(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      startDate: DateTime.now(),
      targetDate: targetDate,
      isActive: true,
      chaptersAtStart: chaptersAtStart,
      createdAt: DateTime.now(),
    );
  }

  /// Total days in the plan.
  int get totalDays => targetDate.difference(startDate).inDays;

  /// Days elapsed since plan start.
  int get daysElapsed {
    final elapsed = DateTime.now().difference(startDate).inDays;
    return elapsed.clamp(0, totalDays);
  }

  /// Days remaining until target.
  int get daysRemaining {
    final remaining = targetDate.difference(DateTime.now()).inDays;
    return remaining.clamp(0, totalDays);
  }

  /// Progress fraction (0.0 to 1.0) based on time elapsed.
  double get timeProgress => totalDays > 0 ? daysElapsed / totalDays : 0.0;

  /// Whether the plan deadline has passed.
  bool get isExpired => DateTime.now().isAfter(targetDate);

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
    'target_date': '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
    'is_active': isActive,
    'chapters_at_start': chaptersAtStart,
    'created_at': createdAt.toIso8601String(),
  };

  factory ReadingPlan.fromJson(Map<String, dynamic> json) => ReadingPlan(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    startDate: DateTime.parse(json['start_date'] as String),
    targetDate: DateTime.parse(json['target_date'] as String),
    isActive: json['is_active'] as bool? ?? true,
    chaptersAtStart: json['chapters_at_start'] as int? ?? 0,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
