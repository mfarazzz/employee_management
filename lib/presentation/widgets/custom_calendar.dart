import 'package:employee_management/core/theme/app_colors.dart';
import 'package:employee_management/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class CustomCalendarDialog extends StatefulWidget {
  final Function(DateTime?) onDateSelected;
  final String from;
  final TextEditingController fromDateController;
  final TextEditingController toDateController;

  const CustomCalendarDialog(
      {super.key,
      required this.onDateSelected,
      required this.from,
      required this.fromDateController,
      required this.toDateController});

  @override
  _CustomCalendarDialogState createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  DateTime? selectedDate;
  DateTime currentMonth = DateTime.now();
  DateTime currentDay = DateTime.now();
  int selectedButtonIndex = 0;

  List<Widget>? rows;
  DateTime? firstDayOfMonth;
  DateTime? lastDayOfMonth;
  int? startingWeekday;
  List<DateTime?>? days;

  bool _isDateHighlighted(DateTime date) {
    return selectedDate != null &&
        selectedDate!.year == date.year &&
        selectedDate!.month == date.month &&
        selectedDate!.day == date.day;
  }

  bool _isButtonSelected(DateTime? selectedDate, String buttonType) {
    if (selectedDate == null) {
      return buttonType == "No Date";
    }

    DateTime today = DateTime.now();
    DateTime normalizedSelected =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Calculate the closest next Monday from today
    int daysUntilNextMonday = (DateTime.monday - today.weekday + 7) % 7;
    DateTime nextMonday = today.add(
        Duration(days: daysUntilNextMonday == 0 ? 7 : daysUntilNextMonday));

    // Calculate the closest next Tuesday from today
    int daysUntilNextTuesday = (DateTime.tuesday - today.weekday + 7) % 7;
    DateTime nextTuesday = today.add(
        Duration(days: daysUntilNextTuesday == 0 ? 7 : daysUntilNextTuesday));

    // Exact "After 1 Week" date
    DateTime afterOneWeek = today.add(const Duration(days: 7));

    switch (buttonType) {
      case "Today":
        return normalizedSelected ==
            DateTime(today.year, today.month, today.day);
      case "Next Monday":
        return normalizedSelected ==
            DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
      case "Next Tuesday":
        return normalizedSelected ==
            DateTime(nextTuesday.year, nextTuesday.month, nextTuesday.day);
      case "After 1 week":
        return normalizedSelected ==
            DateTime(afterOneWeek.year, afterOneWeek.month, afterOneWeek.day);
      default:
        return false;
    }
  }

  DateTime _getDateForButton(String buttonLabel) {
    DateTime today = DateTime.now();
    switch (buttonLabel) {
      case "Today":
        return today;
      case "Next Monday":
        return today.add(Duration(days: (8 - today.weekday) % 7));
      case "Next Tuesday":
        return today.add(Duration(days: (9 - today.weekday) % 7));
      case "After 1 week":
        return today.add(const Duration(days: 7));
      default:
        return today;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.from == "fromDateBox" &&
        widget.fromDateController.text.isNotEmpty &&
        widget.fromDateController.text != 'Today') {
      selectedDate =
          DateFormat("dd MMM, yyyy").parse(widget.fromDateController.text);
    } else if (widget.from == "toDateBox" &&
        widget.toDateController.text.isNotEmpty) {
      selectedDate =
          DateFormat("dd MMM, yyyy").parse(widget.toDateController.text);
    } else if (widget.from == "fromDateBox") {
      selectedDate = DateTime.now();
    }
    // To ensure calendar opens on the selected date
    if (selectedDate != null) {
      currentMonth = DateTime(selectedDate!.year, selectedDate!.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: FractionallySizedBox(
        widthFactor: 1.2,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.from == "fromDateBox"
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _calendarButton(
                              "Today",
                              () {
                                setState(() {
                                  selectedDate = DateTime.now();
                                });
                              },
                              0,
                            ),
                            _calendarButton(
                              "Next Monday",
                              () {
                                setState(() {
                                  selectedDate = DateTime.now().add(Duration(
                                      days: (8 - DateTime.now().weekday) % 7));
                                });
                              },
                              1,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _calendarButton(
                              "Next Tuesday",
                              () {
                                setState(() {
                                  selectedDate = DateTime.now().add(Duration(
                                      days: (9 - DateTime.now().weekday) % 7));
                                });
                              },
                              2,
                            ),
                            _calendarButton(
                              "After 1 week",
                              () {
                                setState(() {
                                  selectedDate = DateTime.now()
                                      .add(const Duration(days: 7));
                                });
                              },
                              3,
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _calendarButton(
                          "No Date",

                          () {
                            setState(() {
                              selectedDate = null; // Clears the selected date
                              selectedButtonIndex =
                                  -1; // Ensures the button is visibly selected
                            });
                          },
                          -1, // Unique index for "No Date"
                        ),
                        _calendarButton(
                          "Today",
                          () {
                            setState(() {
                              selectedDate = DateTime.now();
                              selectedButtonIndex = 0;
                            });
                          },
                          0,
                        ),
                      ],
                    ),

              // Month Selector
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => currentMonth = DateTime(
                            currentMonth.year, currentMonth.month - 1, 1));
                      },
                      child: SafeArea(
                        child: SvgPicture.asset("assets/icons/arrow-left.svg"),
                      ),
                    ),
                    const SizedBox(
                      width: 16.5,
                    ),
                    Text(
                      DateFormat.yMMMM().format(currentMonth),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto'),
                    ),
                    const SizedBox(
                      width: 16.5,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => currentMonth = DateTime(
                            currentMonth.year, currentMonth.month + 1, 1));
                      },
                      child: SafeArea(
                        child: SvgPicture.asset("assets/icons/arrow-right.svg"),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Grid
              _buildCalendar(),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/event.svg",
                            width: 20,
                            height: 23,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            selectedDate != null
                                ? DateFormatter.format(selectedDate!)
                                : 'No date',
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ),
                    Row(
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
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: const Color(0XFFFFFFFF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () {
                            if (selectedDate == null) {
                              widget.onDateSelected(
                                  null); // Pass null when "No Date" is selected
                            } else {
                              widget.onDateSelected(selectedDate);
                            }
                            // Navigator.pop(context, selectedDate);
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Calendar Grid
  Widget _buildCalendar() {
    rows = [];
    firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    startingWeekday = firstDayOfMonth!.weekday % 7;
    days = [];
    // Fill empty spaces before the first day
    for (int i = 0; i < startingWeekday!; i++) {
      days!.add(null);
    }

    // Fill actual dates of the month
    for (int i = 1; i <= lastDayOfMonth!.day; i++) {
      days!.add(DateTime(currentMonth.year, currentMonth.month, i));
    }

    for (int i = 0; i < days!.length; i += 7) {
      rows!.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: days!.skip(i).take(7).map((date) {
          return date == null
              ? const SizedBox(
                  width: 44, height: 32) // Empty slot for alignment
              : GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    width: 44,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: (date.year == currentDay.year &&
                              date.month == currentDay.month &&
                              date.day == currentDay.day)
                          ? Border.all(color: AppColors.primaryColor)
                          : null,
                      color: _isDateHighlighted(date)
                          ? Colors.blue
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: selectedDate != null &&
                                selectedDate!.year == date.year &&
                                selectedDate!.month == date.month &&
                                selectedDate!.day == date.day
                            ? Colors.white
                            : (date.year == currentDay.year &&
                                    date.month == currentDay.month &&
                                    date.day == currentDay.day)
                                ? AppColors.primaryColor
                                : const Color(0XFF323238),
                      ),
                    ),
                  ),
                );
        }).toList(),
      ));
    }

    return Column(
      children: [
        // Weekday Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
              .map((day) => SizedBox(
                  width: MediaQuery.of(context).size.width / 11,
                  child: Center(
                      child: Text(
                    day,
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF323238)),
                  ))))
              .toList(),
        ),
        ...rows!,
      ],
    );
  }

  Widget _calendarButton(String text, VoidCallback onTap, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedButtonIndex = index;
          selectedDate = _getDateForButton(text);
          currentMonth = DateTime(selectedDate!.year, selectedDate!.month,
              1); // Update the calendar month
        });
        onTap();
      },
      child: SizedBox(
        width: 146,
        child: TextButton(
          style: TextButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            foregroundColor: _isButtonSelected(selectedDate, text)
                ? const Color(0XFFFFFFFF)
                : AppColors.primaryColor,
            backgroundColor: _isButtonSelected(selectedDate, text)
                ? AppColors.primaryColor
                : const Color(0XFFEDF8FF),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          onPressed: () {
            setState(() {
              selectedButtonIndex = index;
              selectedDate = _getDateForButton(text);
              currentMonth =
                  DateTime(selectedDate!.year, selectedDate!.month, 1);
            });
            onTap();
          },
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
