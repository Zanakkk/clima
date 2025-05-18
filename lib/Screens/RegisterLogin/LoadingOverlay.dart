// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color overlayColor;
  final Color indicatorColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor = Colors.black,
    required this.indicatorColor,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Stack(
      children: [
        // Main content
        child,

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor.withOpacity(opacity),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular progress indicator
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: indicatorColor,
                        strokeWidth: 3,
                      ),
                    ),

                    // Optional message
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            message!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// A more advanced version with animation
class AnimatedLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color overlayColor;
  final Color indicatorColor;
  final double opacity;
  final Duration animationDuration;

  const AnimatedLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor = Colors.black,
    required this.indicatorColor,
    this.opacity = 0.5,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Stack(
      children: [
        // Main content
        child,

        // Animated loading overlay
        AnimatedSwitcher(
          duration: animationDuration,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: isLoading
              ? Container(
                  key: const ValueKey('loading'),
                  color: overlayColor.withOpacity(opacity),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circular progress indicator
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            color: indicatorColor,
                            strokeWidth: 3,
                          ),
                        ),

                        // Optional message
                        if (message != null) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                message!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('not_loading')),
        ),
      ],
    );
  }
}
