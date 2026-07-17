enum MovementType { entry, exit }

enum SyncStatus { synced, pending }

class Movement {
  final String id;
  final String userId;
  final String placeId;
  final String placeName;
  final MovementType type;
  final DateTime timestamp;
  final String qrData;
  final SyncStatus syncStatus;
  final String latitude;
  final String longitude;
  final int statusId;

  const Movement({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeName,
    required this.type,
    required this.timestamp,
    required this.qrData,
    this.syncStatus = SyncStatus.synced,
    this.latitude = '0.0',
    this.longitude = '0.0',
    this.statusId = 0,
  });

  String get typeLabel => type == MovementType.entry ? 'Entrée' : 'Sortie';

  String get statusLabel {
    switch (statusId) {
      case 1:
        return 'Accepté';
      case 14:
        return 'Validation en cours';
      default:
        return '';
    }
  }

  bool get hasStatusInfo => statusId == 1 || statusId == 14;

  Movement copyWith({
    String? id,
    String? userId,
    String? placeId,
    String? placeName,
    MovementType? type,
    DateTime? timestamp,
    String? qrData,
    SyncStatus? syncStatus,
    String? latitude,
    String? longitude,
    int? statusId,
  }) {
    return Movement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      qrData: qrData ?? this.qrData,
      syncStatus: syncStatus ?? this.syncStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statusId: statusId ?? this.statusId,
    );
  }

  factory Movement.fromJson(Map<String, dynamic> json) {
    final serverType = json['typeMouvement'] as String?;
    final type = serverType == 'Entrée'
        ? MovementType.entry
        : serverType == 'Sortie'
            ? MovementType.exit
            : json['type'] == 'entry'
                ? MovementType.entry
                : MovementType.exit;

    final rawDate = json['createdAt'] as String? ?? json['timestamp'] as String?;
    DateTime timestamp;
    try {
      if (rawDate != null && rawDate.contains(' ')) {
        timestamp = DateTime.parse(rawDate.replaceFirst(' ', 'T'));
      } else if (rawDate != null) {
        timestamp = DateTime.parse(rawDate);
      } else {
        timestamp = DateTime.now();
      }
    } catch (_) {
      timestamp = DateTime.now();
    }

    return Movement(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      placeId: (json['salleId'] ?? json['placeId'] ?? '').toString(),
      placeName: (json['salleLibelle'] as String?) ??
          json['placeName'] as String? ??
          '',
      type: type,
      timestamp: timestamp,
      qrData: json['qrData'] as String? ?? '',
      syncStatus: json['syncStatus'] == 'pending'
          ? SyncStatus.pending
          : SyncStatus.synced,
      latitude: (json['latitude'] ?? '0.0').toString(),
      longitude: (json['longitude'] ?? '0.0').toString(),
      statusId: json['statusId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'placeId': placeId,
      'placeName': placeName,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'qrData': qrData,
      'syncStatus': syncStatus.name,
      'latitude': latitude,
      'longitude': longitude,
      'statusId': statusId,
    };
  }
}
