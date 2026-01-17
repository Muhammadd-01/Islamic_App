import 'package:flutter/material.dart';

/// DeenSphere Brand Color System
/// Official color palette matching https://deen-sphere.vercel.app
class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND GOLD (MOST IMPORTANT - Identity Colors)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary Gold - Main brand color for CTAs, highlights, active states
  static const Color primaryGold = Color(0xFFF5B400);

  /// Highlight Gold - Brighter gold for emphasis, hover states
  static const Color highlightGold = Color(0xFFFFD84D);

  /// Soft Gold - Darker gold for subtle accents, pressed states
  static const Color softGold = Color(0xFFE6A800);

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY BASE COLORS (App Backgrounds)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main Background - Deepest dark for primary screens
  static const Color mainBackground = Color(0xFF0B0B0B);

  /// Secondary Background - Slightly lighter for hierarchy
  static const Color secondaryBackground = Color(0xFF141414);

  /// Card / Surface Dark - For elevated surfaces like cards
  static const Color cardDark = Color(0xFF1C1C1C);

  // ═══════════════════════════════════════════════════════════════════════════
  // NEUTRAL / LIGHT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary White - For headings and important text
  static const Color primaryWhite = Color(0xFFFFFFFF);

  /// Soft White - For light cards and form backgrounds
  static const Color softWhite = Color(0xFFF4F4F4);

  /// Muted Gray - For body text and secondary content
  static const Color mutedGray = Color(0xFFB3B3B3);

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON / UI DARK COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Icon Black - For icons on light/gold backgrounds
  static const Color iconBlack = Color(0xFF000000);

  /// Soft Icon Gray - For subtle UI elements
  static const Color softIconGray = Color(0xFF2A2A2A);

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES (for backward compatibility with existing screens)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary color (maps to primaryGold for compatibility)
  static const Color primary = primaryGold;

  /// Secondary color (maps to softGold for compatibility)
  static const Color secondary = softGold;

  /// Accent color (maps to highlightGold for compatibility)
  static const Color accent = highlightGold;

  /// Light background (maps to softWhite for light theme)
  static const Color backgroundLight = softWhite;

  /// Dark background (maps to mainBackground for dark theme)
  static const Color backgroundDark = mainBackground;

  /// Light surface (white cards in light theme)
  static const Color surfaceLight = primaryWhite;

  /// Dark surface (cards in dark theme)
  static const Color surfaceDark = cardDark;

  /// Light text color
  static const Color textLight = iconBlack;

  /// Dark text color (muted for readability)
  static const Color textDark = mutedGray;

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENTS (Official DeenSphere Gradients)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary Gold Gradient - For main CTAs, primary buttons, highlights
  static const LinearGradient primaryGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [highlightGold, primaryGold, softGold],
  );

  /// Dark Premium Background Gradient - For app background, splash, auth screens
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mainBackground, secondaryBackground],
  );

  /// Gold Tile / Icon Gradient - For feature icons, dashboard cards
  static const LinearGradient goldTileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, highlightGold],
  );

  /// Soft White Card Gradient - For forms, modals, content cards
  static const LinearGradient softWhiteCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryWhite, softWhite],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Disabled state color
  static const Color disabled = mutedGray;

  /// Success color (keeping a subtle green for success states)
  static const Color success = Color(0xFF22C55E);

  /// Error color
  static const Color error = Color(0xFFEF4444);

  /// Warning color (uses gold family)
  static const Color warning = primaryGold;

  // ═══════════════════════════════════════════════════════════════════════════
  // DEPRECATED - Remove after migration
  // ═══════════════════════════════════════════════════════════════════════════

  @Deprecated('Use mainBackground or surfaceDark instead')
  static const Color glassWhite = Color(0x20FFFFFF);

  @Deprecated('Use mainBackground instead')
  static const Color glassBlack = Color(0x20000000);

  @Deprecated('Use highlightGold instead')
  static const Color neonGreen = highlightGold;

  @Deprecated('Use highlightGold instead')
  static const Color neonBlue = highlightGold;

  @Deprecated('Use mainBackground instead')
  static const Color darkGradientStart = mainBackground;

  @Deprecated('Use secondaryBackground instead')
  static const Color darkGradientEnd = secondaryBackground;
}
