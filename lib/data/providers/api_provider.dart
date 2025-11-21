import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/data/datasources/mock_api_service.dart';

final mockApiServiceProvider = Provider<MockApiService>((ref) {
  return MockApiService();
});
