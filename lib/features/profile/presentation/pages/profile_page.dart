import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

/// User profile page with settings and account info
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final userId = user?.uid ?? '';
    
    // Watch premium status
    final premiumAsync = userId.isNotEmpty 
        ? ref.watch(isPremiumProvider(userId))
        : const AsyncValue.data(false);
    
    final isPremium = premiumAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Text(
                'Mon Profil',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // Profile card
              _buildProfileCard(context, ref, user, isPremium),

              const SizedBox(height: 24),

              // Profiles section (Netflix style)
              _buildSection(
                title: 'Profils',
                children: [_buildProfileSelector()],
              ),

              const SizedBox(height: 16),

              // Account section
              _buildSection(
                title: 'Compte',
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Informations personnelles',
                    onTap: () => _showEditNameDialog(context, ref, user?.displayName ?? ''),
                  ),
                  _buildMenuItem(
                    icon: Icons.subscriptions_outlined,
                    title: 'Abonnement',
                    subtitle: isPremium ? 'Premium Guez' : 'Gratuit',
                    onTap: () {},
                    trailing: isPremium 
                      ? _buildPremiumBadge()
                      : _buildUpgradeButton(),
                  ),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Facturation',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Settings section
              _buildSection(
                title: 'Paramètres',
                children: [
                  _buildMenuItem(
                    icon: Icons.download_outlined,
                    title: 'Téléchargements',
                    subtitle: '2.3 GB utilisés',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.hd_outlined,
                    title: 'Qualité vidéo',
                    subtitle: 'Auto',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.subtitles_outlined,
                    title: 'Sous-titres',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'Se déconnecter',
                    style: AppTextStyles.button.copyWith(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Version info
              Center(
                child: Text(
                  'Guezs Films v${AppConstants.appVersion}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, dynamic user, bool isPremium) {
    final displayName = user?.displayName ?? 'Utilisateur';
    final email = user?.email ?? 'Non connecté';
    final photoUrl = user?.photoUrl;

    return GlassCard(
      blur: 15,
      opacity: 0.05,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.glassBorder, width: 0.5),
      child: Row(
        children: [
          // Avatar with Edit Overlay
          GestureDetector(
            onTap: () => _showAvatarPicker(context, ref),
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    image: photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: photoUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 36)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: AppColors.accent, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Edit Name Button
          IconButton(
            onPressed: () => _showEditNameDialog(context, ref, displayName),
            icon: const Icon(Icons.edit_outlined, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent, width: 1),
      ),
      child: Text(
        'PREMIUM',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        'UPGRADE',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileSelector() {
    final profiles = [
      ('Principal', AppColors.primary),
      ('Enfant', AppColors.accent),
      ('+', AppColors.surfaceVariant),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final (name, color) = profiles[index];
          final isAddButton = name == '+';

          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isAddButton ? Colors.transparent : color,
                  borderRadius: BorderRadius.circular(16),
                  border: isAddButton
                      ? Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid)
                      : null,
                ),
                child: Icon(
                  isAddButton ? Icons.add : Icons.person,
                  color: isAddButton ? AppColors.textTertiary : Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAddButton ? 'Ajouter' : name,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary, size: 24),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Modifier le nom', style: AppTextStyles.titleLarge),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nouveau nom',
            labelStyle: TextStyle(color: AppColors.textTertiary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(profileControllerProvider.notifier).updateName(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        blur: 20,
        opacity: 0.1,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Choisir un Avatar Premium', style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.premiumAvatars.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final avatarUrl = AppConstants.premiumAvatars[index];
                  return GestureDetector(
                    onTap: () async {
                      await ref.read(profileControllerProvider.notifier).updateAvatar(avatarUrl);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 2),
                        image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Déconnexion', style: AppTextStyles.titleLarge),
        content: const Text('Voulez-vous vraiment quitter Guezs Films ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(Routes.login);
            },
            child: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
