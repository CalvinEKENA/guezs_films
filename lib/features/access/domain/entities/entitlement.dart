import 'package:equatable/equatable.dart';

import 'access_grant.dart';
import 'access_scope.dart';

class Entitlement extends Equatable {
  const Entitlement({
    required this.id,
    required this.userId,
    required this.grantType,
    required this.scope,
    required this.active,
    required this.createdAt,
    this.expiresAt,
    this.sourceId,
  });

  final String id;
  final String userId;
  final AccessGrantType grantType;
  final AccessScope scope;
  final bool active;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? sourceId;

  bool get isValid {
    final expiry = expiresAt;
    return active && (expiry == null || DateTime.now().isBefore(expiry));
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    grantType,
    scope,
    active,
    createdAt,
    expiresAt,
    sourceId,
  ];
}
