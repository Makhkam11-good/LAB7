import 'package:flutter/material.dart';

import '../widgets/motion.dart';

void feedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}

Future<T?> openPage<T>(BuildContext context, Widget page) => Navigator.push<T>(
  context,
  PageRouteBuilder<T>(
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionDuration: motion(context, 380),
    reverseTransitionDuration: motion(context, 280),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(.045, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  ),
);
