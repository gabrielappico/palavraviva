import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/verse_mark.dart';
import '../domain/models/reading_plan.dart';

class BibleProgressRepository {
  static const _boxName = 'bibleProgressBox';
  final SupabaseClient _client;

  BibleProgressRepository(this._client);

  Box get _box => Hive.box(_boxName);
  String? get _userId => _client.auth.currentUser?.id;

  // ══════════════════════════════════════════════
  // VERSE MARKS
  // ══════════════════════════════════════════════

  /// Load all verse marks from Supabase and cache locally.
  Future<List<VerseMark>> fetchAllVerseMarks() async {
    if (_userId == null) return _loadFromCache();

    try {
      final response = await _client
          .from('verse_marks')
          .select()
          .eq('user_id', _userId!)
          .order('book_abbrev')
          .order('chapter')
          .order('verse');

      final marks = (response as List)
          .map((json) => VerseMark.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache locally
      await _cacheMarks(marks);
      return marks;
    } catch (e) {
      // Fallback to local cache on network error
      return _loadFromCache();
    }
  }

  /// Upsert a single verse mark.
  Future<VerseMark> upsertVerseMark(VerseMark mark) async {
    // Save to cache immediately
    _box.put(mark.cacheKey, json.encode(mark.toJson()));

    if (_userId == null) return mark;

    try {
      final response = await _client
          .from('verse_marks')
          .upsert(
            mark.toJson(),
            onConflict: 'user_id,book_abbrev,chapter,verse',
          )
          .select()
          .single();

      final saved = VerseMark.fromJson(response);
      _box.put(saved.cacheKey, json.encode(saved.toJson()));
      return saved;
    } catch (e) {
      // Mark will sync later; return local version
      return mark;
    }
  }

  /// Delete a verse mark (when all data is cleared from it).
  Future<void> deleteVerseMark(VerseMark mark) async {
    _box.delete(mark.cacheKey);

    if (_userId == null) return;

    try {
      await _client
          .from('verse_marks')
          .delete()
          .eq('user_id', _userId!)
          .eq('book_abbrev', mark.bookAbbrev)
          .eq('chapter', mark.chapter)
          .eq('verse', mark.verse);
    } catch (_) {}
  }

  /// Bulk upsert marks for an entire chapter (mark all as read).
  Future<List<VerseMark>> markChapterAsRead({
    required String bookAbbrev,
    required int chapter,
    required int totalVerses,
    required Map<int, VerseMark> existingMarks,
  }) async {
    if (_userId == null) return [];

    final marks = <VerseMark>[];

    for (int v = 1; v <= totalVerses; v++) {
      final existing = existingMarks[v];
      if (existing != null && existing.isRead) {
        marks.add(existing);
        continue;
      }

      final mark = existing?.copyWith(isRead: true) ??
          VerseMark.create(
            userId: _userId!,
            bookAbbrev: bookAbbrev,
            chapter: chapter,
            verse: v,
            isRead: true,
          );
      marks.add(mark);
    }

    // Cache all locally
    for (final m in marks) {
      _box.put(m.cacheKey, json.encode(m.toJson()));
    }

    // Bulk upsert to Supabase
    try {
      await _client
          .from('verse_marks')
          .upsert(
            marks.map((m) => m.toJson()).toList(),
            onConflict: 'user_id,book_abbrev,chapter,verse',
          );
    } catch (_) {}

    return marks;
  }

  // ══════════════════════════════════════════════
  // READING PLANS
  // ══════════════════════════════════════════════

  /// Fetch the active reading plan.
  Future<ReadingPlan?> fetchActivePlan() async {
    if (_userId == null) return _loadPlanFromCache();

    try {
      final response = await _client
          .from('reading_plans')
          .select()
          .eq('user_id', _userId!)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;

      final plan = ReadingPlan.fromJson(response);
      _box.put('active_plan', json.encode(plan.toJson()));
      return plan;
    } catch (e) {
      return _loadPlanFromCache();
    }
  }

  /// Create a new reading plan (deactivates previous).
  Future<ReadingPlan> createPlan(ReadingPlan plan) async {
    _box.put('active_plan', json.encode(plan.toJson()));

    if (_userId == null) return plan;

    try {
      // Deactivate existing plans
      await _client
          .from('reading_plans')
          .update({'is_active': false})
          .eq('user_id', _userId!)
          .eq('is_active', true);

      final response = await _client
          .from('reading_plans')
          .insert(plan.toJson())
          .select()
          .single();

      final saved = ReadingPlan.fromJson(response);
      _box.put('active_plan', json.encode(saved.toJson()));
      return saved;
    } catch (e) {
      return plan;
    }
  }

  /// Deactivate the current plan.
  Future<void> deactivatePlan(String planId) async {
    _box.delete('active_plan');

    if (_userId == null) return;

    try {
      await _client
          .from('reading_plans')
          .update({'is_active': false})
          .eq('id', planId);
    } catch (_) {}
  }

  // ══════════════════════════════════════════════
  // LOCAL CACHE HELPERS
  // ══════════════════════════════════════════════

  Future<void> _cacheMarks(List<VerseMark> marks) async {
    // Clear old mark entries from cache
    final keysToRemove = _box.keys
        .where((k) => k is String && k.contains(':') && k != 'active_plan')
        .toList();
    for (final key in keysToRemove) {
      await _box.delete(key);
    }

    for (final mark in marks) {
      await _box.put(mark.cacheKey, json.encode(mark.toJson()));
    }
  }

  List<VerseMark> _loadFromCache() {
    return _box.keys
        .where((k) => k is String && k.contains(':') && k != 'active_plan')
        .map((k) {
          try {
            final raw = _box.get(k) as String;
            return VerseMark.fromJson(
              json.decode(raw) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<VerseMark>()
        .toList();
  }

  ReadingPlan? _loadPlanFromCache() {
    try {
      final raw = _box.get('active_plan') as String?;
      if (raw == null) return null;
      return ReadingPlan.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
