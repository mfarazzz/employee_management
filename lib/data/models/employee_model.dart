import 'dart:convert';

class Employee {
  final int? id;
  final String name;
  final String role;
  final String fromDate;
  final String toDate;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.fromDate,
    required this.toDate,
  });

  /// Convert Employee object to JSON for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'fromDate': fromDate,
      'toDate': toDate,
    };
  }

  /// Create Employee object from a database JSON map
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      fromDate: map['fromDate'],
      toDate: map['toDate'],
    );
  }

  /// Convert Employee object to JSON string
  String toJson() => json.encode(toMap());

  /// Create Employee object from JSON string
  factory Employee.fromJson(String source) =>
      Employee.fromMap(json.decode(source));
}
