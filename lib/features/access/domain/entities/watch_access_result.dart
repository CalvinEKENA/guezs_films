import 'package:equatable/equatable.dart';

import 'access_grant.dart';

enum WatchAccessStatus {
  granted,
  denied,
  guest,
  codeRequired,
  expired,
  serviceNotDeployed,
  unavailable,
  error,
}

class WatchAccessResult extends Equatable {
  const WatchAccessResult({
    required this.allowed,
    required this.status,
    required this.message,
    this.sessionId,
    this.grant,
    this.playbackUrl,
    this.expiresAt,
  });

  factory WatchAccessResult.granted({
    required String message,
    String? sessionId,
    AccessGrant? grant,
    String? playbackUrl,
    DateTime? expiresAt,
  }) {
    return WatchAccessResult(
      allowed: true,
      status: WatchAccessStatus.granted,
      message: message,
      sessionId: sessionId,
      grant: grant,
      playbackUrl: playbackUrl,
      expiresAt: expiresAt,
    );
  }

  factory WatchAccessResult.fromMap(Map<String, dynamic> map) {
    final grantMap = map['grant'];
    return WatchAccessResult(
      allowed: map['allowed'] == true,
      status: _statusFromString(map['status'] as String?),
      message: map['message'] as String? ?? '',
      sessionId: map['sessionId'] as String?,
      grant: grantMap is Map
          ? AccessGrant.fromMap(Map<String, dynamic>.from(grantMap))
          : null,
      playbackUrl: map['playbackUrl'] as String?,
      expiresAt: _dateFromValue(map['expiresAt']),
    );
  }

  factory WatchAccessResult.failure({
    required WatchAccessStatus status,
    required String message,
  }) {
    return WatchAccessResult(allowed: false, status: status, message: message);
  }

  final bool allowed;
  final WatchAccessStatus status;
  final String message;
  final String? sessionId;
  final AccessGrant? grant;
  final String? playbackUrl;
  final DateTime? expiresAt;

  bool get requiresCode =>
      status == WatchAccessStatus.codeRequired ||
      status == WatchAccessStatus.denied ||
      status == WatchAccessStatus.expired;

  bool get requiresLogin => status == WatchAccessStatus.guest;

  bool get allowsTemporaryMvpFallback =>
      status == WatchAccessStatus.serviceNotDeployed ||
      status == WatchAccessStatus.unavailable;

  @override
  List<Object?> get props => [
    allowed,
    status,
    message,
    sessionId,
    grant,
    playbackUrl,
    expiresAt,
  ];
}

WatchAccessStatus _statusFromString(String? value) {
  return WatchAccessStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => WatchAccessStatus.denied,
  );
}

DateTime? _dateFromValue(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}
