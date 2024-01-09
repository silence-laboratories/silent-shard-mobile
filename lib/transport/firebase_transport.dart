import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_2_party_ecdsa/dart_2_party_ecdsa.dart';

class FirebaseTransport implements Transport {
  final db = FirebaseFirestore.instance;

  @override
  Stream<Map<String, dynamic>?> updates(String collection, String docId) {
    return db.collection(collection).doc(docId).snapshots().map((event) => event.data());
  }

  @override
  Future<void> set(String collection, String docId, Map<String, dynamic> data) {
    return db.collection(collection).doc(docId).set(data);
  }

  @override
  Future<void> delete(String collection, String docId) {
    return db.collection(collection).doc(docId).delete();
  }
}
