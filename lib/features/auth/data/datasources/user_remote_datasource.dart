import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<UserModel?> getUser(String id) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    final json = _toJson(doc.data()!);
    json['id'] = id;
    return UserModel.fromJson(json);
  }

  Future<void> upsert(UserModel user) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.id)
        .set(
      {
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'createdAt': Timestamp.fromDate(user.createdAt),
        'updatedAt': Timestamp.fromDate(user.updatedAt),
      },
      SetOptions(merge: true),
    );
  }

  Map<String, dynamic> _toJson(Map<String, dynamic> data) {
    final json = Map<String, dynamic>.from(data);
    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];
    if (createdAt is Timestamp) {
      json['createdAt'] = createdAt.toDate().toIso8601String();
    }
    if (updatedAt is Timestamp) {
      json['updatedAt'] = updatedAt.toDate().toIso8601String();
    }
    return json;
  }
}