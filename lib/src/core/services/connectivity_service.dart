import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Streams real internet reachability (not just "connected to WiFi/data"
/// — actually checks if requests can reach the internet).
final connectivityStreamProvider = StreamProvider<InternetStatus>((ref) {
  return InternetConnection().onStatusChange;
});

/// Simple bool for widgets that just need "am I online right now".
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStreamProvider);
  return status.when(
    data: (value) => value == InternetStatus.connected,
    loading: () => true, // assume online until first check completes
    error: (_, __) => true,
  );
});
