import 'package:flutter/material.dart';

// Premium Medical Palette - Apple/Meta Tier
const Color kcPrimaryColor = Color(0xFF00796B); // Deep Medical Teal
const Color kcPrimaryColorDark = Color(0xFF004D40);
const Color kcAccentColor = Color(0xFF00BFA5); // Fresh Mint Accent
const Color kcSecondaryColor = Color(0xFF1976D2); // Reliable Medical Blue

// Semantic Status Colors
const Color kcSuccessColor = Color(0xFF4CAF50);
const Color kcWarningColor = Color(0xFFFFB300);
const Color kcErrorColor = Color(0xFFF44336);
const Color kcInfoColor = Color(0xFF2196F3);

// Neutral Palette
const Color kcDarkGreyColor = Color(0xFF1A1A1A); // Apple-style dark text
const Color kcMediumGrey = Color(0xFF757575); 
const Color kcLightGrey = Color(0xFFE0E0E0);
const Color kcVeryLightGrey = Color(0xFFF5F7FA); // Soft surface grey
const Color kcBackgroundColor = Color(0xFFFFFFFF);
const Color kcWhite = Color(0xFFFFFFFF);

// Premium Gradients
const LinearGradient kcPrimaryGradient = LinearGradient(
  colors: [kcPrimaryColor, kcPrimaryColorDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kcAccentGradient = LinearGradient(
  colors: [kcAccentColor, Color(0xFF64FFDA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Premium Decorations & Shadows
BoxShadow premiumShadow = BoxShadow(
  color: const Color(0xFF000000).withOpacity(0.06),
  blurRadius: 24,
  offset: const Offset(0, 12),
);

BoxDecoration glassDecoration = BoxDecoration(
  color: Colors.white.withOpacity(0.12),
  borderRadius: BorderRadius.circular(30),
  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
);
