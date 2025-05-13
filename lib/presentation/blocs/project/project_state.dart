// lib/presentation/blocs/project/project_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/project.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectState {}

class ProjectsLoading extends ProjectState {}

class ProjectsLoaded extends ProjectState {
  final List<Project> projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object> get props => [projects];
}

class ProjectLoaded extends ProjectState {
  final Project project;

  const ProjectLoaded(this.project);

  @override
  List<Object> get props => [project];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object> get props => [message];
}

class ProjectOperationSuccess extends ProjectState {
  final String message;

  const ProjectOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}