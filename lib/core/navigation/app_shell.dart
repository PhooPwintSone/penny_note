import 'package:flutter/material.dart';

import '../../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/income/presentation/screens/incomes_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../features/statistics/presentation/screens/statistics_screen.dart';

/// The app shell: navigation plus a persistent tab stack.
///
/// [IndexedStack] keeps each tab's scroll position alive when switching. A
/// bottom bar is used on phones and a side rail on tablets and desktop.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _screens = [
    HomeScreen(),
    ExpensesScreen(),
    IncomesScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  static const _destinations =
      <({IconData icon, IconData selectedIcon, String label})>[
        (
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'Home',
        ),
        (
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long_rounded,
          label: 'Expenses',
        ),
        (
          icon: Icons.payments_outlined,
          selectedIcon: Icons.payments_rounded,
          label: 'Income',
        ),
        (
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights_rounded,
          label: 'Statistics',
        ),
        (
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
          label: 'Settings',
        ),
      ];

  int _selectedIndex = 0;

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final content = IndexedStack(index: _selectedIndex, children: _screens);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final useRail = shortestSide >= 600;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: useRail
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    backgroundColor: colors.surface,
                    indicatorColor: colors.primary.withValues(alpha: 0.12),
                    selectedIconTheme: IconThemeData(color: colors.primary),
                    unselectedIconTheme: IconThemeData(
                      color: colors.onSurfaceVariant,
                    ),
                    selectedLabelTextStyle: theme.textTheme.labelMedium
                        ?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                    unselectedLabelTextStyle: theme.textTheme.labelMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectDestination,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: colors.outlineVariant),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: useRail
          ? null
          : Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.outline, width: 1),
                ),
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectDestination,
                destinations: [
                  for (final destination in _destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: destination.label,
                    ),
                ],
              ),
            ),
    );
  }
}
