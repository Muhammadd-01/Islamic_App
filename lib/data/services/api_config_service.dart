import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/constants/api_constants.dart';

class ApiConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the API Base URL from Firestore.
  /// If not found, fallbacks to the hardcoded default.
  Future<String> getBaseUrl() async {
    try {
      final doc = await _firestore
          .collection('settings')
          .doc('app_config')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('apiBaseUrl')) {
          final url = data['apiBaseUrl'] as String;
          if (url.isNotEmpty) return url;
        }
      }
    } catch (e) {
      print('Error fetching dynamic API URL: $e');
    }
    return ApiConstants.defaultBaseUrl;
  }
}

final apiConfigServiceProvider = Provider<ApiConfigService>((ref) {
  return ApiConfigService();
});

/// A notifier that manages the current API base URL
/// Using Riverpod 3.x Notifier syntax
class ApiUrlNotifier extends Notifier<String> {
  @override
  String build() {
    // Start fetching the latest URL
    _lastRefresh();
    return ApiConstants.defaultBaseUrl;
  }

  Future<void> _lastRefresh() async {
    final service = ref.read(apiConfigServiceProvider);
    state = await service.getBaseUrl();
  }

  Future<void> refreshUrl() async {
    final service = ref.read(apiConfigServiceProvider);
    state = await service.getBaseUrl();
  }
}

final apiUrlProvider = NotifierProvider<ApiUrlNotifier, String>(
  ApiUrlNotifier.new,
);
