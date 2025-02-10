import 'package:employee_management/data/models/employee_model.dart';
import 'package:equatable/equatable.dart';

abstract class EmployeeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final Employee employee;
  AddEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}

class EditEmployee extends EmployeeEvent {
  final Employee employee;
  EditEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final int id;
  DeleteEmployee(this.id);

  @override
  List<Object?> get props => [id];
}

class PermanentDeleteEmployee extends EmployeeEvent {
  final int id;
  PermanentDeleteEmployee(this.id);

  @override
  List<Object?> get props => [id];
}

class UndoDeleteEmployee extends EmployeeEvent {
  final int id;

  UndoDeleteEmployee(this.id);
}
