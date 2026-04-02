import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/bible_book.dart';
import '../data/bible_repository.dart';
import 'chapters_screen.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final booksAsync = ref.watch(allBibleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bíblia Sagrada'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, stack) => const Center(child: Text('Erro ao carregar Bíblia', style: TextStyle(color: Colors.red))),
        data: (books) {
          if (books.isEmpty) return const SizedBox.shrink();

          // A Bíblia Protestante padrão (NVI) tem 39 livros no AT e 27 no NT.
          final oldTestament = books.take(39).toList();
          final newTestament = books.skip(39).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Text('Antigo Testamento', style: AppTypography.heading3.copyWith(color: AppColors.gold)),
                ),
              ),
              _buildBookGrid(oldTestament, isDark),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.xl, bottom: AppSpacing.md),
                  child: Text('Novo Testamento', style: AppTypography.heading3.copyWith(color: AppColors.gold)),
                ),
              ),
              _buildBookGrid(newTestament, isDark),
              const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxxl)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookGrid(List<BibleBook> books, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books[index];
            return InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => ChaptersScreen(book: book),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSpacing.radiusSm),
                          bottomLeft: Radius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        book.abbrev,
                        style: AppTypography.label.copyWith(color: AppColors.gold),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Hero(
                        tag: 'book_title_${book.abbrev}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            book.name,
                            style: AppTypography.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
