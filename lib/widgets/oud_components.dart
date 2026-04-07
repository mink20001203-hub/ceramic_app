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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            fontWeight: FontWeight.w900,
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
        color: const Color(0xFFF2EFEA),
        borderRadius: OudRadii.pill,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperCircleIcon(
            icon: Icons.remove,
            onTap: onMinus,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: OudColors.text,
              ),
            ),
          ),
          _StepperCircleIcon(
            icon: Icons.add,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _StepperCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperCircleIcon({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? OudColors.border : OudColors.mutedText,
        ),
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
