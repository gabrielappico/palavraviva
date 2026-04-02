import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class SermonsScreen extends StatefulWidget {
  const SermonsScreen({super.key});

  @override
  State<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends State<SermonsScreen> {
  final _themeController = TextEditingController();
  final _baseTextController = TextEditingController();
  final _audienceController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGenerated = false;

  void _generate() async {
    if (_themeController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Simulate AI Generation Delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isGenerated = true;
      });
    }
  }

  @override
  void dispose() {
    _themeController.dispose();
    _baseTextController.dispose();
    _audienceController.dispose();
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
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.celestialBlue),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _isGenerated 
            ? _buildGeneratedState() 
            : _buildInputState(),
        ),
      ),
    );
  }

  Widget _buildInputState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      key: const ValueKey('input'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Auxílio para Pregações',
          style: AppTypography.heading2.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Gere sermões e mensagens completas com IA',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informações da Mensagem',
                style: AppTypography.heading3.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Tema
              Text(
                'Tema *', 
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildTextField(
                controller: _themeController,
                hintText: 'Ex: O amor de Deus',
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Texto Base
              Text(
                'Texto Base (opcional)', 
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildTextField(
                controller: _baseTextController,
                hintText: 'Ex: João 3:16',
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Público-Alvo
              Text(
                'Público-Alvo (opcional)', 
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildTextField(
                controller: _audienceController,
                hintText: 'Ex: Jovens, casais, congregação geral',
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), // Unused standard blue for exact match, but retaining harmony
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
                onPressed: _isLoading ? null : _generate,
                child: _isLoading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.mic, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Gerar Mensagem',
                          style: AppTypography.title.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      controller: controller,
      style: AppTypography.body.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.lightTextSecondary.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.celestialBlue),
        ),
      ),
    );
  }

  Widget _buildGeneratedState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      key: const ValueKey('generated'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.celestialBlue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEMA: ${_themeController.text.toUpperCase()}',
                style: AppTypography.label.copyWith(color: AppColors.celestialBlue, letterSpacing: 2),
              ),
              if (_baseTextController.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'CITAÇÃO: ${_baseTextController.text}',
                  style: AppTypography.caption.copyWith(color: AppColors.gold),
                ),
              ],
              if (_audienceController.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'ALVO: ${_audienceController.text}',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Divider(color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
              const SizedBox(height: AppSpacing.md),
              _buildTopic('1. Introdução', 'Comece contextualizando a importância deste tema hoje e lendo a passagem principal. Dê uma ilustração pessoal.'),
              _buildTopic('2. O Problema', 'Apresente qual a dor ou a dificuldade que a Bíblia está endereçando (ex: Incredulidade, ansiedade, medo).'),
              _buildTopic('3. A Solução (Caminho)', 'Mostre a ação. O que devemos fazer com base na Escritura? (Oração, jejum, perdão, dependência de Deus).'),
              _buildTopic('4. Conclusão', 'Faça o apelo final. Convide a igreja para uma resposta prática diante da Palavra recebida.'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.celestialBlue),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          ),
          onPressed: () {
            setState(() {
              _isGenerated = false;
              _themeController.clear();
              _baseTextController.clear();
              _audienceController.clear();
            });
          },
          child: Text(
            'Gerar Outro',
            style: AppTypography.title.copyWith(color: AppColors.celestialBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildTopic(String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: AppTypography.title.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description, 
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, 
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
