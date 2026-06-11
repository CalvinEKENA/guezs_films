import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../responsive/responsive_values.dart';
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
    final responsive = ResponsiveValues.of(context);

    if (responsive.shouldUseNavigationRail) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _AdaptiveSideNavigation(
              destinations: _destinations,
              extended: responsive.isDesktop,
              width: responsive.navigationRailWidth,
            ),
            Expanded(child: _ShellBody(child: child)),
          ],
        ),
      );
    }

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

class _AdaptiveSideNavigation extends StatelessWidget {
  const _AdaptiveSideNavigation({
    required this.destinations,
    required this.extended,
    required this.width,
  });

  final List<_MainNavDestination> destinations;
  final bool extended;
  final double width;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.bgCinemaDark.withValues(alpha: 0.96),
        border: Border(
          right: BorderSide(color: AppColors.glassBorder(0.18), width: 0.8),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 14 : 10,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: extended
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              _SideBrand(extended: extended),
              const SizedBox(height: 28),
              ...destinations.map(
                (destination) => _SideNavItem(
                  destination: destination,
                  extended: extended,
                  isActive: location == destination.route,
                  onTap: () => context.go(destination.route),
                ),
              ),
              const Spacer(),
              if (extended)
                Text(
                  'GUEZS FILMS',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideBrand extends StatelessWidget {
  const _SideBrand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder(0.32)),
      ),
      child: const Icon(
        Icons.local_movies_rounded,
        color: AppColors.textOnBlue,
        size: 22,
      ),
    );

    if (!extended) return logo;

    return Row(
      children: [
        logo,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Guezs\nFilms',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
                          color: AppColors.accentSoft.withValues(alpha: 0.45),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            Icon(
              isActive ? destination.activeIcon : destination.icon,
              color: isActive ? AppColors.accentSoft : AppColors.textTertiary,
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
                color: isActive ? AppColors.accentSoft : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  const _SideNavItem({
    required this.destination,
    required this.extended,
    required this.isActive,
    required this.onTap,
  });

  final _MainNavDestination destination;
  final bool extended;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.isActive || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(
            horizontal: widget.extended ? 14 : 0,
            vertical: 12,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accent.withValues(alpha: 0.14)
                : (_hovered
                      ? AppColors.glassBackground(0.22)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.glassBorder(0.42)
                  : Colors.transparent,
              width: 0.8,
            ),
          ),
          child: widget.extended
              ? Row(
                  children: [
                    Icon(
                      widget.isActive
                          ? widget.destination.activeIcon
                          : widget.destination.icon,
                      color: highlighted
                          ? AppColors.accentSoft
                          : AppColors.textTertiary,
                      size: 21,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: highlighted
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(
                  widget.isActive
                      ? widget.destination.activeIcon
                      : widget.destination.icon,
                  color: highlighted
                      ? AppColors.accentSoft
                      : AppColors.textTertiary,
                  size: 22,
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
