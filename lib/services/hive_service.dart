import 'package:hive_flutter/hive_flutter.dart';
import 'package:prime_access/models/movement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveService {
  static const _movementBoxName = 'movements';
  static const _schemaVersionKey = 'hive_movement_schema_version';
  static const _currentSchemaVersion = 3;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MovementAdapter());
    await Hive.openBox<Movement>(_movementBoxName);

    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_schemaVersionKey) ?? 1;
    if (storedVersion < _currentSchemaVersion) {
      await _box.clear();
      await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
    }
  }

  Box<Movement> get _box => Hive.box<Movement>(_movementBoxName);

  List<Movement> getMovements() {
    final movements = _box.values.toList();
    movements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return movements;
  }

  Movement? getLastMovement() {
    final movements = _box.values.toList();
    if (movements.isEmpty) return null;
    movements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return movements.first;
  }

  Future<void> addMovement(Movement movement) async {
    await _box.put(movement.id, movement);
  }

  Future<void> deleteMovement(String id) async {
    await _box.delete(id);
  }

  List<Movement> getMovementsByPlace(String placeId) {
    return _box.values.where((m) => m.placeId == placeId).toList();
  }

  Future<void> markAsSynced(String id) async {
    final movement = _box.get(id);
    if (movement != null) {
      await _box.put(id, movement.copyWith(syncStatus: SyncStatus.synced));
    }
  }

  List<Movement> getPendingSyncMovements() {
    return _box.values
        .where((m) => m.syncStatus == SyncStatus.pending)
        .toList();
  }
}

class MovementAdapter extends TypeAdapter<Movement> {
  @override
  final int typeId = 0;

  @override
  Movement read(BinaryReader reader) {
    return Movement(
      id: reader.readString(),
      userId: reader.readString(),
      placeId: reader.readString(),
      placeName: reader.readString(),
      type: reader.readBool() ? MovementType.entry : MovementType.exit,
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      qrData: reader.readString(),
      syncStatus:
          reader.readBool() ? SyncStatus.pending : SyncStatus.synced,
      latitude: reader.readString(),
      longitude: reader.readString(),
      statusId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Movement obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeString(obj.placeId);
    writer.writeString(obj.placeName);
    writer.writeBool(obj.type == MovementType.entry);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.qrData);
    writer.writeBool(obj.syncStatus == SyncStatus.pending);
    writer.writeString(obj.latitude);
    writer.writeString(obj.longitude);
    writer.writeInt(obj.statusId);
  }
}
