import 'dart:async';

import 'package:employee_management/data/models/employee_model.dart';
import 'package:employee_management/data/repositories/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository _repository;
  List<Employee> _employees = []; // Store employees locally for Undo feature
  final Map<int, Employee> _tempDeletedEmployees =
      {}; // Store temporarily deleted employees
  final Map<int, int> _deletedIndexes = {}; // Store removed indexes
  final Map<int, Timer> _deleteTimers =
      {}; // Store timers for each deleted item

  EmployeeBloc(this._repository) : super(EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<EditEmployee>(_onEditEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
    on<UndoDeleteEmployee>(_onUndoDeleteEmployee);
    on<PermanentDeleteEmployee>(_onPermanentDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
      LoadEmployees event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    try {
      _employees = await _repository.getEmployees();
      emit(EmployeeLoaded(List.from(_employees)));
    } catch (e) {
      emit(EmployeeError("Failed to load employees"));
    }
  }

  Future<void> _onAddEmployee(
      AddEmployee event, Emitter<EmployeeState> emit) async {
    try {
      await _repository.addEmployee(event.employee);
      add(LoadEmployees()); // Refresh employees list
    } catch (e) {
      emit(EmployeeError("Failed to add employee"));
    }
  }

  Future<void> _onEditEmployee(
      EditEmployee event, Emitter<EmployeeState> emit) async {
    try {
      await _repository.updateEmployee(event.employee);
      add(LoadEmployees()); // Refresh employees list
    } catch (e) {
      emit(EmployeeError("Failed to update employee"));
    }
  }

  Future<void> _onDeleteEmployee(
      DeleteEmployee event, Emitter<EmployeeState> emit) async {
    try {
      final index = _employees.indexWhere((e) => e.id == event.id);
      if (index == -1) return;

      final removedEmployee = _employees.removeAt(index);
      _tempDeletedEmployees[event.id] = removedEmployee;
      _deletedIndexes[event.id] = index;

      emit(EmployeeLoaded(List.from(_employees)));

      // Start a cancellable timer for deletion
      _deleteTimers[event.id] = Timer(const Duration(seconds: 3), () async {
        if (_tempDeletedEmployees.containsKey(event.id)) {
          add(PermanentDeleteEmployee(event.id));
        }
      });
    } catch (e) {
      emit(EmployeeError("Failed to delete employee"));
    }
  }

  Future<void> _onUndoDeleteEmployee(
      UndoDeleteEmployee event, Emitter<EmployeeState> emit) async {
    if (_tempDeletedEmployees.containsKey(event.id)) {
      final restoredEmployee = _tempDeletedEmployees.remove(event.id)!;
      final index = _deletedIndexes.remove(event.id)!;
      _employees.insert(index, restoredEmployee);

      _deleteTimers[event.id]?.cancel(); // Cancel permanent deletion timer
      _deleteTimers.remove(event.id);

      emit(EmployeeLoaded(List.from(_employees)));
    }
  }

  Future<void> _onPermanentDeleteEmployee(
      PermanentDeleteEmployee event, Emitter<EmployeeState> emit) async {
    try {
      await _repository.deleteEmployee(event.id);
      _tempDeletedEmployees.remove(event.id);
      _deletedIndexes.remove(event.id);
      _deleteTimers.remove(event.id);
    } catch (e) {
      emit(EmployeeError("Failed to permanently delete employee"));
    }
  }
}
