import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_tokens.dart';

class OudSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const OudSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(OudSpace.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OudColors.card,
        borderRadius: OudRadii.lg,
        border: Border.all(color: OudColors.border),
      ),
      padding: padding,
      child: child,
    );
  }
}

class OudTag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const OudTag({
    super.key,
    required this.label,
    this.bgColor = OudColors.surface,
    this.textColor = OudColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: OudRadii.pill),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class OudPriceText extends StatelessWidget {
  final int price;
  final int? original;
  final bool highlight;

  const OudPriceText({
    super.key,
    required this.price,
    this.original,
    this.highlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'ko_KR');
    final color = highlight ? OudColors.primary : OudColors.text;

    return Row(
      children: [
        Text(
          '₩${format.format(price)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        if (original != null) ...[
          const SizedBox(width: 8),
          Text(
            '₩${format.format(original)}',
            style: const TextStyle(
              color: OudColors.mutedText,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class OudQuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const OudQuantityStepper({
    super.key,
    required this.value,
    this.onMinus,
    this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OudColors.surface,
        borderRadius: OudRadii.pill,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline),
            color: OudColors.mutedText,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: OudColors.text,
              ),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline),
            color: OudColors.mutedText,
          ),
        ],
      ),
    );
  }
}

class OudEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const OudEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OudSpace.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: OudColors.surface,
              child: Icon(icon, color: OudColors.mutedText, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OudColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: OudColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
