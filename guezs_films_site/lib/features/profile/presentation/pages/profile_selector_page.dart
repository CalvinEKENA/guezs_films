import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/profile_form_sheet.dart';

/// Netflix-style luxurious profile selector shown after login
class ProfileSelectorPage extends ConsumerWidget {
  const ProfileSelectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final userId = user?.uid ?? '';
    final profilesAsync = ref.watch(userProfilesProvider(userId));

    return Scaffold(
      backgroundColor: Colors.black, // Dark background as base
      body: profilesAsync.when(
        data: (profiles) => _buildContent(context, ref, userId, profiles),
        loading: () => const Center(
          child: CupertinoActivityIndicator(color: AppColors.accentSoft, radius: 16),
        ),
        error: (err, stack) => _buildContent(context, ref, userId, []),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String userId,
    List<UserProfileEntity> profiles,
  ) {
    // Dynamic AI background based on user's prompt
    final String prompt = Uri.encodeComponent('A beautiful light-skinned African woman with longer hair, sad, dramatic look, slightly black and white, classic movie image style, cinematic portrait');
    final String posterUrl = 'https://image.pollinations.ai/prompt/$prompt?width=1200&height=1800&nologo=true';

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Cinematic Poster Background
        Image.network(
          posterUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ).animate().fadeIn(duration: 800.ms),

        // 2. Gradient Overlay (Fades to black at the bottom to match the model)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.7, 1.0],
              colors: [
                Colors.black12,
                Colors.black45,
                Colors.black87,
                Colors.black,
              ],
            ),
          ),
        ),

        // 3. Foreground Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(flex: 2),

              // "GUEZS FILMS" / "NETFLIX" Top Red Text
              Text(
                'GUEZS FILMS',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary, // Red color like Netflix
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 4),

              // Big Cinematic Title
              Text(
                'LA FEMME\nDU MBENGUISTE',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat', // Using brand font
                  fontSize: 42,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Drame passionnel : le 06 Juin',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const Spacer(flex: 1),

              // "Choisissez votre profil" text
              Text(
                'Choisissez votre profil',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: 20),

              // Profiles Grid
              SizedBox(
                height: 220, // Pre-allocate height
                child: Center(
                  child: profiles.isEmpty
                      ? _buildEmptyState(context, ref, userId)
                      : _buildProfileGrid(context, ref, userId, profiles),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileGrid(
    BuildContext context,
    WidgetRef ref,
    String userId,
    List<UserProfileEntity> profiles,
  ) {
    // Layout logic: if 3 items or less, center them. If more, wrap.
    // The items include the 'Modifier' button at the end.
    final allItems = [...profiles, 'modifier'];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 24,
      children: allItems.map((item) {
        final index = allItems.indexOf(item);
        Widget widget;
        
        if (item is String && item == 'modifier') {
          widget = _buildModifierButton(context, userId);
        } else {
          widget = _buildProfileCard(context, ref, item as UserProfileEntity);
        }

        return widget
            .animate()
            .fadeIn(delay: Duration(milliseconds: 500 + (80 * index)), duration: 350.ms)
            .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1));
      }).toList(),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    UserProfileEntity profile,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(activeProfileProvider.notifier).state = profile;
        context.go(Routes.home);
      },
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Netflix-style squarcle avatar without borders
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: profile.color,
                image: profile.emoji.startsWith('assets/') || profile.emoji.startsWith('http')
                    ? DecorationImage(
                        image: profile.emoji.startsWith('http') 
                            ? NetworkImage(profile.emoji) as ImageProvider
                            : AssetImage(profile.emoji),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Center(
                child: (!profile.emoji.startsWith('assets/') && !profile.emoji.startsWith('http')) 
                  ? Text(
                      profile.emoji,
                      style: const TextStyle(fontSize: 40),
                    )
                  : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openProfileForm(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ProfileFormSheet(
        userId: userId,
        onSaved: (profile) {
          Navigator.of(context, rootNavigator: true).pop();
          ref.read(activeProfileProvider.notifier).state = profile;
          Future.microtask(() {
            context.go(Routes.home);
          });
        },
      ),
    );
  }

  Widget _buildModifierButton(BuildContext context, String userId) {
    return Consumer(
      builder: (context, ref, child) {
        return GestureDetector(
          onTap: () => _openProfileForm(context, ref, userId),
          child: SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.2), // Dark grey like Netflix
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.pencil,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Modifier',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, String userId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _openProfileForm(context, ref, userId),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajouter un profil',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
