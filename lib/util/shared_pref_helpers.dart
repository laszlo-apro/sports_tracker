import 'package:shared_preferences/shared_preferences.dart';

const _numSeriesSuffix = "_num_series";
const _numRepsSuffix = "_num_reps";
const _weightSuffix = "_weight";

Future<int> readNumSeries({required String exerciseId}) async {
  return _readIntPrefValue(key: '$exerciseId$_numSeriesSuffix');
}

Future<void> writeNumSeries({required String exerciseId, required int numSeries}) async {
  await _writeIntPrefValue(key: '$exerciseId$_numSeriesSuffix', value: numSeries);
}

Future<int> readNumReps({required String exerciseId}) async {
  return _readIntPrefValue(key: '$exerciseId$_numRepsSuffix');
}

Future<void> writeNumReps({required String exerciseId, required int numReps}) async {
  await _writeIntPrefValue(key: '$exerciseId$_numRepsSuffix', value: numReps);
}

Future<double> readWeight({required String exerciseId}) async {
  return _readDoublePrefValue(key: '$exerciseId$_weightSuffix');
}

Future<void> writeWeight({required String exerciseId, required double weight}) async {
  await _writeDoublePrefValue(key: '$exerciseId$_weightSuffix', value: weight);
}

Future<int> _readIntPrefValue({required String key, int defaultValue = 0}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key) ?? defaultValue;
}

Future<void> _writeIntPrefValue({required String key, required int value}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}

Future<double> _readDoublePrefValue({required String key, double defaultValue = 0.0}) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(key) ?? defaultValue;
}

Future<void> _writeDoublePrefValue({required String key, required double value}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(key, value);
}
