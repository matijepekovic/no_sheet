// lib/data/repositories/project_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  ProjectRepositoryImpl({
    required FirebaseFirestore firestore,
    required String userId,
  }) : _firestore = firestore, _userId = userId;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _projectsCollection =>
      _firestore.collection('projects');

  @override
  Stream<List<Project>> getProjects() {
    return _projectsCollection
        .where('businessId', isEqualTo: _userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Project.fromFirestore(doc))
        .toList());
  }

  @override
  Stream<List<Project>> getProjectsByCustomer(String customerId) {
    return _projectsCollection
        .where('businessId', isEqualTo: _userId)
        .where('customerId', isEqualTo: customerId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Project.fromFirestore(doc))
        .toList());
  }

  @override
  Future<Project> getProject(String id) async {
    final doc = await _projectsCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Project not found');
    }
    return Project.fromFirestore(doc);
  }

  @override
  Future<void> addProject(Project project) async {
    await _projectsCollection.doc(project.id).set(project.toMap());
  }

  @override
  Future<void> updateProject(Project project) async {
    await _projectsCollection.doc(project.id).update(project.toMap());
  }

  @override
  Future<void> deleteProject(String id) async {
    await _projectsCollection.doc(id).delete();
  }
}