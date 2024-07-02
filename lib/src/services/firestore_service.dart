import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/mappable.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreService<T extends Mappable> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionPath;
  final T Function(Map<String, dynamic>, String) fromMap;
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  FirestoreService(this.collectionPath, this.fromMap);

  CollectionReference get collection {
    return firestore.collection(collectionPath);
  }

  Future<List<T>> fetchAll(String userId) async {
    try {
      QuerySnapshot snapshot = await collection.where('creatorId', isEqualTo: userId).get();
      return snapshot.docs.map((doc) {
        try {
          return fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          _logger.e("Error parsing document ${doc.id}: $e");
          return null;
        }
      }).whereType<T>().toList();
    } catch (e) {
      _logger.e("Failed to fetch documents: $e");
      throw FirestoreException('Failed to fetch documents');
    }
  }


  Future<void> create(Map<String, dynamic> data, String docId, String userId) async {
    try {
      data['creatorId'] = userId;  // Include userId in the data
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
      _logger.e("Failed to update document: $e");
      throw FirestoreException('Failed to update document');
    }
  }

  Future<void> delete(String docId) async {
    try {
      await collection.doc(docId).delete();
    } catch (e) {
      _logger.e("Failed to delete document: $e");
      throw FirestoreException('Failed to delete document');
    }
  }

  Future<void> batchCreate(List<Map<String, dynamic>> data, List<String> docIds) async {
    try {
      WriteBatch batch = firestore.batch();
      for (int i = 0; i < data.length; i++) {
        batch.set(collection.doc(docIds[i]), data[i]);
      }
      await batch.commit();
    } catch (e) {
      _logger.e("Failed to batch create documents: $e");
      throw FirestoreException('Failed to batch create documents: $e');
    }
  }

  Future<void> batchUpdate(List<Map<String, dynamic>> data, List<String> docIds) async {
    try {
      WriteBatch batch = firestore.batch();
      for (int i = 0; i < data.length; i++) {
        batch.update(collection.doc(docIds[i]), data[i]);
      }
      await batch.commit();
    } catch (e) {
      _logger.e("Failed to batch update documents: $e");
      throw FirestoreException('Failed to batch update documents: $e');
    }
  }

  Future<void> batchDelete(List<String> docIds) async {
    try {
      WriteBatch batch = firestore.batch();
      for (String docId in docIds) {
        batch.delete(collection.doc(docId));
      }
      await batch.commit();
    } catch (e) {
      _logger.e("Failed to batch delete documents: $e");
      throw FirestoreException('Failed to batch delete documents: $e');
    }
  }
  // Check if an account name is unique for the current user, excluding the current account ID
  Future<bool> isAccountNameUnique(String name, [String? currentAccountId]) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final querySnapshot = await firestore
        .collection('accounts')
        .where('creatorId', isEqualTo: user.uid)
        .where('name', isEqualTo: name)
        .get();

    // Exclude the current account ID from the results
    final docs = querySnapshot.docs.where((doc) => doc.id != currentAccountId).toList();

    print('Checking uniqueness for name: $name, Excluding ID: $currentAccountId');
    print('Filtered docs length after excluding current account: ${docs.length}');
    return docs.isEmpty;
  }
}


class FirestoreException implements Exception {
  final String message;
  FirestoreException(this.message);

  @override
  String toString() => 'FirestoreException: $message';
}