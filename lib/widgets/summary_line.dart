import 'package:flutter/material.dart';

class SummaryLine extends StatelessWidget {
  const SummaryLine(this.label, this.value, {super.key, this.strong = false});
  final String label, value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: strong ? 18 : 13,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: strong ? 22 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
