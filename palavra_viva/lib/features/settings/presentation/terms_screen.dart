import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text('Privacidade e Termos', style: AppTypography.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const BouncingScrollPhysics(),
        children: [
          _Section(
            title: '1. Nossa Missão e Seu Uso',
            content: 'O Palavra Viva foi desenvolvido com o propósito de aproximar você de Deus através de ferramentas bíblicas, diário espiritual e comunidade. Ao utilizar o aplicativo, você concorda em usar todas as ferramentas com respeito, mantendo um ambiente edificante para si mesmo e para a comunidade (quando aplicável).',
            isDark: isDark,
          ),
          _Section(
            title: '2. Dados que Coletamos',
            content: 'Nós armazenamos os dados que você fornece ativamente: E-mail, Senha (criptografada), e informações de Perfil (como nome, data de nascimento, data de batismo e foto de perfil). Seus registros do diário, respostas do Palavra.AI, e anotações são armazenados de forma privada numa nuvem segura atrelada unicamente à sua conta.',
            isDark: isDark,
          ),
           _Section(
            title: '3. Como Protegemos Suas Informações',
            content: 'A sua intimidade espiritual é prioridade. Utilizamos infraestrutura segura com proteção de chaves (Row Level Security no Supabase) garantindo que absolutamente ninguém além de você logado na sua conta possa ler ou alterar seus Diários ou Confissões particulares. A Inteligência Artificial também interage por vias seguras mantendo o sigilo.',
            isDark: isDark,
          ),
          _Section(
            title: '4. Inteligência Artificial (Palavra.AI)',
            content: 'O Palavra.AI atua como um conselheiro teológico utilizando modelos providos pela OpenAI. Todo seu uso deve estar atrelado ao desejo de buscar direcionamento com embasamento cristão e sabedoria. O modelo não usa suas confissões mais profundas para treinar dados futuros, sendo o escopo da assistência estritamente pessoal no seu aplicativo.',
            isDark: isDark,
          ),
          _Section(
            title: '5. Exclusão de Conta',
            content: 'Caso sinta que não precisa mais de nossos serviços, ao excluir sua conta todos os seus dados pessoais e dados atrelados aos módulos de orações e diários serão permanentemente excluídos da nossa base de dados sem possibilidade de recuperação posterior.',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: Text(
              'A paz seja com você.',
              style: AppTypography.heading2.copyWith(
                color: AppColors.gold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  final bool isDark;

  const _Section({
    required this.title,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
