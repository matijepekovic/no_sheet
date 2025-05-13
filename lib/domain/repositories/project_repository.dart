// lib/domain/repositories/project_repository.dart
import '../../data/models/project.dart';

abstract class ProjectRepository {
  Stream<List<Project>> getProjects();
  Stream<List<Project>> getProjectsByCustomer(String customerId);
  Future<Project> getProject(String id);
  Future<void> addProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String id);
}