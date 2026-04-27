import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/activity_model.dart';
import '../data/activities_data.dart';

const _favoritesKey = 'activity_favorites';

final activityFavoritesProvider =
    NotifierProvider<ActivityFavoritesNotifier, Set<String>>(
        ActivityFavoritesNotifier.new);

class ActivityFavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favoritesKey) ?? [];
    state = ids.toSet();
  }

  Future<void> toggle(String id) async {
    final updated = Set<String>.from(state);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, updated.toList());
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, ActivityCategory>(
        SelectedCategoryNotifier.new);

class SelectedCategoryNotifier extends Notifier<ActivityCategory> {
  @override
  ActivityCategory build() => ActivityCategory.all;

  void select(ActivityCategory category) => state = category;
}

final filteredActivitiesProvider = Provider<List<DynamicActivity>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  if (category == ActivityCategory.all) return activitiesDataset;
  return activitiesDataset.where((a) => a.category == category).toList();
});

final weeklyActivityProvider = Provider<DynamicActivity>((ref) {
  final now = DateTime.now();
  final weekOfYear = ((now.difference(DateTime(now.year)).inDays) / 7).floor();
  final index = weekOfYear % activitiesDataset.length;
  return activitiesDataset[index];
});
