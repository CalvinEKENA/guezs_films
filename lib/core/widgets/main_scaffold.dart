import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/route_constants.dart';
import '../theme/app_colors.dart';
import 'offline_banner.dart';

/// Main scaffold with bottom navigation bar
/// Contains the shell for home, search, downloads, and profile tabs
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

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Accueil',
              isActive: location == Routes.home,
              onTap: () => context.go(Routes.home),
            ),
            _NavItem(
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: 'Recherche',
              isActive: location == Routes.search,
              onTap: () => context.go(Routes.search),
            ),
            _NavItem(
              icon: Icons.bookmark_outline,
              activeIcon: Icons.bookmark,
              label: 'Ma liste',
              isActive: location == Routes.favorites,
              onTap: () => context.go(Routes.favorites),
            ),
            _NavItem(
              icon: Icons.download_for_offline_outlined,
              activeIcon: Icons.download_for_offline,
              label: 'Téléchargements',
              isActive: location == Routes.downloads,
              onTap: () => context.go(Routes.downloads),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
              isActive: location == Routes.profile,
              onTap: () => context.go(Routes.profile),
            ),
          ],
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
