import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/route_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'offline_banner.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _MainNavDestination(
      route: Routes.home,
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Accueil',
    ),
    _MainNavDestination(
      route: Routes.search,
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
      label: 'Recherche',
    ),
    _MainNavDestination(
      route: Routes.favorites,
      icon: CupertinoIcons.bookmark,
      activeIcon: CupertinoIcons.bookmark_fill,
      label: 'Ma liste',
    ),
    _MainNavDestination(
      route: Routes.downloads,
      icon: CupertinoIcons.arrow_down_circle,
      activeIcon: CupertinoIcons.arrow_down_circle_fill,
      label: 'Téléchargements',
    ),
    _MainNavDestination(
      route: Routes.profile,
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _ShellBody(child: child),
      bottomNavigationBar: const _MobileBottomNavigation(
        destinations: _destinations,
      ),
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        const Positioned(top: 0, left: 0, right: 0, child: OfflineBanner()),
      ],
    );
  }
}

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation({required this.destinations});

  final List<_MainNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.78),
            border: Border(
              top: BorderSide(
                color: AppColors.accentSoft.withValues(alpha: 0.12),
                width: 0.6,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: destinations
                  .map(
                    (destination) => Expanded(
                      child: _BottomNavItem(
                        destination: destination,
                        isActive: location == destination.route,
                        onTap: () => context.go(destination.route),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final _MainNavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
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
                              color: AppColors.accentSoft.withValues(
                                alpha: 0.45,
                              ),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                Icon(
                  isActive ? destination.activeIcon : destination.icon,
                  color: isActive
                      ? AppColors.accentSoft
                      : AppColors.textTertiary,
                  size: 23,
                ),
                const SizedBox(height: 4),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? AppColors.accentSoft
                        : AppColors.textTertiary,
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

class _MainNavDestination {
  const _MainNavDestination({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
