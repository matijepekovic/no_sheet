// lib/presentation/blocs/project/project_event.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/project.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {}

class LoadProjectsByCustomer extends ProjectEvent {
  final String customerId;

  const LoadProjectsByCustomer(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class LoadProject extends ProjectEvent {
  final String id;

  const LoadProject(this.id);

  @override
  List<Object> get props => [id];
}

class AddProject extends ProjectEvent {
  final Project project;

  const AddProject(this.project);

  @override
  List<Object> get props => [project];
}

class UpdateProject extends ProjectEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object> get props => [project];
}

class DeleteProject extends ProjectEvent {
  final String id;

  const DeleteProject(this.id);

  @override
  List<Object> get props => [id];
}