import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';
import 'responsive_breakpoints.dart';

class ResponsiveValues {
  const ResponsiveValues({
    required this.width,
    required this.height,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isWideDesktop,
    required this.pagePadding,
    required this.maxContentWidth,
    required this.posterColumns,
    required this.posterWidth,
    required this.gridGap,
    required this.shouldUseNavigationRail,
    required this.shouldUseBottomNavigation,
  });

  factory ResponsiveValues.fromSize(Size size) {
    final width = size.width;
    final isMobile = ResponsiveBreakpoints.isMobile(width);
    final isTablet = ResponsiveBreakpoints.isTablet(width);
    final isDesktop = ResponsiveBreakpoints.isDesktop(width);
    final isWideDesktop = ResponsiveBreakpoints.isWideDesktop(width);

    final pagePadding = isWideDesktop
        ? 72.0
        : isDesktop
        ? 64.0
        : isTablet
        ? 32.0
        : 16.0;
    final maxContentWidth = isWideDesktop
        ? 1360.0
        : isDesktop
        ? 1200.0
        : isTablet
        ? 1080.0
        : double.infinity;
    final gridGap = isDesktop
        ? 20.0
        : isTablet
        ? 16.0
        : 12.0;
    final posterColumns = _posterColumnsForWidth(width);
    final availableWidth = maxContentWidth.isFinite
        ? width.clamp(0, maxContentWidth).toDouble()
        : width;
    final posterWidth =
        (availableWidth - (pagePadding * 2) - (gridGap * (posterColumns - 1))) /
        posterColumns;

    return ResponsiveValues(
      width: width,
      height: size.height,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      isWideDesktop: isWideDesktop,
      pagePadding: pagePadding,
      maxContentWidth: maxContentWidth,
      posterColumns: posterColumns,
      posterWidth: posterWidth.clamp(112.0, isDesktop ? 196.0 : 168.0),
      gridGap: gridGap,
      shouldUseNavigationRail: width >= ResponsiveBreakpoints.tablet,
      shouldUseBottomNavigation: width < ResponsiveBreakpoints.tablet,
    );
  }

  factory ResponsiveValues.of(BuildContext context) {
    return ResponsiveValues.fromSize(MediaQuery.sizeOf(context));
  }

  final double width;
  final double height;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isWideDesktop;
  final double pagePadding;
  final double maxContentWidth;
  final int posterColumns;
  final double posterWidth;
  final double gridGap;
  final bool shouldUseNavigationRail;
  final bool shouldUseBottomNavigation;

  double get railPosterWidth {
    if (isWideDesktop) return 184;
    if (isDesktop) return 176;
    if (isTablet) return 150;
    return width >= 420 ? 138 : 128;
  }

  double get contentWidth {
    if (!maxContentWidth.isFinite) return width;
    return width.clamp(0, maxContentWidth).toDouble();
  }

  EdgeInsets get pageInsets => EdgeInsets.symmetric(horizontal: pagePadding);
  EdgeInsets get sliverPageInsets =>
      EdgeInsets.fromLTRB(pagePadding, 0, pagePadding, 0);

  int get loadingCardCount {
    if (isWideDesktop) return 7;
    if (isDesktop) return 6;
    if (isTablet) return 5;
    return 4;
  }

  double get navigationRailWidth => isDesktop ? 244 : 88;
}

int _posterColumnsForWidth(double width) {
  if (width >= 1440) return 7;
  if (width >= AppConstants.desktopBreakpoint) return 6;
  if (width >= 1024) return 5;
  if (width >= AppConstants.tabletBreakpoint) return 4;
  if (width >= 430) return 3;
  return 2;
}
