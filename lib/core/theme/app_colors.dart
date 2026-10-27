import 'package:flutter/material.dart';

/// Penny Note brand palette.
///
/// Widgets should not read these constants directly. Use
/// `Theme.of(context).colorScheme` or [PennyColors] via `context.pennyColors`
/// so light and dark mode stay in sync.
abstract final class AppColors {
  // Light theme
  static const lightPrimary = Color(0xFF4F6F52);
  static const lightPrimaryDark = Color(0xFF2F4532);
  static const lightAccent = Color(0xFFC9A227);
  static const lightBackground = Color(0xFFF8F6F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF252525);
  static const lightTextSecondary = Color(0xFF777777);
  static const lightIncome = Color(0xFF4F8A5B);
  static const lightExpense = Color(0xFFC96B6B);
  static const lightOutline = Color(0xFFD9D4C7);
  static const lightOutlineVariant = Color(0xFFE7E2D6);

  // Dark theme — a muted, comfortable version of the same identity.
  static const darkBackground = Color(0xFF171A17);
  static const darkSurface = Color(0xFF222722);
  static const darkPrimary = Color(0xFF8EAD91);
  static const darkPrimaryContainer = Color(0xFF2F4532);
  static const darkAccent = Color(0xFFD6B84C);
  static const darkTextPrimary = Color(0xFFF1F1EC);
  static const darkTextSecondary = Color(0xFFA7ACA5);
  static const darkIncome = Color(0xFF78A87D);
  static const darkExpense = Color(0xFFD47C7C);
  static const darkOutline = Color(0xFF454B45);
  static const darkOutlineVariant = Color(0xFF333833);
}

/// Semantic colors that [ColorScheme] does not provide.
@immutable
class PennyColors extends ThemeExtension<PennyColors> {
  const PennyColors({required this.income, required this.expense});

  static const light = PennyColors(
    income: AppColors.lightIncome,
    expense: AppColors.lightExpense,
  );

  static const dark = PennyColors(
    income: AppColors.darkIncome,
    expense: AppColors.darkExpense,
  );

  final Color income;
  final Color expense;

  @override
  PennyColors copyWith({Color? income, Color? expense}) {
    return PennyColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  PennyColors lerp(ThemeExtension<PennyColors>? other, double t) {
    if (other is! PennyColors) return this;
    return PennyColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
    );
  }
}

extension PennyTheme on BuildContext {
  /// Shorthand for `Theme.of(context).extension<PennyColors>()`.
  PennyColors get pennyColors =>
      Theme.of(this).extension<PennyColors>() ?? PennyColors.light;
}
