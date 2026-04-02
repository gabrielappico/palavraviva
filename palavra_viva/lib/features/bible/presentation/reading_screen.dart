import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/bible_book.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({
    super.key,
    required this.book,
    required this.chapterIndex,
  });

  final BibleBook book;
  final int chapterIndex;

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  // Configuração rápida de preferência do usuário (Para a MVP)
  double _fontSizeTheme = 18.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070A12) : AppColors.lightBackground, // Um fundo ainda mais escuro para imersão focada
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Hero(
              tag: 'book_title_${widget.book.abbrev}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.book.name,
                  style: AppTypography.heading3.copyWith(fontSize: 20),
                ),
              ),
            ),
            Text(
              'Capítulo ${widget.chapterIndex + 1}',
              style: AppTypography.caption.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.type),
            onPressed: () {
              // Simples menu de tamanho de fonte
              showModalBottomSheet(
                context: context,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tamanho da Fonte', style: AppTypography.title),
                      StatefulBuilder(builder: (context, setModalState) {
                        return Slider(
                          value: _fontSizeTheme,
                          min: 14.0,
                          max: 28.0,
                          activeColor: AppColors.gold,
                          inactiveColor: AppColors.gold.withValues(alpha: 0.2),
                          onChanged: (val) {
                            setState(() => _fontSizeTheme = val);
                            setModalState(() => _fontSizeTheme = val);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        itemCount: widget.book.chapters[widget.chapterIndex].length,
        itemBuilder: (context, index) {
          final verseText = widget.book.chapters[widget.chapterIndex][index];
          final verseNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: RichText(
              text: TextSpan(
                style: AppTypography.bibleText.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontSize: _fontSizeTheme,
                  height: 1.8, // Altura de linha majestosa e confortável
                ),
                children: [
                  TextSpan(
                    text: '$verseNumber  ',
                    style: TextStyle(
                      color: AppColors.gold.withValues(alpha: 0.8),
                      fontSize: _fontSizeTheme * 0.75,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: verseText),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
