import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _verseController = TextEditingController();
  final _churchController = TextEditingController();

  DateTime? _birthDate;
  DateTime? _baptismDate;
  String? _avatarUrl;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  void _loadMetadata() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null) {
        _nameController.text = meta['name'] ?? '';
        _verseController.text = meta['favorite_verse'] ?? '';
        _churchController.text = meta['local_church'] ?? '';
        _avatarUrl = meta['avatar_url'];
        
        if (meta['birth_date'] != null) {
          _birthDate = DateTime.tryParse(meta['birth_date']);
        }
        if (meta['baptism_date'] != null) {
          _baptismDate = DateTime.tryParse(meta['baptism_date']);
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe um Nome de Exibição.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final attrs = {
        'name': newName,
        'favorite_verse': _verseController.text.trim(),
        'local_church': _churchController.text.trim(),
        if (_birthDate != null) 'birth_date': _birthDate!.toIso8601String(),
        if (_baptismDate != null) 'baptism_date': _baptismDate!.toIso8601String(),
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
      };

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: attrs),
      );
      
      // Agenda a notificacao se tiver a data
      if (_birthDate != null) {
        try {
          await NotificationService().scheduleBirthdayNotification(_birthDate!);
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      final fileName = '$currentUserId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
          );

      final newUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
      setState(() {
        _avatarUrl = newUrl;
      });
      
      await _updateProfile();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Erro ao fazer upload da imagem. Certifique-se de que a pasta (Bucket) "avatars" foi criada no painel do Supabase.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate(bool isBirthDate) async {
    final now = DateTime.now();
    final initial = isBirthDate ? (_birthDate ?? DateTime(now.year - 20)) : (_baptismDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('pt', 'BR'),
      initialDatePickerMode: isBirthDate ? DatePickerMode.year : DatePickerMode.day,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark 
            ? ThemeData.dark().copyWith(
               colorScheme: const ColorScheme.dark(
                 primary: AppColors.gold,
                 onPrimary: Colors.white,
                 surface: AppColors.darkSurface,
                 onSurface: Colors.white,
               )
              )
            : ThemeData.light().copyWith(
               colorScheme: const ColorScheme.light(
                 primary: AppColors.gold,
                 onPrimary: Colors.white,
                 surface: AppColors.lightSurface,
                 onSurface: Colors.black,
               )
              ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _baptismDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _verseController.dispose();
    _churchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final currentName = _nameController.text;
    final initial = currentName.isNotEmpty ? currentName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text('Meu Perfil', style: AppTypography.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child: _avatarUrl == null
                        ? Text(
                            initial,
                            style: AppTypography.heading1.copyWith(
                              color: AppColors.gold,
                              fontSize: 40,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildTextField(
            label: 'Nome de Exibição',
            hint: 'Como devemos te chamar?',
            controller: _nameController,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildDateField(
             label: 'Data de Aniversário',
             date: _birthDate,
             icon: LucideIcons.cake,
             isDark: isDark,
             onTap: () => _pickDate(true),
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildDateField(
             label: 'Data de Batismo',
             date: _baptismDate,
             hint: 'Não se batizou ainda? Sem problemas',
             icon: LucideIcons.droplets,
             isDark: isDark,
             onTap: () => _pickDate(false),
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildTextField(
            label: 'Versículo Favorito',
            hint: 'Ex: Salmos 23:1',
            icon: LucideIcons.book,
            controller: _verseController,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildTextField(
            label: 'Igreja Local (opicional)',
            hint: 'Onde você congrega?',
            icon: LucideIcons.building,
            controller: _churchController,
            isDark: isDark,
          ),

          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Salvar Perfil', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          _ProfileItem(
            icon: LucideIcons.mail,
            label: 'E-mail de Cadastro',
            value: user?.email ?? 'Não informado',
            isDark: isDark,
          ),
          
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            icon: const Icon(LucideIcons.logOut, color: Colors.white),
            label: Text(
              'Sair da Conta', 
              style: AppTypography.button.copyWith(color: Colors.white)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSurface2,
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required String hint, 
    IconData? icon,
    required TextEditingController controller, 
    required bool isDark
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: AppColors.gold, size: 20) : null,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: isDark ? AppColors.gold.withValues(alpha: 0.1) : AppColors.gold.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(
                color: isDark ? AppColors.gold.withValues(alpha: 0.1) : AppColors.gold.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label, 
    DateTime? date, 
    String hint = 'Tocar para selecionar',
    required IconData icon, 
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
               color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
               borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
               border: Border.all(
                 color: isDark ? AppColors.gold.withValues(alpha: 0.1) : AppColors.gold.withValues(alpha: 0.2),
               )
            ),
            child: Row(
               children: [
                 Icon(icon, color: AppColors.gold, size: 20),
                 const SizedBox(width: 12),
                 if (date != null)
                   Text(
                     DateFormat('dd / MM / yyyy').format(date),
                     style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 16,
                     ),
                   )
                 else
                   Text(
                     hint,
                     style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 16,
                     ),
                   ),
               ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.gold.withValues(alpha: 0.1) : AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
