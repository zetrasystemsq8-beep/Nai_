import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';

/// Slides down a persistent "You're offline" banner whenever internet
/// is unreachable. Drop this once, near the top of the app's widget tree.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: isOnline ? 0 : 32,
      width: double.infinity,
      color: Colors.red.shade700,
      child: isOnline
          ? null
          : const Center(
              child: Text(
                'No internet connection',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
    );
  }
}
