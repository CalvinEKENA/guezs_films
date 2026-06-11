import '../constants/app_constants.dart';

class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobile = AppConstants.mobileBreakpoint;
  static const double tablet = AppConstants.tabletBreakpoint;
  static const double desktop = AppConstants.desktopBreakpoint;
  static const double wideDesktop = 1440;

  static bool isMobile(double width) => width < tablet;
  static bool isTablet(double width) => width >= tablet && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
  static bool isWideDesktop(double width) => width >= wideDesktop;
}
