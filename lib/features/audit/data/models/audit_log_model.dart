import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_model.freezed.dart';
part 'audit_log_model.g.dart';

@freezed
abstract class AuditLogModel with _$AuditLogModel {
  const factory AuditLogModel({
    required String id,
    required String userId,
    required String userName,
    required String action,
    required String entityType,
    required String entityId,
    required String description,
    required DateTime createdAt,
  }) = _AuditLogModel;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$AuditLogModelFromJson(json);
}
