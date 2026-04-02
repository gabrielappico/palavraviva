import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import 'dart:math';

class ConfessionScreen extends StatefulWidget {
  const ConfessionScreen({super.key});

  @override
  State<ConfessionScreen> createState() => _ConfessionScreenState();
}

class _ConfessionScreenState extends State<ConfessionScreen> {
  final _controller = TextEditingController();
  bool _isSent = false;
  String? _verse;

  final List<Map<String, String>> _forgivenessVerses = [
    {'ref': '1 João 1:9', 'text': 'Se confessarmos os nossos pecados, ele é fiel e justo para nos perdoar as culpas e nos purificar de toda injustiça.'},
    {'ref': 'Salmos 32:5', 'text': 'Então reconheci diante de ti o meu pecado e não encobri as minhas culpas. Eu disse: "Confessarei as minhas transgressões ao Senhor", e tu perdoaste a culpa do meu pecado.'},
    {'ref': 'Miquéias 7:18', 'text': 'Quem é Deus como tu, que perdoa a maldade e esquece a rebelião do seu remanescente? Não ficas irado para sempre, pois tens prazer em mostrar amor fiel.'},
    {'ref': 'Isaías 1:18', 'text': '"Venham, vamos refletir juntos", diz o Senhor. "Embora os seus pecados sejam vermelhos como escarlate, eles se tornarão brancos como a neve..."'},
  ];

  void _confess() {
    if (_controller.text.trim().isEmpty) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isSent = true;
      _verse = '${_forgivenessVerses[Random().nextInt(_forgivenessVerses.length)]['text']!}\n— ${_forgivenessVerses[Random().nextInt(_forgivenessVerses.length)]['ref']!}';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 2),
          child: _isSent
              ? _buildForgivenState()
              : _buildConfessionState(),
        ),
      ),
    );
  }

  Widget _buildConfessionState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      key: const ValueKey('confess'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.shieldAlert, size: 48, color: AppColors.gold),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Santuário Privado',
          style: AppTypography.heading2.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tudo o que for escrito aqui permanecerá apenas entre você e Deus. Ao ser enviado, o texto será consumido.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          controller: _controller,
          maxLines: 6,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Escreva suas falhas e desabafos...',
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.lightTextSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide(color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide(color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          ),
          onPressed: _confess,
          child: Text(
            'Entregar a Deus',
            style: AppTypography.title.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildForgivenState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      key: const ValueKey('forgiven'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.flame, size: 64, color: AppColors.success),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Seus pecados foram sepultados.',
          style: AppTypography.heading2.copyWith(color: AppColors.success),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
          child: Text(
            _verse ?? '',
            style: AppTypography.body.copyWith(color: AppColors.gold, fontStyle: FontStyle.italic, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
