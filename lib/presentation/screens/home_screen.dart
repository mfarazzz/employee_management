import 'package:employee_management/core/theme/app_colors.dart';
import 'package:employee_management/logic/bloc/employee/employee_bloc.dart';
import 'package:employee_management/logic/bloc/employee/employee_event.dart';
import 'package:employee_management/logic/bloc/employee/employee_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/employee_model.dart';
import 'add_edit_employee_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF2F2F2),
      appBar: AppBar(
          title: const Text(
        "Employee List",
        style: TextStyle(
            fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 18),
      )),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EmployeeLoaded) {
            final employees = state.employees;

            if (employees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/no-data.svg",
                      width: 261.79,
                      height: 218.84,
                    ),
                    const SizedBox(height: 4.54),
                    const Text(
                      "No employee records found",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF323238),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                if (employees.any((e) => e.toDate.isEmpty)) ...[
                  _buildSectionHeader("Current Employees"),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: employees
                          .where((e) => e.toDate.isEmpty)
                          .map((employee) =>
                              _buildEmployeeTile(context, employee))
                          .toList(),
                    ),
                  ),
                ],
                if (employees.any((e) => e.toDate.isNotEmpty)) ...[
                  _buildSectionHeader("Previous Employees"),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: employees
                          .where((e) => e.toDate.isNotEmpty)
                          .map((employee) =>
                              _buildEmployeeTile(context, employee))
                          .toList(),
                    ),
                  ),
                ],
                if (employees.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12.0, left: 16.0),
                    child: Text(
                      "Swipe left to delete",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF949C9E),
                      ),
                    ),
                  ),
              ],
            );
          } else if (state is EmployeeError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/no-data.svg", height: 200),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF949C9E),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/no-data.svg", height: 200),
                const SizedBox(height: 12),
                const Text(
                  "No employee records found",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0XFF949C9E),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEmployee = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditEmployeeScreen()),
          );
          if (newEmployee != null) {
            context.read<EmployeeBloc>().add(AddEmployee(newEmployee));
          }
        },
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

// Function to build section headers
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0XFFF2F2F2),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

// Function to build employee list tile with swipe-to-delete
  Widget _buildEmployeeTile(BuildContext context, Employee employee) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Slidable(
            key: Key(employee.id.toString()),
            endActionPane: ActionPane(
              extentRatio: 0.20,
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    context
                        .read<EmployeeBloc>()
                        .add(DeleteEmployee(employee.id!));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                          SnackBar(
                            content:
                                const Text("Employee data has been deleted"),
                            action: SnackBarAction(
                              textColor: AppColors.primaryColor,
                              label: "Undo",
                              onPressed: () {
                                context
                                    .read<EmployeeBloc>()
                                    .add(UndoDeleteEmployee(employee.id!));
                              },
                            ),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.fixed,
                          ),
                        )
                        .closed
                        .then((reason) {
                      if (reason == SnackBarClosedReason.timeout) {
                        context
                            .read<EmployeeBloc>()
                            .add(PermanentDeleteEmployee(employee.id!));
                      }
                    });
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: const IconData(0xe800, fontFamily: 'MyIcons'),
                ),
              ],
            ),
            child: ListTile(
              onTap: () async {
                final updateEmployee = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEditEmployeeScreen(
                            employee: employee,
                          )),
                );
                if (updateEmployee != null) {
                  context
                      .read<EmployeeBloc>()
                      .add(EditEmployee(updateEmployee));
                }
              },
              title: Text(
                employee.name,
                style: const TextStyle(
                    color: Color(0XFF323238),
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.role,
                    style: const TextStyle(
                        color: Color(0XFF949C9E),
                        fontFamily: 'Roboto',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400),
                  ),
                  Text(
                    employee.toDate == ""
                        ? "From ${employee.fromDate}"
                        : "${employee.fromDate} - ${employee.toDate}",
                    style: const TextStyle(
                        color: Color(0XFF949C9E),
                        fontFamily: 'Roboto',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ),
        ),
        const Divider(
          color: Color(0XFFF2F2F2),
          thickness: 0.5,
          height: 1,
        ),
      ],
    );
  }
}
