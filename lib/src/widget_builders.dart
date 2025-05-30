import 'package:flutter/widgets.dart';
import '../responsive_builder2.dart';

typedef WidgetBuilder = Widget Function(BuildContext);
typedef WidgetBuilder2 = Widget Function(BuildContext, SizingInformation);

/// A widget with a builder that provides you with the sizingInformation
///
/// This widget is used by the ScreenTypeLayout to provide different widget builders
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    SizingInformation sizingInformation,
  ) builder;

  final ScreenBreakpoints? breakpoints;
  final RefinedBreakpoints? refinedBreakpoints;
  final bool? isWebOrDesktop;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
    this.breakpoints,
    this.refinedBreakpoints,
    this.isWebOrDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      final size = MediaQuery.sizeOf(context);
      final sizingInformation = SizingInformation(
        deviceScreenType: getDeviceType(
          size,
          breakpoints,
          isWebOrDesktop,
        ),
        refinedSize: getRefinedSize(
          size,
          refinedBreakpoint: refinedBreakpoints,
          isWebOrDesktop: isWebOrDesktop,
        ),
        screenSize: size,
        localWidgetSize:
            Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
      );
      return builder(context, sizingInformation);
    });
  }
}

enum OrientationLayoutBuilderMode {
  auto,
  landscape,
  portrait,
}

/// Provides a builder function for a landscape and portrait widget
class OrientationLayoutBuilder extends StatelessWidget {
  final WidgetBuilder? landscape;
  final WidgetBuilder portrait;
  final OrientationLayoutBuilderMode mode;

  const OrientationLayoutBuilder({
    Key? key,
    this.landscape,
    required this.portrait,
    this.mode = OrientationLayoutBuilderMode.auto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final orientation = MediaQuery.orientationOf(context);
        if (mode != OrientationLayoutBuilderMode.portrait &&
            (orientation == Orientation.landscape ||
                mode == OrientationLayoutBuilderMode.landscape)) {
          if (landscape != null) {
            return landscape!(context);
          }
        }

        return portrait(context);
      },
    );
  }
}

/// Provides a builder function for different screen types
///
/// Each builder will get built based on the current device width.
/// [breakpoints] define your own custom device resolutions
/// [watch] will be built and shown when width is less than 300
/// [mobile] will be built when width greater than 300
/// [tablet] will be built when width is greater than 600
/// [desktop] will be built if width is greater than 950
class ScreenTypeLayout extends StatelessWidget {
  final ScreenBreakpoints? breakpoints;
  final bool? isWebOrDesktop;

  final WidgetBuilder? watch;
  final WidgetBuilder2? watch2;

  final WidgetBuilder? mobile;
  final WidgetBuilder2? phone2;

  final WidgetBuilder? tablet;
  final WidgetBuilder2? tablet2;

  final WidgetBuilder? desktop;
  final WidgetBuilder2? desktop2;

  @Deprecated(
    'Use ScreenTypeLayout.builder instead for performance improvements',
  )
  ScreenTypeLayout({
    Key? key,
    this.breakpoints,
    this.isWebOrDesktop = null,
    Widget? watch,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  })  : this.watch = _builderOrNull(watch),
        this.watch2 = null,
        this.mobile = _builderOrNull(mobile)!,
        this.phone2 = null,
        this.tablet = _builderOrNull(tablet),
        this.tablet2 = null,
        this.desktop = _builderOrNull(desktop),
        this.desktop2 = null,
        super(key: key) {
    _checkIfMobileOrDesktopIsSupplied();
  }

  @Deprecated(
      'Use ScreenTypeLayout.builder instead for performance improvements')
  static WidgetBuilder? _builderOrNull(Widget? widget) {
    return widget == null ? null : (BuildContext context) => widget;
  }

  ScreenTypeLayout.builder({
    Key? key,
    this.breakpoints,
    this.isWebOrDesktop = null,
    this.watch,
    this.mobile,
    this.tablet,
    this.desktop,
  })  : this.watch2 = null,
        this.phone2 = null,
        this.tablet2 = null,
        this.desktop2 = null,
        super(key: key) {
    _checkIfMobileOrDesktopIsSupplied();
  }

  ScreenTypeLayout.builder2({
    Key? key,
    this.breakpoints,
    this.isWebOrDesktop = null,
    WidgetBuilder2? watch,
    WidgetBuilder2? phone,
    WidgetBuilder2? tablet,
    WidgetBuilder2? desktop,
  })  : this.watch = null,
        this.watch2 = watch,
        this.mobile = null,
        this.phone2 = phone,
        this.tablet = null,
        this.tablet2 = tablet,
        this.desktop = null,
        this.desktop2 = desktop,
        super(key: key) {
    _checkIfMobileOrDesktopIsSupplied();
  }

  void _checkIfMobileOrDesktopIsSupplied() {
    final hasMobileLayout = mobile != null || phone2 != null;
    final hasDesktopLayout = desktop != null || desktop2 != null;

    assert(
      hasMobileLayout || hasDesktopLayout,
      'You should supply either a mobile layout or a desktop layout. '
      'If you don\'t need two layouts then remove this widget and use the '
      'widget you want to use directly. ',
    );
  }

  bool _usingBuilder2() {
    return watch2 != null ||
        phone2 != null ||
        tablet2 != null ||
        desktop2 != null;
  }

  /// Builds the widget tree for the [ScreenTypeLayout].
  ///
  /// This method uses a [ResponsiveBuilder] to determine the current screen's
  /// sizing information and selects the appropriate widget builder based on
  /// the device type (watch, mobile, tablet, desktop) and the provided
  /// breakpoints. It first attempts to use a simple [WidgetBuilder] (if
  /// provided), and if none is available for the current device type, it falls
  /// back to a [WidgetBuilder2] (if provided) for more granular control.
  ///
  /// Throws an assertion error if neither a mobile nor a desktop layout is supplied.
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      breakpoints: breakpoints,
      isWebOrDesktop: isWebOrDesktop,
      builder: (context, sizingInformation) {
        if (_usingBuilder2()) {
          return _handleWidgetBuilder2(context, sizingInformation)!;
        }
        return _handleWidgetBuilder(context, sizingInformation)!;
      },
    );
  }

  Widget? _handleWidgetBuilder(
      BuildContext context, SizingInformation sizingInformation) {
    if (ResponsiveAppUtil.preferDesktop) {
      return desktop?.call(context) ?? mobile!(context);
    }

    // If we're at desktop size
    if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
      // If we have supplied the desktop layout then display that
      if (desktop != null) return desktop!(context);
      // If no desktop layout is supplied we want to check if we have the size below it and display that
      if (tablet != null) return tablet!(context);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      if (tablet != null) return tablet!(context);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.watch &&
        watch != null) {
      return watch!(context);
    }

    return mobile?.call(context);
  }

  Widget? _handleWidgetBuilder2(
      BuildContext context, SizingInformation sizingInformation) {
    if (ResponsiveAppUtil.preferDesktop) {
      return desktop2?.call(context, sizingInformation) ??
          phone2!(context, sizingInformation);
    }

    // If we're at desktop size
    if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
      // If we have supplied the desktop layout then display that
      if (desktop2 != null) return desktop2!(context, sizingInformation);
      // If no desktop layout is supplied we want to check if we have the size below it and display that
      if (tablet2 != null) return tablet2!(context, sizingInformation);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      if (tablet2 != null) return tablet2!(context, sizingInformation);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.watch &&
        watch2 != null) {
      return watch2!(context, sizingInformation);
    }

    return phone2?.call(context, sizingInformation);
  }
}

/// Provides a builder function for refined screen sizes to be used with [ScreenTypeLayout]
///
/// Each builder will get built based on the current device width.
/// [breakpoints] define your own custom device resolutions
/// [extraLarge] will be built if width is greater than 2160 on Desktops, 1280 on Tablets, and 600 on Mobiles
/// [large] will be built when width is greater than 1440 on Desktops, 1024 on Tablets, and 414 on Mobiles
/// [normal] will be built when width is greater than 1080 on Desktops, 768 on Tablets, and 375 on Mobiles
/// [small] will be built if width is less than 720 on Desktops, 600 on Tablets, and 320 on Mobiles
class RefinedLayoutBuilder extends StatelessWidget {
  final RefinedBreakpoints? refinedBreakpoints;
  final bool? isWebOrDesktop;

  final WidgetBuilder? extraLarge;
  final WidgetBuilder? large;
  final WidgetBuilder normal;
  final WidgetBuilder? small;

  const RefinedLayoutBuilder({
    Key? key,
    this.refinedBreakpoints,
    this.isWebOrDesktop,
    this.extraLarge,
    this.large,
    required this.normal,
    this.small,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      refinedBreakpoints: refinedBreakpoints,
      isWebOrDesktop: isWebOrDesktop,
      builder: (context, sizingInformation) {
        // If we're at extra large size
        if (sizingInformation.refinedSize == RefinedSize.extraLarge) {
          // If we have supplied the extra large layout then display that
          if (extraLarge != null) return extraLarge!(context);
          // If no extra large layout is supplied we want to check if we have the size below it and display that
          if (large != null) return large!(context);
        }

        if (sizingInformation.refinedSize == RefinedSize.large) {
          // If we have supplied the large layout then display that
          if (large != null) return large!(context);
          // If no large layout is supplied we want to check if we have the size below it and display that
          return normal(context);
        }

        if (sizingInformation.refinedSize == RefinedSize.small) {
          // If we have supplied the small layout then display that
          if (small != null) return small!(context);
        }

        // If none of the layouts above are supplied or we're on the small size layout then we show the small layout
        return normal(context);
      },
    );
  }
}
