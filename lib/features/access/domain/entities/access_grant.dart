import 'package:equatable/equatable.dart';

import 'access_scope.dart';

enum AccessGrantType { free, ambassadorCode, pass, purchase, global }

class AccessGrant extends Equatable {
  const AccessGrant({
    required this.type,
    required this.scope,
    this.sourceId,
    this.expiresAt,
  });

  final AccessGrantType type;
  final AccessScope scope;
  final String? sourceId;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  factory AccessGrant.fromMap(Map<String, dynamic> map) {
    return AccessGrant(
      type: _grantTypeFromString(map['type'] as String?),
      scope: AccessScope(
        contentType: _contentTypeFromString(map['contentType'] as String?),
        filmId: map['filmId'] as String?,
        seriesId: map['seriesId'] as String?,
        seasonId: map['seasonId'] as String?,
        episodeId: map['episodeId'] as String?,
      ),
      sourceId: map['sourceId'] as String?,
      expiresAt: _dateFromValue(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      ...scope.toMap(),
      if (sourceId != null) 'sourceId': sourceId,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [type, scope, sourceId, expiresAt];
}

AccessGrantType _grantTypeFromString(String? value) {
  return AccessGrantType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => AccessGrantType.free,
  );
}

AccessContentType _contentTypeFromString(String? value) {
  return AccessContentType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => AccessContentType.global,
  );
}

DateTime? _dateFromValue(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}
