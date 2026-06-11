import 'package:flutter/widgets.dart';

import 'responsive_values.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, ResponsiveValues responsive);

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.builder});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaSize.width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mediaSize.height;

        return builder(context, ResponsiveValues.fromSize(Size(width, height)));
      },
    );
  }
}

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveValues.of(context);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? responsive.maxContentWidth,
        ),
        child: Padding(padding: padding ?? responsive.pageInsets, child: child),
      ),
    );
  }
}
