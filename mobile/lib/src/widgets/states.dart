import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../core/tokens.dart';

/// Shimmer placeholder list used while sessions load.
class LoadingSkeleton extends StatelessWidget {
  final int rows;
  const LoadingSkeleton({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rows,
        (i) => Shimmer.fromColors(
          baseColor: Theme.of(context).disabledColor.withValues(alpha: 0.15),
          highlightColor:
              Theme.of(context).disabledColor.withValues(alpha: 0.35),
          child: Container(
            height: 96,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: Theme.of(context).disabledColor,
            ),
          ),
        ).animate().fadeIn(delay: (i * 120).ms),
      ),
    );
  }
}

/// Standard empty state with icon + message + optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon,
              size: 40, color: Theme.of(context).disabledColor),
          const SizedBox(height: AppSpacing.sm),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor)),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.sm + 2),
            OutlinedButton(
                onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

/// Standard error card with retry.
class ErrorCard extends StatelessWidget {
  final String title;
  final String detail;
  final VoidCallback onRetry;
  const ErrorCard({
    super.key,
    required this.title,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.error_outline, color: AppColors.danger),
            SizedBox(width: AppSpacing.sm),
            Text('Couldn’t load sessions',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(detail,
              style: TextStyle(
                  color: Theme.of(context).hintColor, fontSize: 12)),
          const SizedBox(height: AppSpacing.sm + 2),
          FilledButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              onPressed: onRetry),
        ],
      ),
    ).animate().shake();
  }
}
