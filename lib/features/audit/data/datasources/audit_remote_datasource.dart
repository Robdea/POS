import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/firebase/firestore_json.dart';
import '../models/audit_log_model.dart';

class AuditRemoteDataSource {
  AuditRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<AuditLogModel>> getAll() async {
    final snap = await _firestore
        .collection(FirestoreCollections.auditLogs)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) =>
            AuditLogModel.fromJson(FirestoreJson.fromSnapshot(doc.data(), id: doc.id)))
        .toList();
  }

  Future<AuditLogModel?> getById(String id) async {
    final doc = await _firestore
        .collection(FirestoreCollections.auditLogs)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return AuditLogModel.fromJson(
      FirestoreJson.fromSnapshot(doc.data(), id: doc.id),
    );
  }

  Future<void> upsert(AuditLogModel log) async {
    await _firestore.collection(FirestoreCollections.auditLogs).doc(log.id).set(
      {
        'userId': log.userId,
        'userName': log.userName,
        'action': log.action,
        'entityType': log.entityType,
        'entityId': log.entityId,
        'description': log.description,
        'createdAt': Timestamp.fromDate(log.createdAt),
      },
      SetOptions(merge: true),
    );
  }
}