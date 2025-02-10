import '../../core/db/database_helper.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Employee>> getEmployees() async {
    return await _databaseHelper.getAllEmployees();
  }

  Future<int> addEmployee(Employee employee) async {
    return await _databaseHelper.insertEmployee(employee);
  }

  Future<int> updateEmployee(Employee employee) async {
    return await _databaseHelper.updateEmployee(employee);
  }

  Future<int> deleteEmployee(int id) async {
    return await _databaseHelper.deleteEmployee(id);
  }
}
