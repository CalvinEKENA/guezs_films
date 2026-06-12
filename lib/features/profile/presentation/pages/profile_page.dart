import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/platform/platform_capabilities.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_feedback.dart';
import '../../../../core/widgets/premium_states.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/profile_providers.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/profile_form_sheet.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: authState.when(
          data: (user) => _ProfileDashboard(user: user),
          loading: () => const PremiumLoadingState(
            title: 'Ouverture de votre profil',
            message: 'Nous préparons votre espace personnel.',
          ),
          error: (_, _) => PremiumErrorState(
            title: 'Profil indisponible',
            message:
                'Impossible de vérifier votre compte. Vérifiez votre connexion puis réessayez.',
            onRetry: () => ref.invalidate(authStateProvider),
          ),
        ),
      ),
    );
  }
}

class _ProfileDashboard extends ConsumerWidget {
  const _ProfileDashboard({required this.user});

  final UserEntity? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = user?.uid ?? '';
    final premiumAsync = userId.isEmpty
        ? const AsyncValue<bool>.data(false)
        : ref.watch(isPremiumProvider(userId));

    return ResponsiveLayout(
      builder: (context, responsive) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          responsive.pagePadding,
          responsive.isDesktop ? 28 : 18,
          responsive.pagePadding,
          28,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumPageHeader(
                  title: 'Mon espace',
                  subtitle:
                      'Votre compte, vos profils et les préférences de l’application.',
                ),
                const SizedBox(height: 24),
                _AccountHero(user: user, premiumAsync: premiumAsync),
                if (user != null) ...[
                  const SizedBox(height: 22),
                  _ProfilesSection(userId: userId),
                ],
                const SizedBox(height: 22),
                if (responsive.isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _PreferencesSection(),
                            const SizedBox(height: 18),
                            _AccountSection(
                              user: user,
                              premiumAsync: premiumAsync,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(child: _InformationSection()),
                    ],
                  )
                else ...[
                  _PreferencesSection(),
                  const SizedBox(height: 18),
                  _InformationSection(),
                  const SizedBox(height: 18),
                  _AccountSection(user: user, premiumAsync: premiumAsync),
                ],
                const SizedBox(height: 26),
                if (user == null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go(Routes.login),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Se connecter'),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _logout(context, ref),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Se déconnecter'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _startDeleteAccountFlow(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.55),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: const Text('Supprimer mon compte'),
                    ),
                  ),
                ],
                const SizedBox(height: 34),
                Center(
                  child: Text(
                    'Guezs Films v${AppConstants.appVersion}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
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

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showPremiumConfirmationDialog(
      context,
      title: 'Se déconnecter ?',
      message:
          'Vous devrez vous reconnecter pour retrouver votre compte et vos profils.',
      confirmLabel: 'Se déconnecter',
      destructive: true,
    );
    if (!confirmed) return;

    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      showPremiumSnackBar(
        context,
        message: 'La déconnexion n’a pas pu être terminée.',
        tone: PremiumFeedbackTone.error,
      );
      return;
    }
    context.go(Routes.login);
  }
}

class _AccountHero extends ConsumerWidget {
  const _AccountHero({required this.user, required this.premiumAsync});

  final UserEntity? user;
  final AsyncValue<bool> premiumAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final displayName =
        activeProfile?.name ??
        user?.displayName?.trim().takeIf((value) => value.isNotEmpty) ??
        (user == null ? 'Mode invité' : 'Cinéphile');
    final email = user?.email ?? 'Aucune session connectée';
    final isPremium = premiumAsync.valueOrNull ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandBlue.withValues(alpha: 0.72),
            AppColors.surfaceObsidian.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder(0.38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 18,
        runSpacing: 16,
        children: [
          _ProfileAvatar(
            profile: activeProfile,
            photoUrl: user?.photoUrl,
            size: 82,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      icon: user == null
                          ? Icons.person_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      label: user == null ? 'Invité' : 'Connecté',
                      color: user == null
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    _StatusChip(
                      icon: Icons.workspace_premium_outlined,
                      label: premiumAsync.isLoading
                          ? 'Vérification de l’accès'
                          : isPremium
                          ? 'Premium'
                          : 'Accès standard',
                      color: isPremium
                          ? AppColors.brandGold
                          : AppColors.textSecondary,
                    ),
                    if (activeProfile != null)
                      _StatusChip(
                        icon: activeProfile.isKids
                            ? Icons.child_care_rounded
                            : Icons.person_rounded,
                        label: activeProfile.isKids
                            ? 'Profil enfant'
                            : 'Profil standard',
                        color: AppColors.spotlightBlue,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilesSection extends ConsumerWidget {
  const _ProfilesSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(userProfilesProvider(userId));

    return _SettingsSection(
      title: 'Profils',
      child: profilesAsync.when(
        data: (profiles) => SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: profiles.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == profiles.length) {
                return _SmallProfileAction(
                  icon: Icons.add_rounded,
                  label: 'Ajouter',
                  onTap: () => _openProfileForm(context, ref),
                );
              }
              final profile = profiles[index];
              final active = ref.watch(activeProfileProvider)?.id == profile.id;
              return _SmallProfileCard(
                profile: profile,
                active: active,
                onTap: () =>
                    ref.read(activeProfileProvider.notifier).state = profile,
                onLongPress: () => _showProfileActions(context, ref, profile),
              );
            },
          ),
        ),
        loading: () => const SizedBox(
          height: 118,
          child: PremiumLoadingState(compact: true),
        ),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error),
              const SizedBox(width: 10),
              const Expanded(child: Text('Impossible de charger les profils.')),
              TextButton(
                onPressed: () => ref.invalidate(userProfilesProvider(userId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfileForm(
    BuildContext context,
    WidgetRef ref, {
    UserProfileEntity? existing,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => ProfileFormSheet(
        userId: userId,
        existing: existing,
        onSaved: (profile) {
          ref.read(activeProfileProvider.notifier).state = profile;
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  void _showProfileActions(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modifier le profil'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openProfileForm(context, ref, existing: profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.switch_account_outlined),
              title: const Text('Sélectionner ce profil'),
              onTap: () {
                ref.read(activeProfileProvider.notifier).state = profile;
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              title: const Text(
                'Supprimer le profil',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(_deleteProfile(context, ref, profile));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) async {
    final confirmed = await showPremiumConfirmationDialog(
      context,
      title: 'Supprimer “${profile.name}” ?',
      message:
          'Les préférences associées à ce profil seront supprimées. Cette action est irréversible.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref
          .read(userProfileRepositoryProvider)
          .deleteProfile(userId: userId, profileId: profile.id);
      if (ref.read(activeProfileProvider)?.id == profile.id) {
        ref.read(activeProfileProvider.notifier).state = null;
      }
      if (!context.mounted) return;
      showPremiumSnackBar(
        context,
        message: 'Profil supprimé.',
        tone: PremiumFeedbackTone.success,
      );
    } catch (_) {
      if (!context.mounted) return;
      showPremiumSnackBar(
        context,
        message: 'Le profil n’a pas pu être supprimé.',
        tone: PremiumFeedbackTone.error,
      );
    }
  }
}

class _PreferencesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Préférences',
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.download_for_offline_outlined,
            title: 'Téléchargements',
            subtitle: PlatformCapabilities.supportsDownloads
                ? 'Gérer les contenus hors-ligne'
                : 'Disponibles sur l’application mobile',
            onTap: () => context.push(Routes.downloads),
          ),
          _SettingsTile(
            icon: Icons.high_quality_outlined,
            title: 'Qualité vidéo',
            subtitle: 'Automatique · gérée par le lecteur',
            onTap: () => showPremiumInfoSheet(
              context,
              icon: Icons.high_quality_rounded,
              title: 'Qualité automatique',
              message:
                  'Le player sélectionne actuellement la qualité compatible avec la source. Le choix manuel arrivera avec les futurs flux adaptatifs.',
            ),
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Langue',
            subtitle: 'Français · seule interface disponible',
            onTap: () => showPremiumInfoSheet(
              context,
              icon: Icons.translate_rounded,
              title: 'Langues de l’application',
              message:
                  'L’interface est disponible en français pour le moment. Les futures langues apparaîtront ici lorsqu’elles seront réellement traduites.',
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Préférences bientôt disponibles',
            onTap: () => showPremiumInfoSheet(
              context,
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              message:
                  'Les alertes éditoriales ne sont pas encore connectées à un service backend. Les notifications de téléchargement mobile restent gérées par l’appareil.',
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Aide et informations',
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.support_agent_rounded,
            title: 'Support',
            subtitle: 'Centre d’aide en préparation',
            onTap: () => showPremiumInfoSheet(
              context,
              icon: Icons.support_agent_rounded,
              title: 'Support GUEZS FILMS',
              message:
                  'Le centre d’aide et le contact support seront ajoutés dans une prochaine version.',
            ),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialité',
            subtitle: 'Document en préparation',
            onTap: () => showPremiumInfoSheet(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Politique de confidentialité',
              message:
                  'Le document juridique final sera publié ici avant la mise en production publique.',
            ),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Conditions d’utilisation',
            subtitle: 'Document en préparation',
            onTap: () => showPremiumInfoSheet(
              context,
              icon: Icons.description_outlined,
              title: 'Conditions d’utilisation',
              message:
                  'Les conditions d’utilisation définitives seront accessibles depuis cet emplacement.',
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection({required this.user, required this.premiumAsync});

  final UserEntity? user;
  final AsyncValue<bool> premiumAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = premiumAsync.valueOrNull ?? false;
    return _SettingsSection(
      title: 'Compte',
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Nom d’affichage',
            subtitle: user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : user == null
                ? 'Session invitée'
                : 'Ajouter un nom',
            enabled: user != null,
            onTap: user == null
                ? null
                : () => _editDisplayName(context, ref, user?.displayName ?? ''),
          ),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Statut d’accès',
            subtitle: premiumAsync.isLoading
                ? 'Vérification en cours'
                : isPremium
                ? 'Accès premium actif'
                : 'Accès standard ou par code',
            trailing: isPremium
                ? const Icon(Icons.verified_rounded, color: AppColors.brandGold)
                : null,
            onTap: () => showPremiumInfoSheet(
              context,
              icon: isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_open_rounded,
              title: isPremium ? 'Accès premium actif' : 'Accès au catalogue',
              message: isPremium
                  ? 'Votre compte possède actuellement un statut premium reconnu.'
                  : 'Certains contenus peuvent demander une connexion ou un code. Aucun paiement n’est proposé dans cette version.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Nom d’affichage'),
          onSubmitted: (_) => Navigator.of(dialogContext).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (submitted != true || name.isEmpty) return;

    await ref.read(profileControllerProvider.notifier).updateName(name);
    if (!context.mounted) return;
    final state = ref.read(profileControllerProvider);
    showPremiumSnackBar(
      context,
      message: state.hasError
          ? 'Le nom n’a pas pu être modifié.'
          : 'Nom d’affichage mis à jour.',
      tone: state.hasError
          ? PremiumFeedbackTone.error
          : PremiumFeedbackTone.success,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.4,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceObsidian.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder(0.22)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      onTap: enabled ? onTap : null,
      minTileHeight: 68,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.brandBlue.withValues(alpha: enabled ? 0.42 : 0.2),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          size: 21,
          color: enabled ? AppColors.brandGoldLight : AppColors.textDisabled,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: enabled ? AppColors.textTertiary : AppColors.textDisabled,
        ),
      ),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                )),
    );
  }
}

class _SmallProfileCard extends StatelessWidget {
  const _SmallProfileCard({
    required this.profile,
    required this.active,
    required this.onTap,
    required this.onLongPress,
  });

  final UserProfileEntity profile;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Appui long pour gérer ${profile.name}',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          width: 78,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: profile.color,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: active
                        ? AppColors.brandGoldLight
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: _ProfileAvatar(profile: profile, size: 66),
              ),
              const SizedBox(height: 7),
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: active
                      ? AppColors.brandGoldLight
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallProfileAction extends StatelessWidget {
  const _SmallProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.glassBackground(0.26),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: AppColors.glassBorder(0.3)),
              ),
              child: Icon(icon, color: AppColors.brandGoldLight),
            ),
            const SizedBox(height: 7),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.profile, this.photoUrl, required this.size});

  final UserProfileEntity? profile;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final profileValue = profile?.emoji ?? '';
    final provider = profileValue.startsWith('assets/')
        ? AssetImage(profileValue) as ImageProvider
        : profileValue.startsWith('http')
        ? NetworkImage(profileValue)
        : photoUrl?.trim().isNotEmpty == true
        ? NetworkImage(photoUrl!)
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: profile?.color ?? AppColors.brandBlue,
        borderRadius: BorderRadius.circular(size * 0.24),
        image: provider == null
            ? null
            : DecorationImage(image: provider, fit: BoxFit.cover),
        border: Border.all(color: AppColors.glassBorder(0.4)),
      ),
      alignment: Alignment.center,
      child: provider == null
          ? profileValue.isNotEmpty && !profileValue.contains('/')
                ? Text(profileValue, style: TextStyle(fontSize: size * 0.45))
                : Icon(
                    Icons.person_rounded,
                    size: size * 0.48,
                    color: AppColors.textPrimary,
                  )
          : null,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

Future<void> _startDeleteAccountFlow(
  BuildContext context,
  WidgetRef ref,
) async {
  final credential = await _requestReauthentication(context);
  if (credential == null || !context.mounted) return;

  var deleteDownloads = false;
  if (PlatformCapabilities.supportsDownloads) {
    final choice = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fichiers hors-ligne'),
        content: const Text(
          'Voulez-vous également supprimer les fichiers téléchargés sur cet appareil ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Conserver les fichiers'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer les fichiers'),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    deleteDownloads = choice;
  }

  final confirmed = await showPremiumConfirmationDialog(
    context,
    title: 'Suppression définitive',
    message:
        'Votre compte, vos profils et vos favoris seront supprimés définitivement. Cette action est irréversible.',
    confirmLabel: 'Supprimer définitivement',
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;

  await ref
      .read(authControllerProvider.notifier)
      .deleteAccount(credential: credential, deleteDownloads: deleteDownloads);
  if (!context.mounted) return;
  final state = ref.read(authControllerProvider);
  if (state.hasError) {
    showPremiumSnackBar(
      context,
      message: _mapDeleteError(state.error ?? 'unknown'),
      tone: PremiumFeedbackTone.error,
    );
    return;
  }
  context.go(Routes.login);
}

Future<AuthCredential?> _requestReauthentication(BuildContext context) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) return null;
  final providerId = firebaseUser.providerData.isNotEmpty
      ? firebaseUser.providerData.first.providerId
      : 'password';

  if (providerId == 'google.com') return _reauthenticateWithGoogle();
  if (providerId == 'apple.com') return _reauthenticateWithApple();
  return _showPasswordDialog(context, firebaseUser.email ?? '');
}

Future<AuthCredential?> _showPasswordDialog(
  BuildContext context,
  String email,
) async {
  final passwordController = TextEditingController();
  final password = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmez votre identité'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Entrez votre mot de passe avant de supprimer définitivement le compte.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            onSubmitted: (value) =>
                Navigator.of(dialogContext).pop(value.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(passwordController.text.trim()),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Continuer'),
        ),
      ],
    ),
  );
  passwordController.dispose();
  if (password == null || password.isEmpty) return null;
  return EmailAuthProvider.credential(email: email, password: password);
}

Future<AuthCredential?> _reauthenticateWithGoogle() async {
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

Future<AuthCredential?> _reauthenticateWithApple() async {
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

String _mapDeleteError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'wrong-password' || 'invalid-credential' =>
        'Le mot de passe ou l’autorisation est incorrect.',
      'network-request-failed' =>
        'Vérifiez votre connexion internet puis réessayez.',
      _ => error.message ?? 'La suppression n’a pas pu être terminée.',
    };
  }
  return 'La suppression n’a pas pu être terminée. Réessayez.';
}

extension on String {
  String? takeIf(bool Function(String value) predicate) {
    return predicate(this) ? this : null;
  }
}
