// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double textScaleFactor;

  // Safe Area dimensions
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  // Device type
  static late bool isTablet;
  static late bool isPhone;
  static late Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    textScaleFactor = _mediaQueryData.textScaleFactor;

    // Block sizes (1% of screen)
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Safe area dimensions
    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    // Device type detection
    isTablet = screenWidth >= 600;
    isPhone = screenWidth < 600;

    // Default size for consistent spacing
    defaultSize = orientation == Orientation.landscape
        ? screenHeight * 0.024
        : screenWidth * 0.024;
  }

  // Get proportional height according to screen size
  static double getProportionateScreenHeight(double inputHeight) {
    double screenHeight = SizeConfig.screenHeight;
    // 812 is the layout height that designer use
    return (inputHeight / 812.0) * screenHeight;
  }

  // Get proportional width according to screen size
  static double getProportionateScreenWidth(double inputWidth) {
    double screenWidth = SizeConfig.screenWidth;
    // 375 is the layout width that designer use
    return (inputWidth / 375.0) * screenWidth;
  }

  // Returns a size based on device type
  static double adaptiveFontSize(double phoneSize, {double? tabletSize}) {
    return isTablet
        ? (tabletSize ?? phoneSize * 1.25)
        : phoneSize;
  }

  // Returns a size based on orientation
  static double orientationBasedSize(double portraitSize, double landscapeSize) {
    return orientation == Orientation.portrait
        ? portraitSize
        : landscapeSize;
  }

  // Returns a size that scales with the screen width
  static double widthScaledSize(double size) {
    return size * blockSizeHorizontal;
  }

  // Returns a size that scales with the screen height
  static double heightScaledSize(double size) {
    return size * blockSizeVertical;
  }

  // Get bottom padding for safe area (for bottom navigation bars)
  static double get bottomPadding => _mediaQueryData.padding.bottom;

  // Get top padding for safe area (for status bar)
  static double get topPadding => _mediaQueryData.padding.top;

  // Check if device is in dark mode
  static bool get isDarkMode => _mediaQueryData.platformBrightness == Brightness.dark;
}