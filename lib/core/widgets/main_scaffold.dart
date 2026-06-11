import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/route_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'offline_banner.dart';

/// Main scaffold with premium Cupertino-luxurious bottom navigation bar
/// Contains the shell for home, search, favorites, downloads, and profile tabs
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          const Positioned(top: 0, left: 0, right: 0, child: OfflineBanner()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                color: AppColors.accentSoft.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: CupertinoIcons.house,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Accueil',
                    isActive: location == Routes.home,
                    onTap: () => context.go(Routes.home),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: CupertinoIcons.search,
                    activeIcon: CupertinoIcons.search,
                    label: 'Recherche',
                    isActive: location == Routes.search,
                    onTap: () => context.go(Routes.search),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: CupertinoIcons.bookmark,
                    activeIcon: CupertinoIcons.bookmark_fill,
                    label: 'Ma liste',
                    isActive: location == Routes.favorites,
                    onTap: () => context.go(Routes.favorites),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: CupertinoIcons.arrow_down_circle,
                    activeIcon: CupertinoIcons.arrow_down_circle_fill,
                    label: 'Téléchargements',
                    isActive: location == Routes.downloads,
                    onTap: () => context.go(Routes.downloads),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: CupertinoIcons.person,
                    activeIcon: CupertinoIcons.person_fill,
                    label: 'Profil',
                    isActive: location == Routes.profile,
                    onTap: () => context.go(Routes.profile),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active indicator bar (golden)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isActive ? 24 : 0,
              height: 2.5,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accentSoft.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            // Icon with subtle golden glow when active
            Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentSoft.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color: isActive ? AppColors.accentSoft : AppColors.textTertiary,
                    size: 23,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.overline.copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.accentSoft : AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
