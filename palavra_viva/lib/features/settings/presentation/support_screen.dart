import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = "556596312685";
    const message = "Olá! Preciso de ajuda com o aplicativo Palavra Viva.";
    final url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    await _launchUrl(url);
  }

  Future<void> _launchEmail() async {
    final url = "mailto:contato@appicompany.com?subject=${Uri.encodeComponent('Suporte - Palavra Viva')}";
    await _launchUrl(url);
  }

  Future<void> _launchInstagram() async {
    const username = "appicompany";
    final url = "https://instagram.com/$username";
    await _launchUrl(url);
  }

  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;

    setState(() { _isSubmitting = true; });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('feedbacks').insert({
          'user_id': user.id,
          'content': text,
        });

        if (mounted) {
          _feedbackController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sua mensagem foi enviada. Obrigado!'),
              backgroundColor: Colors.green,
            ),
          );
          FocusScope.of(context).unfocus();
        }
      } else {
        throw Exception("Usuário não autenticado.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar feedback. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

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
        title: Text('Ajuda e Suporte', style: AppTypography.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildSectionHeader('Dúvidas Frequentes (FAQ)', isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildFaqItem(
              'Meus diários estão seguros?',
              'Sim! Todos os seus diários são armazenados de forma criptografada nos nossos servidores (usando a plataforma segura do Supabase) e apenas você tem acesso a eles com sua conta.',
              isDark,
            ),
            _buildFaqItem(
              'Como o Palavra.AI funciona?',
              'O Palavra.AI utiliza inteligência artificial avançada para ajudar com devocionais, tirar dúvidas sobre passagens bíblicas e apoiar no seu estudo da palavra de Deus.',
              isDark,
            ),
            _buildFaqItem(
              'Posso mudar o tamanho da fonte?',
              'Claro! Vá em Configurações > Tamanho da Fonte e escolha a opção que for mais confortável para sua leitura.',
              isDark,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader('Reportar um Problema', isDark),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Encontrou algum problema ou tem uma sugestão? Envie para nós pelo aplicativo:',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 4,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Escreva sua mensagem aqui...',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Enviar Mensagem', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionHeader('Outros Canais', isDark),
            const SizedBox(height: AppSpacing.sm),
            _ContactTile(
              icon: LucideIcons.messageCircle,
              title: 'WhatsApp',
              subtitle: 'Responderemos o mais rápido possível',
              isDark: isDark,
              onTap: _launchWhatsApp,
            ),
            _ContactTile(
              icon: LucideIcons.mail,
              title: 'E-mail',
              subtitle: 'contato@appicompany.com',
              isDark: isDark,
              onTap: _launchEmail,
            ),
            _ContactTile(
              icon: LucideIcons.instagram,
              title: 'Instagram',
              subtitle: '@appicompany',
              isDark: isDark,
              onTap: _launchInstagram,
            ),
            
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.caption.copyWith(
        color: isDark ? AppColors.gold : AppColors.goldDark,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          iconColor: AppColors.gold,
          collapsedIconColor: isDark ? Colors.white54 : Colors.black54,
          childrenPadding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          children: [
            Text(
              answer,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold),
        title: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTypography.caption),
        trailing: Icon(LucideIcons.arrowUpRight, size: 18, color: isDark ? Colors.white38 : Colors.black38),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
