import 'package:islamic_app/domain/entities/invention.dart';
import 'package:islamic_app/domain/entities/scientist.dart';

abstract class MuslimScientistsRepository {
  Future<List<Invention>> getInventions();
  Future<List<Scientist>> getScientists();
}
