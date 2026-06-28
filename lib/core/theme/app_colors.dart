import 'package:flutter/material.dart';

class AppColors {
  // ------------------ Light Theme ------------------
  static AppColorScheme light = AppColorScheme(
    // Primary Colors
    colorPrimary: Color(0xFF004AAD),
    colorSecond: Color(0xFFFF6E40),
    colorAccent: Color(0xFFF67E58),
    background: Color(0xFFFFFFFF),
    colorPrimaryDark: Color(0xFFF67E58),
    colorPrimaryLight: Color(0xFFEEF6FF),

    // Other Colors
    divider: Color(0xFFFFB4A2),
    textIcon: Color(0xFF000000),
    green: Color(0xFF4CAF50),
    red: Color(0xFFC50C0C),
    colortur: Color(0xFFD5E9FF),
    semiTransparentBlack: Color(0x80000000),
    gray: Color(0xFF989C9B),
    grayLight: Colors.grey[100] ?? Colors.white,
    bottomNavigation: Color(0xFFEEF6FF),
    searchBg: Color(0xFFF5F5F5),

    // Splash & Common
    splashbg: Color(0xFFFFD700),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    textLight: Color(0xFFFFFFFF),
    textDark: Color(0xFF000000),
    textGray: Colors.black54,

    // Google Colors
    gplusColor1: Color(0xFF3E802F),
    gplusColor2: Color(0xFFF4B400),
    gplusColor3: Color(0xFF427FED),
    gplusColor4: Color(0xFFB23424),

    // Additional
    whiteTrans: Color(0xA6FFFFFF),
    inputSummary: Color(0xFFE5E5E5),
    btnColorBg: Color(0xFFFFD700),
    blurAppBar: Color(0x303C3C3B),


    backGroundLayer1: Colors.white.withOpacity(0.4),
    cemiTransparent: Colors.white.withOpacity(0.1),
  );

  // ------------------ Dark Theme ------------------
  static AppColorScheme dark = AppColorScheme(
    // Primary Colors
    colorPrimary: Color(0xFF1E3A8A), // darker blue
    colorSecond: Color(0xFFFF8A65),
    colorAccent: Color(0xFFFB8C7A),
    background: Color(0xFF121212),
    colorPrimaryDark: Color(0xFFB25F45),
    colorPrimaryLight: Color(0xFF1F2937),

    // Other Colors
    divider: Color(0xFF4E4E4E),
    textIcon: Color(0xFFFFFFFF),
    green: Color(0xFF66BB6A),
    red: Color(0xFFE57373),
    colortur: Color(0xFF4A6572),
    semiTransparentBlack: Color(0x99000000),
    gray: Color(0xFF9E9E9E),
    grayLight: Color(0xFF616161),
    bottomNavigation: Color(0xFF1E1E1E),
    searchBg: Color(0xFF2C2C2C),

    // Splash & Common
    splashbg: Color(0xFF9C27B0), // purple in dark mode
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    textLight: Color(0xFFFFFFFF),
    textDark: Color(0xFFE0E0E0),
    textGray: Colors.white70,

    // Google Colors
    gplusColor1: Color(0xFF388E3C),
    gplusColor2: Color(0xFFFBC02D),
    gplusColor3: Color(0xFF1976D2),
    gplusColor4: Color(0xFFD32F2F),

    // Additional
    whiteTrans: Color(0x80FFFFFF),
    inputSummary: Color(0xFF2C2C2C),
    btnColorBg: Color(0xFF9C27B0),
    blurAppBar: Color(0x60212121),


    backGroundLayer1: Colors.grey.withOpacity(0.1),
    cemiTransparent: Colors.black.withOpacity(0.1),
  );
}

/// Private struct holding a set of colors
class AppColorScheme {
  final Color colorPrimary;
  final Color colorSecond;
  final Color colorAccent;
  final Color background;
  final Color colorPrimaryDark;
  final Color colorPrimaryLight;

  final Color divider;
  final Color textIcon;
  final Color green;
  final Color red;
  final Color colortur;
  final Color semiTransparentBlack;
  final Color gray;
  final Color grayLight;
  final Color bottomNavigation;
  final Color searchBg;

  final Color splashbg;
  final Color white;
  final Color black;
  final Color textLight;
  final Color textDark;
  final Color textGray;

  final Color gplusColor1;
  final Color gplusColor2;
  final Color gplusColor3;
  final Color gplusColor4;

  final Color whiteTrans;
  final Color inputSummary;
  final Color btnColorBg;
  final Color blurAppBar;
  final Color backGroundLayer1;

  final Color cemiTransparent;

  const AppColorScheme({
    required this.colorPrimary,
    required this.colorSecond,
    required this.colorAccent,
    required this.background,
    required this.colorPrimaryDark,
    required this.colorPrimaryLight,
    required this.divider,
    required this.textIcon,
    required this.green,
    required this.red,
    required this.colortur,
    required this.semiTransparentBlack,
    required this.gray,
    required this.grayLight,
    required this.bottomNavigation,
    required this.searchBg,
    required this.splashbg,
    required this.white,
    required this.black,
    required this.textLight,
    required this.textDark,
    required this.textGray,
    required this.gplusColor1,
    required this.gplusColor2,
    required this.gplusColor3,
    required this.gplusColor4,
    required this.whiteTrans,
    required this.inputSummary,
    required this.btnColorBg,
    required this.blurAppBar,
    required this.backGroundLayer1,
    required this.cemiTransparent,
  });
}
