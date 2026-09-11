import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/firebase/firestore_json.dart';
import '../../../auth/data/models/user_model.dart';

class UsersRemoteDataSource {
  UsersRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UserModel>> getAll() async {
    final snap = await _firestore
        .collection(FirestoreCollections.users)
        .orderBy('name')
        .get();
    return snap.docs
        .map((doc) =>
            UserModel.fromJson(FirestoreJson.fromSnapshot(doc.data(), id: doc.id)))
        .toList();
  }

  Future<void> upsert(UserModel user) async {
    await _firestore.collection(FirestoreCollections.users).doc(user.id).set(
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

  Future<void> updateRole(
    String id,
    String role,
    DateTime updatedAt,
  ) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(id)
        .update({
      'role': role,
      'updatedAt': Timestamp.fromDate(updatedAt),
    });
  }
}