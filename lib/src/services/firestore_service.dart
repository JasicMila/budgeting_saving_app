import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/mappable.dart';

class FirestoreService<T extends Mappable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionPath;
  final T Function(Map<String, dynamic>, String) fromMap;


  FirestoreService(this.collectionPath, this.fromMap);

  CollectionReference get collection {
    return firestore.collection(collectionPath);
  }

  Future<List<T>> fetchAll() async {
    try {
      QuerySnapshot snapshot = await collection.get();
      return snapshot.docs.map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Failed to fetch documents: $e");
      throw FirestoreException('Failed to fetch documents');
    }
  }


  Future<void> create(Map<String, dynamic> data, String docId) async {
    try {
      await collection.doc(docId).set(data);
    } catch (e) {
      print("Failed to create document: $e");
      throw FirestoreException('Failed to create document');
    }
  }

  Future<void> update(String docId, Map<String, dynamic> data) async {
    try {
      await collection.doc(docId).update(data);
    } catch (e) {
      print("Failed to update document: $e");
      throw FirestoreException('Failed to update document');
    }
  }

  Future<void> delete(String docId) async {
    try {
      await collection.doc(docId).delete();
    } catch (e) {
      print("Failed to delete document: $e");
      throw FirestoreException('Failed to delete document');
    }
  }
}

class FirestoreException implements Exception {
  final String message;
  FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}