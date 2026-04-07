import 'package:flutter/material.dart';

class OudColors {
  static const Color bg = Color(0xFFF5F2ED);
  static const Color surface = Color(0xFFEFEBE5);
  static const Color card = Colors.white;
  static const Color primary = Color(0xFFAA4E36);
  static const Color primarySoft = Color(0xFFF1D4CB);
  static const Color sage = Color(0xFFCFE4BF);
  static const Color text = Color(0xFF2F2E2B);
  static const Color mutedText = Color(0xFF7C7A74);
  static const Color border = Color(0xFFE3DED6);
  static const Color danger = Color(0xFFD65E4A);
  static const Color panelDark = Color(0xFF232624);
  static const Color panelDarkDivider = Color(0xFF4A4F4D);
  static const Color panelDarkMutedText = Color(0xFFAFB5B2);
  static const Color panelDarkAccent = Color(0xFFFFD4C8);
  static const Color successText = Color(0xFF32502E);
  static const Color selectedChip = Color(0xFFF2EFEA);
}

class OudRadii {
  static const BorderRadius xl = BorderRadius.all(Radius.circular(28));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(22));
  static const BorderRadius md = BorderRadius.all(Radius.circular(16));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

class OudSpace {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class OudInsets {
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets pageTop = EdgeInsets.fromLTRB(16, 10, 16, 0);
  static const EdgeInsets sectionGap = EdgeInsets.only(bottom: 12);
  static const EdgeInsets bottomAction = EdgeInsets.fromLTRB(16, 10, 16, 14);
}

class OudTypography {
  static const TextStyle headingXl = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: OudColors.text,
  );
  static const TextStyle headingLg = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: OudColors.text,
  );
  static const TextStyle headingMd = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: OudColors.text,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: OudColors.text,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: OudColors.mutedText,
  );
  static const TextStyle bodyMuted = TextStyle(
    color: OudColors.mutedText,
  );
}
