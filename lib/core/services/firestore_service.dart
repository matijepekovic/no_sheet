// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  // Get a document reference
  DocumentReference document(String path) {
    return _firestore.doc(path);
  }

  // Get a document by ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).get();
  }

  // Get all documents in a collection
  Future<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).get();
  }

  // Add a document to a collection
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) {
    return _firestore.collection(collection).add(data);
  }

  // Set a document (create or update)
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data, {bool merge = true}) {
    return _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  // Update a document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) {
    return _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).delete();
  }

  // Get realtime updates on a document
  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Get realtime updates on a collection
  Stream<QuerySnapshot> collectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}