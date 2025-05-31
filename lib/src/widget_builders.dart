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
/// [_breakpoints] define your own custom device resolutions
/// [_watch] will be built and shown when width is less than 300
/// [_mobile] will be built when width greater than 300
/// [_tablet] will be built when width is greater than 600
/// [_desktop] will be built if width is greater than 950
class ScreenTypeLayout extends StatelessWidget {
  final ScreenBreakpoints? _breakpoints;
  final bool? _isWebOrDesktop;

  final WidgetBuilder? _watch;
  final WidgetBuilder2? _watch2;

  final WidgetBuilder? _mobile;
  final WidgetBuilder2? _phone2;

  final WidgetBuilder? _tablet;
  final WidgetBuilder2? _tablet2;

  final WidgetBuilder? _desktop;
  final WidgetBuilder2? _desktop2;

  @Deprecated(
    'Use ScreenTypeLayout.builder instead for performance improvements',
  )
  ScreenTypeLayout({
    Key? key,
    ScreenBreakpoints? breakpoints,
    bool? isWebOrDesktop = null,
    Widget? watch,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  })  : this._breakpoints = breakpoints, 
        this._isWebOrDesktop = isWebOrDesktop, 
        this._watch = _builderOrNull(watch),
        this._watch2 = null,
        this._mobile = _builderOrNull(mobile)!,
        this._phone2 = null,
        this._tablet = _builderOrNull(tablet),
        this._tablet2 = null,
        this._desktop = _builderOrNull(desktop),
        this._desktop2 = null,
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
    ScreenBreakpoints? breakpoints,
    bool? isWebOrDesktop = null,
    Widget Function(BuildContext)? watch,
    Widget Function(BuildContext)? mobile,
    Widget Function(BuildContext)? tablet,
    Widget Function(BuildContext)? desktop,
  })  : this._breakpoints = breakpoints, 
        this._isWebOrDesktop = isWebOrDesktop, 
        this._desktop = desktop, 
        this._tablet = tablet, 
        this._mobile = mobile, 
        this._watch = watch, 
        this._watch2 = null,
        this._phone2 = null,
        this._tablet2 = null,
        this._desktop2 = null,
        super(key: key) {
    _checkIfMobileOrDesktopIsSupplied();
  }

  ScreenTypeLayout.builder2({
    Key? key,
    ScreenBreakpoints? breakpoints,
    bool? isWebOrDesktop = null,
    WidgetBuilder2? watch,
    WidgetBuilder2? phone,
    WidgetBuilder2? tablet,
    WidgetBuilder2? desktop,
  })  : this._breakpoints = breakpoints, 
        this._isWebOrDesktop = isWebOrDesktop, 
        this._watch = null,
        this._watch2 = watch,
        this._mobile = null,
        this._phone2 = phone,
        this._tablet = null,
        this._tablet2 = tablet,
        this._desktop = null,
        this._desktop2 = desktop,
        super(key: key) {
    _checkIfMobileOrDesktopIsSupplied();
  }

  void _checkIfMobileOrDesktopIsSupplied() {
    final hasMobileLayout = _mobile != null || _phone2 != null;
    final hasDesktopLayout = _desktop != null || _desktop2 != null;

    assert(
      hasMobileLayout || hasDesktopLayout,
      'You should supply either a mobile layout or a desktop layout. '
      'If you don\'t need two layouts then remove this widget and use the '
      'widget you want to use directly. ',
    );
  }

  bool _usingBuilder2() {
    return _watch2 != null ||
        _phone2 != null ||
        _tablet2 != null ||
        _desktop2 != null;
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
      breakpoints: _breakpoints,
      isWebOrDesktop: _isWebOrDesktop,
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
      return _desktop?.call(context) ?? _mobile!(context);
    }

    // If we're at desktop size
    if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
      // If we have supplied the desktop layout then display that
      if (_desktop != null) return _desktop!(context);
      // If no desktop layout is supplied we want to check if we have the size below it and display that
      if (_tablet != null) return _tablet!(context);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      if (_tablet != null) return _tablet!(context);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.watch &&
        _watch != null) {
      return _watch!(context);
    }

    return _mobile?.call(context);
  }

  Widget? _handleWidgetBuilder2(
      BuildContext context, SizingInformation sizingInformation) {
    if (ResponsiveAppUtil.preferDesktop) {
      return _desktop2?.call(context, sizingInformation) ??
          _phone2!(context, sizingInformation);
    }

    // If we're at desktop size
    if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
      // If we have supplied the desktop layout then display that
      if (_desktop2 != null) return _desktop2!(context, sizingInformation);
      // If no desktop layout is supplied we want to check if we have the size below it and display that
      if (_tablet2 != null) return _tablet2!(context, sizingInformation);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
      if (_tablet2 != null) return _tablet2!(context, sizingInformation);
    }

    if (sizingInformation.deviceScreenType == DeviceScreenType.watch &&
        _watch2 != null) {
      return _watch2!(context, sizingInformation);
    }

    return _phone2?.call(context, sizingInformation);
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
