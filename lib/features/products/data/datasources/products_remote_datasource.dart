import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/firebase/firestore_json.dart';
import '../models/product_model.dart';

class ProductsRemoteDataSource {
  ProductsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<ProductModel>> getAll() async {
    final snap = await _firestore
        .collection(FirestoreCollections.products)
        .orderBy('name')
        .get();
    return snap.docs
        .map((doc) => ProductModel.fromJson(
              FirestoreJson.fromSnapshot(doc.data(), id: doc.id),
            ))
        .toList();
  }

  Future<void> upsert(ProductModel product) async {
    await _firestore
        .collection(FirestoreCollections.products)
        .doc(product.id)
        .set(
      {
        'name': product.name,
        'description': product.description,
        'categoryId': product.categoryId,
        'entryDate': Timestamp.fromDate(product.entryDate),
        'expirationDate': product.expirationDate == null
            ? null
            : Timestamp.fromDate(product.expirationDate!),
        'currentStock': product.currentStock,
        'purchaseCost': product.purchaseCost,
        'createdAt': Timestamp.fromDate(product.createdAt),
        'updatedAt': Timestamp.fromDate(product.updatedAt),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteById(String id) async {
    await _firestore
        .collection(FirestoreCollections.products)
        .doc(id)
        .delete();
  }
}