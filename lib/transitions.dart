import 'package:flutter/material.dart';

abstract class SophisticatedTransitionBuilder extends PageTransitionsBuilder {
  const SophisticatedTransitionBuilder();
  static Map<TargetPlatform, SophisticatedTransitionBuilder> uniform(
    SophisticatedTransitionBuilder builder,
  ) {
    return {for (final platform in TargetPlatform.values) platform: builder};
  }
}

class ExaggeratedSwipeTransitionBuilder extends SophisticatedTransitionBuilder {
  const ExaggeratedSwipeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeIn = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    final slideIn = Tween<Offset>(
      begin: const Offset(0.05, 0), // slight shift right
      end: Offset.zero,
    ).animate(fadeIn);

    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeIn,
    );

    return Stack(
      children: [
        FadeTransition(
          opacity: fadeOut,
          child: const ColoredBox(color: Colors.white),
        ),
        SlideTransition(
          position: slideIn,
          child: FadeTransition(opacity: fadeIn, child: child),
        ),
      ],
    );
  }
}
