// lib/presentation/blocs/project/project_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'project_event.dart';
import 'project_state.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../data/models/project.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository _projectRepository;
  StreamSubscription<List<Project>>? _projectsSubscription;

  ProjectBloc({required ProjectRepository projectRepository})
      : _projectRepository = projectRepository,
        super(ProjectsInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<LoadProjectsByCustomer>(_onLoadProjectsByCustomer);
    on<LoadProject>(_onLoadProject);
    on<AddProject>(_onAddProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
  }

  Future<void> _onLoadProjects(
      LoadProjects event,
      Emitter<ProjectState> emit,
      ) async {
    emit(ProjectsLoading());
    try {
      await _projectsSubscription?.cancel();
      _projectsSubscription = _projectRepository.getProjects().listen(
            (projects) => add(ProjectsLoaded(projects) as ProjectEvent),
        onError: (error) => add(ProjectError(error.toString()) as ProjectEvent),
      );
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onLoadProjectsByCustomer(
      LoadProjectsByCustomer event,
      Emitter<ProjectState> emit,
      ) async {
    emit(ProjectsLoading());
    try {
      await _projectsSubscription?.cancel();
      _projectsSubscription = _projectRepository.getProjectsByCustomer(event.customerId).listen(
            (projects) => add(ProjectsLoaded(projects) as ProjectEvent),
        onError: (error) => add(ProjectError(error.toString()) as ProjectEvent),
      );
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onLoadProject(
      LoadProject event,
      Emitter<ProjectState> emit,
      ) async {
    emit(ProjectsLoading());
    try {
      final project = await _projectRepository.getProject(event.id);
      emit(ProjectLoaded(project));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onAddProject(
      AddProject event,
      Emitter<ProjectState> emit,
      ) async {
    try {
      await _projectRepository.addProject(event.project);
      emit(const ProjectOperationSuccess('Project added successfully'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onUpdateProject(
      UpdateProject event,
      Emitter<ProjectState> emit,
      ) async {
    try {
      await _projectRepository.updateProject(event.project);
      emit(const ProjectOperationSuccess('Project updated successfully'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  Future<void> _onDeleteProject(
      DeleteProject event,
      Emitter<ProjectState> emit,
      ) async {
    try {
      await _projectRepository.deleteProject(event.id);
      emit(const ProjectOperationSuccess('Project deleted successfully'));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }
}