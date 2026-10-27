import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: EmptyState(
            icon: Icons.insights_rounded,
            title: 'Insights are on the way',
            message:
                'Monthly totals and category breakdowns will appear here '
                'once you have a few expenses recorded.',
          ),
        ),
      ),
    );
  }
}
