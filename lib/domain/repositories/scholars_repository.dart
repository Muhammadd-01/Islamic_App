import 'package:islamic_app/domain/entities/scholar.dart';

abstract class ScholarsRepository {
  Future<List<Scholar>> getScholars();
  Future<Scholar> getScholarById(String id);
}
