import 'package:employee_management/core/theme/app_theme.dart';
import 'package:employee_management/logic/bloc/employee/employee_bloc.dart';
import 'package:employee_management/logic/bloc/employee/employee_event.dart';
import 'package:employee_management/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/employee_repository.dart';

void main() {
  final EmployeeRepository employeeRepository = EmployeeRepository();

  runApp(MyApp(repository: employeeRepository));
}

class MyApp extends StatelessWidget {
  final EmployeeRepository repository;

  const MyApp({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeBloc(repository)..add(LoadEmployees()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee Manager',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        home: const EmployeeListScreen(),
      ),
    );
  }
}
