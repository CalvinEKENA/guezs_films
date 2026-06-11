import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/profile_providers.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/profile_form_sheet.dart';

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
        child: ResponsiveLayout(
          builder: (context, responsive) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              responsive.pagePadding,
              16,
              responsive.pagePadding,
              16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: responsive.isDesktop
                      ? 920
                      : responsive.maxContentWidth,
                ),
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

                    // Profiles section
                    _buildSection(
                      title: 'Profils',
                      children: [_buildProfileSelector(context, ref, userId)],
                    ),

                    const SizedBox(height: 16),

                    // Account section
                    _buildSection(
                      title: 'Compte',
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Informations personnelles',
                          onTap: () => _showEditNameDialog(
                            context,
                            ref,
                            user?.displayName ?? '',
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.subscriptions_outlined,
                          title: 'Abonnement',
                          subtitle: isPremium ? 'Premium Guez' : 'Gratuit',
                          onTap: () =>
                              _showSubscriptionSheet(context, isPremium),
                          trailing: isPremium
                              ? _buildPremiumBadge()
                              : _buildUpgradeButton(),
                        ),
                        _buildMenuItem(
                          icon: Icons.payment_outlined,
                          title: 'Facturation',
                          onTap: () => _showBillingSheet(context),
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
                          onTap: () => context.push(Routes.downloads),
                        ),
                        _buildMenuItem(
                          icon: Icons.hd_outlined,
                          title: 'Qualité vidéo',
                          subtitle: 'Auto',
                          onTap: () => _showVideoQualitySheet(context),
                        ),
                        _buildMenuItem(
                          icon: Icons.subtitles_outlined,
                          title: 'Sous-titres',
                          onTap: () => _showSubtitlesSheet(context),
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () => _showNotificationsSheet(context),
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
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_rounded, size: 18),
                      label: const Text('Supprimer mon compte'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => _startDeleteAccountFlow(context, ref),
                    ),

                    const SizedBox(height: 48),

                    // Version info
                    Center(
                      child: Text(
                        'Guezs Films v${AppConstants.appVersion}',
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
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isPremium,
  ) {
    final displayName = user?.displayName ?? 'Utilisateur';
    final email = user?.email ?? 'Non connecté';
    final photoUrl = user?.photoUrl;

    return GlassCard(
      blur: 15,
      opacity: 0.05,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.glassBorder(0.28), width: 0.5),
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
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.black,
                    ),
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
                      const Icon(
                        Icons.verified,
                        color: AppColors.accent,
                        size: 18,
                      ),
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
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textTertiary,
            ),
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
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileSelector(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    final profilesAsync = ref.watch(userProfilesProvider(userId));

    return profilesAsync.when(
      data: (profiles) {
        final items = [...profiles, null]; // null = bouton "+"

        return SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final profile = items[index];
              if (profile == null) {
                return _buildAddProfileButton(context, ref, userId);
              }
              return _buildProfileItem(context, ref, userId, profile);
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 108,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    WidgetRef ref,
    String userId,
    UserProfileEntity profile,
  ) {
    final isActive = ref.watch(activeProfileProvider)?.id == profile.id;

    return GestureDetector(
      onTap: () {
        ref.read(activeProfileProvider.notifier).state = profile;
      },
      onLongPress: () => _showProfileOptions(context, ref, userId, profile),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: profile.color,
              borderRadius: BorderRadius.circular(16),
              border: isActive
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: profile.color.withValues(alpha: 0.55),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child:
                  profile.emoji.startsWith('assets/') ||
                      profile.emoji.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: profile.emoji.startsWith('http')
                          ? Image.network(
                              profile.emoji,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              profile.emoji,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                    )
                  : Text(profile.emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddProfileButton(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) {
    return GestureDetector(
      onTap: () => _showCreateSheet(context, ref, userId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajouter',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileOptions(
    BuildContext context,
    WidgetRef ref,
    String userId,
    UserProfileEntity profile,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: profile.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child:
                            profile.emoji.startsWith('assets/') ||
                                profile.emoji.startsWith('http')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: profile.emoji.startsWith('http')
                                    ? Image.network(
                                        profile.emoji,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        profile.emoji,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : Text(
                                profile.emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      profile.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  'Modifier',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditSheet(context, ref, userId, profile);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.switch_account_outlined,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  'Sélectionner ce profil',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  ref.read(activeProfileProvider.notifier).state = profile;
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  'Supprimer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _confirmDeleteProfile(context, ref, userId, profile);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ProfileFormSheet(
        userId: userId,
        onSaved: (profile) {
          ref.read(activeProfileProvider.notifier).state = profile;
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    String userId,
    UserProfileEntity profile,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ProfileFormSheet(
        userId: userId,
        existing: profile,
        onSaved: (_) => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> _confirmDeleteProfile(
    BuildContext context,
    WidgetRef ref,
    String userId,
    UserProfileEntity profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer "${profile.name}" ?',
          style: AppTextStyles.titleLarge,
        ),
        content: Text(
          'Cette action est irréversible.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(userProfileRepositoryProvider)
          .deleteProfile(userId: userId, profileId: profile.id);
      // Si ce profil était actif, désélectionner
      if (ref.read(activeProfileProvider)?.id == profile.id) {
        ref.read(activeProfileProvider.notifier).state = null;
      }
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) {
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
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(profileControllerProvider.notifier)
                  .updateName(controller.text);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: AppColors.textOnGold),
            ),
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                      await ref
                          .read(profileControllerProvider.notifier)
                          .updateAvatar(avatarUrl);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        ),
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

  void _showSubscriptionSheet(BuildContext context, bool isPremium) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.08,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.accent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  isPremium ? 'Abonnement Premium Guez' : 'Passer à Premium',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isPremium
                      ? 'Vous bénéficiez d\'un accès illimité à tout le catalogue Guezs Films, en HD et sans publicité.'
                      : 'Débloquez tout le catalogue, la HD, les téléchargements et bien plus encore.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!isPremium) ...[
                  _buildPlanTile(
                    ctx,
                    '100 FCFA / épisode',
                    'À l\'unité',
                    isHighlighted: false,
                  ),
                  const SizedBox(height: 12),
                  _buildPlanTile(
                    ctx,
                    '2 500 FCFA / mois',
                    'Mensuel  •  Accès illimité',
                    isHighlighted: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textOnGold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'S\'abonner maintenant',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textOnGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTile(
    BuildContext context,
    String price,
    String label, {
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : AppColors.border,
          width: isHighlighted ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: AppTextStyles.titleSmall.copyWith(
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isHighlighted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'MEILLEUR',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBillingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.08,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Facturation',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildBillingRow(
                  Icons.history_rounded,
                  'Historique des paiements',
                  'Aucune transaction',
                ),
                const Divider(color: AppColors.border, height: 24),
                _buildBillingRow(
                  Icons.credit_card_outlined,
                  'Moyen de paiement',
                  'Aucun moyen enregistré',
                ),
                const Divider(color: AppColors.border, height: 24),
                _buildBillingRow(
                  Icons.receipt_long_outlined,
                  'Prochain prélèvement',
                  '—',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Fermer',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textTertiary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVideoQualitySheet(BuildContext context) {
    const qualities = ['Auto', '1080p HD', '720p HD', '480p', '360p'];
    String selected = 'Auto';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.08,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Qualité vidéo',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...qualities.map(
                  (q) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    title: Text(
                      q,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: q == selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: AppColors.border,
                            size: 20,
                          ),
                    onTap: () {
                      setState(() => selected = q);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubtitlesSheet(BuildContext context) {
    const subtitles = ['Désactivés', 'Français', 'Anglais', 'Wolof'];
    String selected = 'Désactivés';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.08,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Sous-titres',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ...subtitles.map(
                  (s) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Icon(
                      s == 'Désactivés'
                          ? Icons.subtitles_off_outlined
                          : Icons.subtitles_outlined,
                      color: s == selected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    title: Text(
                      s,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: s == selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() => selected = s);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: GlassCard(
          blur: 20,
          opacity: 0.08,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              bool newEpisodes = true;
              bool newFilms = true;
              bool promotions = false;
              bool recommendations = true;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Notifications',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildNotifToggle(
                    ctx,
                    setState,
                    label: 'Nouveaux épisodes',
                    subtitle: 'Soyez alerté dès qu\'un épisode sort',
                    value: newEpisodes,
                    onChanged: (v) => setState(() => newEpisodes = v),
                  ),
                  _buildNotifToggle(
                    ctx,
                    setState,
                    label: 'Nouveaux films',
                    subtitle: 'Films ajoutés au catalogue',
                    value: newFilms,
                    onChanged: (v) => setState(() => newFilms = v),
                  ),
                  _buildNotifToggle(
                    ctx,
                    setState,
                    label: 'Recommandations',
                    subtitle: 'Contenu personnalisé pour vous',
                    value: recommendations,
                    onChanged: (v) => setState(() => recommendations = v),
                  ),
                  _buildNotifToggle(
                    ctx,
                    setState,
                    label: 'Promotions',
                    subtitle: 'Offres et réductions',
                    value: promotions,
                    onChanged: (v) => setState(() => promotions = v),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textOnGold,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Enregistrer',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textOnGold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotifToggle(
    BuildContext context,
    StateSetter setState, {
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
      ),
      value: value,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
      onChanged: onChanged,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(Routes.login);
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Delete Account Flow ──────────────────────────────────────────────────

  Future<void> _startDeleteAccountFlow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final credential = await _showReauthDialog(context);
    if (credential == null || !context.mounted) return;

    final deleteDownloads = await _showDeleteDownloadsDialog(context);
    if (deleteDownloads == null || !context.mounted) return;

    final confirmed = await _showFinalConfirmationSheet(context);
    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .deleteAccount(
            credential: credential,
            deleteDownloads: deleteDownloads,
          );
      if (context.mounted) context.go(Routes.login);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapDeleteError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<AuthCredential?> _showReauthDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';
    if (providerId == 'google.com') return _reauthWithGoogle();
    if (providerId == 'apple.com') return _reauthWithApple();
    return _showEmailReauthDialog(context, user.email ?? '');
  }

  Future<AuthCredential?> _showEmailReauthDialog(
    BuildContext context,
    String email,
  ) async {
    final passwordController = TextEditingController();
    AuthCredential? credential;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Confirmez votre identité',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez votre mot de passe pour continuer.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              credential = EmailAuthProvider.credential(
                email: email,
                password: passwordController.text.trim(),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    return credential;
  }

  Future<AuthCredential?> _reauthWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final auth = await googleUser.authentication;
      return GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AuthCredential?> _reauthWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );
      return OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool?> _showDeleteDownloadsDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Fichiers téléchargés',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Voulez-vous aussi supprimer vos fichiers téléchargés sur cet appareil ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non, garder les fichiers'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Oui, tout supprimer'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showFinalConfirmationSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Suppression définitive',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cette action est irréversible. Votre compte, vos profils et vos favoris seront définitivement supprimés.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Supprimer définitivement',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  String _mapDeleteError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Mot de passe incorrect.';
        case 'network-request-failed':
          return 'Vérifiez votre connexion internet.';
        default:
          return 'Erreur : ${e.message}';
      }
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
