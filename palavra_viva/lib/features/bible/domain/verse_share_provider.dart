import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Generates a deterministic key for a verse reference
String verseKey(String abbrev, int chapter, int startVerse, int? endVerse) {
  final end = endVerse ?? startVerse;
  return '${abbrev}_${chapter}_${startVerse}_$end';
}

/// Mutable share count cache — supports optimistic updates
final _shareCountCache = <String, int>{};

/// Fetches the share count for a verse, with optimistic cache overlay
final verseShareCountProvider =
    Provider.family<int, String>((ref, key) {
  // If we have a cached optimistic value, use it
  if (_shareCountCache.containsKey(key)) {
    return _shareCountCache[key]!;
  }

  // Otherwise fetch from server
  final asyncCount = ref.watch(_fetchShareCountProvider(key));
  final serverCount = asyncCount.value ?? 0;
  return serverCount;
});

/// Internal: fetches share count from Supabase
final _fetchShareCountProvider =
    FutureProvider.family<int, String>((ref, key) async {
  try {
    final response = await Supabase.instance.client
        .from('verse_shares')
        .select('share_count')
        .eq('verse_key', key)
        .maybeSingle();

    if (response == null) return 0;
    final count = (response['share_count'] as num?)?.toInt() ?? 0;
    _shareCountCache[key] = count;
    return count;
  } catch (_) {
    return 0;
  }
});

/// Increments the share count optimistically, then persists to Supabase
Future<void> incrementVerseShare(WidgetRef ref, String key) async {
  // Optimistic update
  final current = _shareCountCache[key] ?? 0;
  _shareCountCache[key] = current + 1;
  ref.invalidate(verseShareCountProvider(key));

  try {
    final result = await Supabase.instance.client
        .rpc('increment_verse_share', params: {'p_verse_key': key});

    if (result is num) {
      _shareCountCache[key] = result.toInt();
      ref.invalidate(verseShareCountProvider(key));
    }
  } catch (_) {
    // Keep optimistic value — will sync on next app open
  }
}
