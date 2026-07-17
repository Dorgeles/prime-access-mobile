import 'package:flutter/foundation.dart';
import 'package:prime_access/models/movement.dart';
import 'package:prime_access/services/hive_service.dart';
import 'package:prime_access/services/api_service.dart';

class MovementProvider extends ChangeNotifier {
  final HiveService _hiveService;
  final ApiService _apiService;

  List<Movement> _movements = [];
  List<Movement> _filteredMovements = [];
  bool _isLoading = false;

  String _filterType = 'all';
  String _filterPlaceId = 'all';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  MovementProvider({
    required HiveService hiveService,
    required ApiService apiService,
  }) : _hiveService = hiveService,
       _apiService = apiService;

  List<Movement> get movements => _filteredMovements;
  Movement? get lastMovement => _movements.isNotEmpty ? _movements.first : null;
  bool get isLoading => _isLoading;
  List<Movement> get allMovements => _movements;

  String get filterType => _filterType;
  String get filterPlaceId => _filterPlaceId;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  void loadMovements() {
    _isLoading = true;
    notifyListeners();

    _movements = _hiveService.getMovements();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<ApiResult?> addMovement(Movement movement, String? token) async {
    _movements = _hiveService.getMovements();

    ApiResult? result;
    if (token != null) {
      try {
        result = await _apiService.syncMovement(movement, token);
        if (result.success == false && result.errorCode == '800') {
          Movement? registerMouvement = Movement.fromJson(result.data ?? {});
          await _hiveService.addMovement(registerMouvement);
          await _hiveService.markAsSynced(movement.id);
          _movements = _hiveService.getMovements();
        } else if (result.errorCode != '800') {
          await _hiveService.deleteMovement(movement.id);
          _movements = _hiveService.getMovements();
        }
      } catch (_) {
        result = ApiResult(
          success: false,
          errorMessage: 'Impossible de contacter le serveur',
        );
      }
    }

    _applyFilters();
    notifyListeners();
    return result;
  }

  void setFilterType(String type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  void setFilterPlaceId(String placeId) {
    _filterPlaceId = placeId;
    _applyFilters();
    notifyListeners();
  }

  void setFilterDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filterType = 'all';
    _filterPlaceId = 'all';
    _filterStartDate = null;
    _filterEndDate = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMovements = _movements.where((m) {
      if (_filterType != 'all' && m.type.name != _filterType) {
        return false;
      }
      if (_filterPlaceId != 'all' && m.placeId != _filterPlaceId) {
        return false;
      }
      if (_filterStartDate != null && m.timestamp.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null) {
        final endOfDay = _filterEndDate!
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        if (m.timestamp.isAfter(endOfDay)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> fetchFromServer(String token, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final serverMovements = await _apiService.fetchMovements(token, userId);
      for (final movement in serverMovements) {
        await _hiveService.addMovement(movement);
      }
    } catch (_) {}

    _movements = _hiveService.getMovements();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncPendingMovements(String token) async {
    final pending = _hiveService.getPendingSyncMovements();
    for (final movement in pending) {
      try {
        final result = await _apiService.syncMovement(movement, token);
        if (result.success) {
          await _hiveService.markAsSynced(movement.id);
        } else if (result.errorCode == '800') {
          await _hiveService.deleteMovement(movement.id);
        }
      } catch (_) {}
    }
    _movements = _hiveService.getMovements();
    _applyFilters();
    notifyListeners();
  }
}
