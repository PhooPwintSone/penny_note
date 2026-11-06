import 'package:flutter/material.dart';

/// Penny Note brand palette.
///
/// Widgets should not read these constants directly. Use
/// `Theme.of(context).colorScheme` or [PennyColors] via `context.pennyColors`
/// so light and dark mode stay in sync.
abstract final class AppColors {
  // Light theme — warm paper, chocolate ink, and muted earthy accents.
  static const lightBackground = Color(0xFFF6F0E5);
  static const lightSurface = Color(0xFFE9DDC9);
  static const lightTextPrimary = Color(0xFF382D28);
  static const lightTextSecondary = Color(0xFF81756B);
  static const lightPrimary = Color(0xFFA95D43);
  static const lightPrimaryContainer = Color(0xFF382D28);
  static const lightSecondary = Color(0xFF78866A);
  static const lightHighlight = Color(0xFFC29B55);
  static const lightIncome = Color(0xFF4F6545);
  static const lightExpense = Color(0xFF8F4632);
  static const lightOutline = Color(0xFF8C7460);
  static const lightOutlineVariant = Color(0xFFCBB9A2);
  static const lightSurfaceContainerLowest = Color(0xFFFBF6EC);
  static const lightSurfaceContainerLow = Color(0xFFF3E9D9);
  static const lightSurfaceContainerHigh = Color(0xFFDED0BA);
  static const lightSurfaceContainerHighest = Color(0xFFD2C2AA);
  static const lightOnPrimary = Color(0xFFFFF8F0);
  static const lightOnPrimaryContainer = Color(0xFFF6F0E5);
  static const lightOnSecondary = Color(0xFF1F2A1B);
  static const lightSecondaryContainer = Color(0xFFDDE5D2);
  static const lightOnSecondaryContainer = Color(0xFF2F3A29);
  static const lightOnHighlight = Color(0xFF2A2013);
  static const lightHighlightContainer = Color(0xFFEAD7B0);
  static const lightOnHighlightContainer = Color(0xFF3B2A21);
  static const lightOnError = Color(0xFFFFF8F3);

  // Dark theme — a warm plum and espresso version of the same identity.
  static const darkBackground = Color(0xFF251F29);
  static const darkSurface = Color(0xFF342A36);
  static const darkTextPrimary = Color(0xFFF0E6D6);
  static const darkTextSecondary = Color(0xFFB8AFAE);
  static const darkPrimary = Color(0xFFC77A5C);
  static const darkPrimaryContainer = Color(0xFF3F2E3A);
  static const darkSecondary = Color(0xFF91A181);
  static const darkHighlight = Color(0xFFD0AD70);
  static const darkIncome = Color(0xFFA9C096);
  static const darkExpense = Color(0xFFE09A80);
  static const darkError = Color(0xFFD98A72);
  static const darkOutline = Color(0xFFB8AFAE);
  static const darkOutlineVariant = Color(0xFF4D3F4A);
  static const darkSurfaceContainerLowest = Color(0xFF201A24);
  static const darkSurfaceContainerLow = Color(0xFF2C2430);
  static const darkSurfaceContainerHigh = Color(0xFF403442);
  static const darkSurfaceContainerHighest = Color(0xFF4C3E4E);
  static const darkOnPrimary = Color(0xFF2A140C);
  static const darkOnPrimaryContainer = Color(0xFFF0E6D6);
  static const darkOnSecondary = Color(0xFF1F2A1B);
  static const darkSecondaryContainer = Color(0xFF3A4A33);
  static const darkOnSecondaryContainer = Color(0xFFDDE5D2);
  static const darkOnHighlight = Color(0xFF2A2013);
  static const darkHighlightContainer = Color(0xFF4A3B22);
  static const darkOnHighlightContainer = Color(0xFFF0E6D6);
  static const darkOnError = Color(0xFF2A100A);
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
