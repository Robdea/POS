import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FirebaseConnectionStatus { connected, noConnection, unknown, firestoreDisabled }

class FirebaseConnectionService {
  static Future<FirebaseConnectionStatus> check() async {
    try {
      await FirebaseFirestore.instance.collection('categories').limit(1).get();
      return FirebaseConnectionStatus.connected;
    } on FirebaseException catch (e) {
      if (_isFirestoreApiDisabled(e)) {
        return FirebaseConnectionStatus.firestoreDisabled;
      }
      if (e.code == 'permission-denied' || e.code == 'unauthenticated') {
        return FirebaseConnectionStatus.connected;
      }
      return FirebaseConnectionStatus.noConnection;
    } catch (_) {
      return FirebaseConnectionStatus.noConnection;
    }
  }

  static bool _isFirestoreApiDisabled(FirebaseException e) {
    final message = (e.message ?? '').toLowerCase();
    return e.code == 'permission-denied' &&
        (message.contains('api has not been used') ||
            message.contains('disabled'));
  }
}

final firebaseConnectionProvider =
    FutureProvider<FirebaseConnectionStatus>((ref) {
  return FirebaseConnectionService.check();
});