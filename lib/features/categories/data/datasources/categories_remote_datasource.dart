import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/firebase/firestore_json.dart';
import '../models/category_model.dart';

class CategoriesRemoteDataSource {
  CategoriesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<CategoryModel>> getAll() async {
    final snap = await _firestore
        .collection(FirestoreCollections.categories)
        .orderBy('name')
        .get();
    return snap.docs
        .map((doc) => CategoryModel.fromJson(
              FirestoreJson.fromSnapshot(doc.data(), id: doc.id),
            ))
        .toList();
  }

  Future<void> upsert(CategoryModel category) async {
    await _firestore
        .collection(FirestoreCollections.categories)
        .doc(category.id)
        .set(
      {
        'name': category.name,
        'description': category.description,
        'createdAt': Timestamp.fromDate(category.createdAt),
        'updatedAt': Timestamp.fromDate(category.updatedAt),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteById(String id) async {
    await _firestore
        .collection(FirestoreCollections.categories)
        .doc(id)
        .delete();
  }
}