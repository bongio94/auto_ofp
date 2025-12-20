import 'package:auto_ofp/src/services/flightaware_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flight_controller.g.dart';

@riverpod
class FlightController extends _$FlightController {
  // Static cache to persist data across provider rebuilds
  static final Map<String, ({Map<String, dynamic> data, DateTime timestamp})>
  _cache = {};
  static DateTime? _lastRequestTime;

  @override
  FutureOr<Map<String, dynamic>?> build() {
    return null;
  }

  Future<void> searchFlight(String ident) async {
    final normalizedIdent = ident.toUpperCase().trim();
    if (normalizedIdent.isEmpty) return;

    // Prevent request spamming (e.g., max 1 request every 5 seconds)
    if (_lastRequestTime != null) {
      final difference = DateTime.now().difference(_lastRequestTime!);
      if (difference.inSeconds < 5) {
        state = AsyncError(
          "Please wait ${5 - difference.inSeconds}s before searching again.",
          StackTrace.current,
        );
        return;
      }
    }

    // Check Cache
    final cachedEntry = _cache[normalizedIdent];
    if (cachedEntry != null) {
      final isFresh =
          DateTime.now().difference(cachedEntry.timestamp) <
          const Duration(minutes: 30);
      if (isFresh) {
        // Return cached data immediately
        state = AsyncData(cachedEntry.data);
        return;
      } else {
        _cache.remove(normalizedIdent);
      }
    }

    // Set loading
    state = const AsyncLoading();

    // Perform the fetch
    state = await AsyncValue.guard(() async {
      _lastRequestTime = DateTime.now();
      final service = FlightAwareService();
      final result = await service.getFlight(normalizedIdent);

      if (result != null) {
        // Save to cache
        _cache[normalizedIdent] = (data: result, timestamp: DateTime.now());
      }
      return result;
    });
  }
}
