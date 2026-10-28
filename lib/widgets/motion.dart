import 'package:flutter/material.dart';

Duration motion(BuildContext context, [int ms = 320]) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : Duration(milliseconds: ms);

class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: motion(context, 550),
    curve: Curves.easeOutCubic,
    builder: (_, v, child) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
    ),
    child: child,
  );
}

class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child});
  final Widget child;
  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => pressed = true),
    onPointerUp: (_) => setState(() => pressed = false),
    onPointerCancel: (_) => setState(() => pressed = false),
    child: AnimatedScale(
      scale: pressed ? .975 : 1,
      duration: motion(context, 130),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}
