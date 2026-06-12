import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/premium_states.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/profile_form_sheet.dart';

class ProfileSelectorPage extends ConsumerWidget {
  const ProfileSelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCinema,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _SelectorBackdrop(),
            SafeArea(
              child: authState.when(
                data: (user) {
                  if (user == null) {
                    return PremiumEmptyState(
                      icon: Icons.person_off_outlined,
                      title: 'Session requise',
                      message:
                          'Connectez-vous pour retrouver vos profils et votre sélection.',
                      actionLabel: 'Se connecter',
                      onAction: () => context.go(Routes.login),
                    );
                  }
                  return _ProfilesContent(userId: user.uid);
                },
                loading: () => const PremiumLoadingState(
                  title: 'Ouverture de votre espace',
                  message: 'Nous préparons vos profils.',
                ),
                error: (_, _) => PremiumErrorState(
                  title: 'Profils indisponibles',
                  message:
                      'Impossible de vérifier votre session pour le moment.',
                  onRetry: () => ref.invalidate(authStateProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilesContent extends ConsumerWidget {
  const _ProfilesContent({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(userProfilesProvider(userId));

    return profilesAsync.when(
      data: (profiles) => ResponsiveLayout(
        builder: (context, responsive) => Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.pagePadding,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorder(0.42)),
                    ),
                    child: const Icon(
                      Icons.local_movies_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'GUEZS FILMS',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.brandGoldLight,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Qui regarde ?',
                    textAlign: TextAlign.center,
                    style:
                        (responsive.isDesktop
                                ? AppTextStyles.displayMedium
                                : AppTextStyles.displaySmall)
                            .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez votre espace pour personnaliser la séance.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: responsive.isDesktop ? 42 : 30),
                  if (profiles.isEmpty)
                    _EmptyProfiles(
                      onCreate: () => _openProfileForm(context, ref),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: responsive.isDesktop ? 26 : 18,
                      runSpacing: 24,
                      children: [
                        ...profiles.map(
                          (profile) => _ProfileChoiceCard(
                            profile: profile,
                            onTap: () {
                              ref.read(activeProfileProvider.notifier).state =
                                  profile;
                              context.go(Routes.home);
                            },
                          ),
                        ),
                        _AddProfileCard(
                          onTap: () => _openProfileForm(context, ref),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  TextButton.icon(
                    onPressed: () => context.go(Routes.profile),
                    icon: const Icon(Icons.manage_accounts_outlined, size: 19),
                    label: const Text('Gérer les profils'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => const PremiumLoadingState(
        title: 'Chargement des profils',
        message: 'Votre espace arrive dans quelques instants.',
      ),
      error: (_, _) => PremiumErrorState(
        title: 'Profils indisponibles',
        message:
            'Impossible de charger les profils. Vérifiez votre connexion puis réessayez.',
        onRetry: () => ref.invalidate(userProfilesProvider(userId)),
      ),
    );
  }

  void _openProfileForm(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => ProfileFormSheet(
        userId: userId,
        onSaved: (profile) {
          Navigator.of(sheetContext).pop();
          ref.read(activeProfileProvider.notifier).state = profile;
          router.go(Routes.home);
        },
      ),
    );
  }
}

class _ProfileChoiceCard extends StatefulWidget {
  const _ProfileChoiceCard({required this.profile, required this.onTap});

  final UserProfileEntity profile;
  final VoidCallback onTap;

  @override
  State<_ProfileChoiceCard> createState() => _ProfileChoiceCardState();
}

class _ProfileChoiceCardState extends State<_ProfileChoiceCard> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovered || _focused;

    return Semantics(
      button: true,
      label: 'Choisir le profil ${widget.profile.name}',
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
            child: AnimatedScale(
              scale: _pressed ? 0.96 : (highlighted ? 1.035 : 1),
              duration: const Duration(milliseconds: 150),
              child: SizedBox(
                width: 118,
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: widget.profile.color,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: highlighted
                              ? AppColors.brandGoldLight
                              : AppColors.glassBorder(0.32),
                          width: highlighted ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.profile.color.withValues(alpha: 0.34),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _ProfileVisual(profile: widget.profile),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      widget.profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 5),
                    _ProfileTypeBadge(isKids: widget.profile.isKids),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileVisual extends StatelessWidget {
  const _ProfileVisual({required this.profile});

  final UserProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final value = profile.emoji;
    if (value.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.asset(
          value,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    if (value.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.network(
          value,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return Center(child: Text(value, style: const TextStyle(fontSize: 46)));
  }

  Widget _fallback() {
    return const Center(
      child: Icon(Icons.person_rounded, size: 46, color: Colors.white),
    );
  }
}

class _ProfileTypeBadge extends StatelessWidget {
  const _ProfileTypeBadge({required this.isKids});

  final bool isKids;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isKids
            ? AppColors.success.withValues(alpha: 0.13)
            : AppColors.brandBlue.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isKids
              ? AppColors.success.withValues(alpha: 0.34)
              : AppColors.glassBorder(0.26),
        ),
      ),
      child: Text(
        isKids ? 'Enfant' : 'Standard',
        style: AppTextStyles.labelSmall.copyWith(
          color: isKids ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 118,
        child: Column(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.glassBackground(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.glassBorder(0.32)),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 38,
                color: AppColors.brandGoldLight,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              'Ajouter',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfiles extends StatelessWidget {
  const _EmptyProfiles({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surfaceObsidian.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder(0.28)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.people_outline_rounded,
            size: 48,
            color: AppColors.brandGoldLight,
          ),
          const SizedBox(height: 15),
          Text('Aucun profil pour le moment', style: AppTextStyles.titleLarge),
          const SizedBox(height: 7),
          Text(
            'Créez un profil standard ou enfant pour commencer.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Créer un profil'),
          ),
        ],
      ),
    );
  }
}

class _SelectorBackdrop extends StatelessWidget {
  const _SelectorBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -160,
            right: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandBlue.withValues(alpha: 0.24),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGold.withValues(alpha: 0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
