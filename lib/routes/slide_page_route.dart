import 'package:flutter/material.dart';

/// A [PageRouteBuilder] that slides the incoming page in from the right.
///
/// Forward: new page slides in from right; the previous page stays in place.
/// Back (pop): the page reverses back to the right; the previous page is
/// already there underneath — no black gap, no simultaneous movement.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  SlidePageRoute({required Widget page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        );
}
