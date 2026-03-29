import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/route_constants.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// User profile page with settings and account info
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

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
              _buildProfileCard(context, user),

              const SizedBox(height: 24),

              // Profiles section
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
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.subscriptions_outlined,
                    title: 'Abonnement',
                    subtitle: 'Premium',
                    onTap: () {},
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ACTIF',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
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

              const SizedBox(height: 16),

              // Help section
              _buildSection(
                title: 'Aide',
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Centre d\'aide',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'À propos',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context, ref);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    'Se déconnecter',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Version
              Center(
                child: Text(
                  'Guezs Films v1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    // Determine display name and email
    final displayName = user?.displayName ?? 'Utilisateur';
    final email = user?.email ?? 'Se connecter';
    final photoUrl = user?.photoUrl;

    return GlassCard(
      blur: 15,
      opacity: 0.1,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              image: photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 32)
                : null,
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

          // Edit button
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelector() {
    final profiles = [
      ('Utilisateur', AppColors.primary),
      ('Enfant', AppColors.accent),
      ('+', AppColors.surfaceVariant),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final (name, color) = profiles[index];
          final isAddButton = name == '+';

          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAddButton ? Colors.transparent : color,
                  borderRadius: BorderRadius.circular(12),
                  border: isAddButton
                      ? Border.all(
                          color: AppColors.border,
                          width: 2,
                          style: BorderStyle.solid,
                        )
                      : null,
                ),
                child: Icon(
                  isAddButton ? Icons.add : Icons.person,
                  color: isAddButton ? AppColors.textTertiary : Colors.white,
                  size: isAddButton ? 28 : 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAddButton ? 'Ajouter' : name,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Se déconnecter',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Trigger sign out and force navigation
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go(Routes.login);
              }
            },
            child: Text(
              'Déconnecter',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
