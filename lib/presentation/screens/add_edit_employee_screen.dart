import 'package:employee_management/core/theme/app_colors.dart';
import 'package:employee_management/logic/bloc/employee/employee_bloc.dart';
import 'package:employee_management/logic/bloc/employee/employee_event.dart';
import 'package:employee_management/presentation/widgets/custom_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/employee_model.dart';
import '../../core/utils/date_formatter.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  _AddEditEmployeeScreenState createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _roleController.text = widget.employee!.role;
      _fromDateController.text = widget.employee!.fromDate;
      _toDateController.text = widget.employee!.toDate;
    } else {
      _fromDateController.text = "Today";
    }
  }

  void _saveOrUpdateEmployee() {
    if (_nameController.text != '' &&
        _roleController.text != '' &&
        _fromDateController.text != '') {
      Employee employee = Employee(
        id: widget.employee?.id,
        name: _nameController.text,
        role: _roleController.text,
        fromDate: _fromDateController.text,
        toDate: _toDateController.text,
      );

      Navigator.pop(context, employee);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.employee != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: isEditing
              ? [
                  GestureDetector(
                    onTap: () {
                      context
                          .read<EmployeeBloc>()
                          .add(DeleteEmployee(widget.employee!.id!));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                            SnackBar(
                              content:
                                  const Text("Employee data has been deleted"),
                              action: SnackBarAction(
                                textColor: AppColors.primaryColor,
                                label: "Undo",
                                onPressed: () {
                                  context.read<EmployeeBloc>().add(
                                      UndoDeleteEmployee(widget.employee!.id!));
                                },
                              ),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.fixed,
                            ),
                          )
                          .closed
                          .then((reason) {
                        if (reason == SnackBarClosedReason.timeout) {
                          context.read<EmployeeBloc>().add(
                              PermanentDeleteEmployee(widget.employee!.id!));
                        }
                        Navigator.pop(context);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgPicture.asset(
                        "assets/icons/delete-icon.svg",
                        width: 15,
                        height: 16.88,
                      ),
                    ),
                  )
                ]
              : [],
          title: Text(
            isEditing ? "Edit Employee Details" : "Add Employee Details",
            style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 18),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                  child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        constraints: const BoxConstraints(maxHeight: 40),
                        hintText: "Employee Name",
                        hintStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0XFF949C9E),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 14.62,
                            width: 15,
                            child: SvgPicture.asset('assets/icons/person.svg'),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5)), // Light Gray Border
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _roleController,
                      readOnly: true,
                      onTap: () => _showRoleSelectionSheet(context),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        constraints: const BoxConstraints(maxHeight: 40),
                        hintText: "Select Role",
                        hintStyle: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF949C9E),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 14.62,
                            width: 15,
                            child: SvgPicture.asset('assets/icons/work.svg'),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: SizedBox(
                            height: 11.67,
                            width: 6.67,
                            child:
                                SvgPicture.asset('assets/icons/arrow_down.svg'),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            onTap: () async {
                              final pickedDate = await showDialog<DateTime>(
                                context: context,
                                builder: (context) => CustomCalendarDialog(
                                  from: 'fromDateBox',
                                  fromDateController: _fromDateController,
                                  toDateController: _toDateController,
                                  onDateSelected: (picked) {
                                    if (picked != null) {
                                      _fromDateController.text =
                                          DateFormatter.format(picked);
                                    } else {
                                      _fromDateController.clear();
                                    }
                                    Navigator.pop(context, picked);
                                  },
                                ),
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  _fromDateController.text =
                                      DateFormatter.format(pickedDate);
                                });
                              }
                            },
                            controller: _fromDateController,
                            readOnly: true,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              constraints: const BoxConstraints(maxHeight: 40),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E5E5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E5E5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 19.12,
                                  width: 17,
                                  child: SvgPicture.asset(
                                      'assets/icons/event.svg'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          "assets/icons/date-arrow.svg",
                          width: 13.21,
                          height: 9.54,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: TextFormField(
                            onTap: () async {
                              final pickedDate = await showDialog<DateTime?>(
                                context: context,
                                builder: (context) => CustomCalendarDialog(
                                  from: 'toDateBox',
                                  fromDateController: _fromDateController,
                                  toDateController: _toDateController,
                                  onDateSelected: (picked) {
                                    if (picked != null) {
                                      _toDateController.text =
                                          DateFormatter.format(picked);
                                    } else {
                                      _toDateController.clear();
                                    }
                                    Navigator.pop(context, picked);
                                  },
                                ),
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  _toDateController.text =
                                      DateFormatter.format(pickedDate);
                                });
                              }
                            },
                            controller: _toDateController,
                            readOnly: true,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              constraints: const BoxConstraints(maxHeight: 40),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E5E5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E5E5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: "No date",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 19.12,
                                  width: 17,
                                  child: SvgPicture.asset(
                                      'assets/icons/event.svg'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            border: Border(
              top: BorderSide(
                color: Color(0xFFD3D3D3),
                width: 1.0,
              ),
            )),
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: const Color(0XFFEDF8FF),
                  foregroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: const Color(0XFFFFFFFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: _saveOrUpdateEmployee,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSelectionSheet(BuildContext context) {
    List<String> roles = [
      "Product Designer",
      "Flutter Developer",
      "QA Tester",
      "Product Owner"
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles
                .map(
                  (role) => Column(
                    children: [
                      ListTile(
                        title: Text(
                          role,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0XFF323238)),
                        ),
                        onTap: () {
                          _roleController.text = role;
                          Navigator.pop(context);
                        },
                      ),
                      if (role != roles.last)
                        const Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Color.fromARGB(255, 216, 215, 215)),
                    ],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
