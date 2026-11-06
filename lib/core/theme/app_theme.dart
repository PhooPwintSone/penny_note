import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the light and dark [ThemeData] objects for Penny Note.
///
/// Everything visual is derived from the brand palette in [AppColors], so a
/// color change only needs to happen in one place.
abstract final class AppTheme {
  static const _serifFamily = 'Lora';
  static const _serifFallback = <String>['Georgia', 'Times New Roman', 'serif'];
  static const _sansFamily = 'SourceSans3';
  static const _sansFallback = <String>[
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'sans-serif',
  ];

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: _lightScheme,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    income: AppColors.lightIncome,
    expense: AppColors.lightExpense,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: _darkScheme,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    income: AppColors.darkIncome,
    expense: AppColors.darkExpense,
  );

  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.lightPrimary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimaryContainer: AppColors.lightOnPrimaryContainer,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        secondaryContainer: AppColors.lightSecondaryContainer,
        onSecondaryContainer: AppColors.lightOnSecondaryContainer,
        tertiary: AppColors.lightHighlight,
        onTertiary: AppColors.lightOnHighlight,
        tertiaryContainer: AppColors.lightHighlightContainer,
        onTertiaryContainer: AppColors.lightOnHighlightContainer,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        error: AppColors.lightExpense,
        onError: AppColors.lightOnError,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
        shadow: AppColors.lightTextPrimary,
        scrim: AppColors.lightTextPrimary,
        surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
        surfaceContainerLow: AppColors.lightSurfaceContainerLow,
        surfaceContainer: AppColors.lightSurface,
        surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkOnSecondaryContainer,
        tertiary: AppColors.darkHighlight,
        onTertiary: AppColors.darkOnHighlight,
        tertiaryContainer: AppColors.darkHighlightContainer,
        onTertiaryContainer: AppColors.darkOnHighlightContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        error: AppColors.darkError,
        onError: AppColors.darkOnError,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
        surfaceContainerLow: AppColors.darkSurfaceContainerLow,
        surfaceContainer: AppColors.darkSurface,
        surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      );

  static TextStyle? _serif(
    TextStyle? base, {
    FontWeight? weight,
    double? letterSpacing,
    double? height,
  }) {
    return base?.copyWith(
      fontFamily: _serifFamily,
      fontFamilyFallback: _serifFallback,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color background,
    required Color surface,
    required Color income,
    required Color expense,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: _sansFamily,
      fontFamilyFallback: _sansFallback,
    );

    final sansTheme = base.textTheme.apply(
      fontFamily: _sansFamily,
      fontFamilyFallback: _sansFallback,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final textTheme = sansTheme.copyWith(
      displayLarge: _serif(
        sansTheme.displayLarge,
        weight: FontWeight.w600,
        letterSpacing: -1.2,
        height: 1.05,
      ),
      displayMedium: _serif(
        sansTheme.displayMedium,
        weight: FontWeight.w600,
        letterSpacing: -1,
        height: 1.08,
      ),
      displaySmall: _serif(
        sansTheme.displaySmall,
        weight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      headlineLarge: _serif(
        sansTheme.headlineLarge,
        weight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      headlineMedium: _serif(
        sansTheme.headlineMedium,
        weight: FontWeight.w600,
        letterSpacing: -0.35,
        height: 1.18,
      ),
      headlineSmall: _serif(
        sansTheme.headlineSmall,
        weight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      titleLarge: _serif(
        sansTheme.titleLarge,
        weight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.25,
      ),
      titleMedium: _serif(
        sansTheme.titleMedium,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
      ),
      // Small financial information and list titles stay in the clean sans face.
      titleSmall: sansTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        height: 1.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      bodyLarge: sansTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: sansTheme.bodyMedium?.copyWith(height: 1.45),
      bodySmall: sansTheme.bodySmall?.copyWith(
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: sansTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: sansTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: sansTheme.labelSmall?.copyWith(
        letterSpacing: 0.4,
        color: scheme.onSurfaceVariant,
      ),
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
    );

    return base.copyWith(
      textTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: scheme.outline, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        useIndicator: true,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        prefixStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHigh,
          disabledForegroundColor: scheme.onSurfaceVariant,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.7)),
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          side: BorderSide(color: scheme.outline, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.9),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: scheme.outline, width: 1.5),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.xl),
          ),
          side: BorderSide(color: scheme.outline, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.primaryContainer,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          side: BorderSide(
            color: scheme.tertiary.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.tileRadius),
          side: BorderSide(color: scheme.outline, width: 1.5),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primaryContainer;
            }
            return scheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.onPrimaryContainer;
            }
            return scheme.onSurface;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
          shape: WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: scheme.primaryContainer,
        headerForegroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: scheme.onSurface,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: scheme.outlineVariant),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.24),
        selectionHandleColor: scheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      extensions: [PennyColors(income: income, expense: expense)],
    );
  }
}
