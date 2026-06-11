import 'package:equatable/equatable.dart';

import 'access_grant.dart';
import 'access_scope.dart';

class AccessCode extends Equatable {
  const AccessCode({
    required this.id,
    required this.label,
    required this.grantType,
    required this.scope,
    required this.active,
    required this.usedCount,
    this.maxUses,
    this.startsAt,
    this.expiresAt,
  });

  final String id;
  final String label;
  final AccessGrantType grantType;
  final AccessScope scope;
  final bool active;
  final int usedCount;
  final int? maxUses;
  final DateTime? startsAt;
  final DateTime? expiresAt;

  bool get isAvailable {
    final now = DateTime.now();
    final start = startsAt;
    final expiry = expiresAt;
    final max = maxUses;
    return active &&
        (start == null || now.isAfter(start)) &&
        (expiry == null || now.isBefore(expiry)) &&
        (max == null || usedCount < max);
  }

  @override
  List<Object?> get props => [
    id,
    label,
    grantType,
    scope,
    active,
    usedCount,
    maxUses,
    startsAt,
    expiresAt,
  ];
}
