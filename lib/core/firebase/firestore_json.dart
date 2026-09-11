import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreJson {
  FirestoreJson._();

  /// Convierte un documento de Firestore en un mapa serializable:
  /// - Timestamps -> ISO-8601 (compatible con json_serializable)
  /// - Añade el `id` del documento como campo si se provee.
  static Map<String, dynamic> fromSnapshot(
    Map<String, dynamic>? data, {
    String? id,
  }) {
    final json = Map<String, dynamic>.from(data ?? const {});
    for (final entry in json.entries.toList()) {
      if (entry.value is Timestamp) {
        json[entry.key] = (entry.value as Timestamp).toDate().toIso8601String();
      }
    }
    if (id != null) json['id'] = id;
    return json;
  }
}