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

class OudSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const OudSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: OudTypography.sectionTitle),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
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
      decoration: const BoxDecoration(
        color: Color(0xFFF2EFEA),
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

class OudStepTitle extends StatelessWidget {
  final int step;
  final String title;

  const OudStepTitle({
    super.key,
    required this.step,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: OudColors.primary,
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(title, style: OudTypography.sectionTitle),
        ],
      ),
    );
  }
}

class OudAmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final bool dark;

  const OudAmountRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = dark
        ? (emphasize ? Colors.white : OudColors.panelDarkMutedText)
        : (emphasize ? OudColors.text : OudColors.mutedText);
    final valueColor = dark
        ? (emphasize ? OudColors.panelDarkAccent : Colors.white)
        : (emphasize ? OudColors.primary : OudColors.text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              fontSize: emphasize ? 20 : 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? (dark ? 28 : 34) : 18,
            ),
          ),
        ],
      ),
    );
  }
}

class OudMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final VoidCallback onTap;

  const OudMenuTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: OudRadii.lg,
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: OudColors.border),
              borderRadius: OudRadii.lg,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconBg,
                  child: Icon(icon, size: 16, color: OudColors.text),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: OudColors.mutedText,
                ),
              ],
            ),
          ),
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

class OudLoadingState extends StatelessWidget {
  final String title;
  final String subtitle;

  const OudLoadingState({
    super.key,
    this.title = '불러오는 중입니다',
    this.subtitle = '잠시만 기다려 주세요.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OudSpace.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: OudColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: OudColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class OudFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const OudFadeSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}

class OudTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const OudTapScale({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<OudTapScale> createState() => _OudTapScaleState();
}

class _OudTapScaleState extends State<OudTapScale> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        scale: _pressed ? 0.985 : 1,
        child: widget.child,
      ),
    );
  }
}
