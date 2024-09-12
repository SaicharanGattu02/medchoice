import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sets to hold present and absent dates
  Set<DateTime> _presentDates = {};
  Set<DateTime> _absentDates = {};
  Set<DateTime> _leavetDates = {};

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  void _initializeDates() {
    final response = {
      "data": {
        "present_dates": [
          "2024-09-06",
          "2024-09-03",
          "2024-09-05"
        ],
        "leave_dates": [],
        "absent_dates": [
          "2024-09-01",
          "2024-09-02",
          "2024-09-04"
        ]
      },
      "settings": {
        "success": 1,
        "message": "Data found successfully.",
        "status": 200
      }
    };

    setState(() {
      _presentDates = (response['data']!['present_dates'] as List)
          .map((date) => DateTime.parse(date).toLocal().toDateOnly())
          .toSet();

      _absentDates = (response['data']!['absent_dates'] as List)
          .map((date) => DateTime.parse(date).toLocal().toDateOnly())
          .toSet();

      _leavetDates = (response['data']!['leave_dates'] as List)
          .map((date) => DateTime.parse(date).toLocal().toDateOnly())
          .toSet();

      print('Present Dates: $_presentDates');
      print('Absent Dates: $_absentDates');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime,
      body: Column(
        children: [
          SizedBox(height: 200,),
          Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  final normalizedDate = date.toDateOnly();
                  if (_presentDates.contains(normalizedDate)) {
                    // Present days
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else if (_absentDates.contains(normalizedDate)) {
                    // Absent days
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else if (_leavetDates.contains(normalizedDate)) {
                    // Absent days
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  else {
                    // Default style for other days
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }
                },
                  todayBuilder: (context, date, _) {
                    final normalizedDate = date.toDateOnly();
                    Color color;
                    if (_presentDates.contains(normalizedDate)) {
                      color = Colors.green; // Color for present days
                    } else if (_absentDates.contains(normalizedDate)) {
                      color = Colors.red; // Color for absent days
                    } else {
                      color = Colors.blueAccent; // Default color for today if not present or absent
                    }
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, date, _) {
                  return Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusIndicator(Colors.green, 'Present'),
              _buildStatusIndicator(Colors.red, 'Absent'),
              _buildStatusIndicator(Colors.yellow, 'Late'),
              _buildStatusIndicator(Colors.brown, 'Leave'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Color color, String status) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Text(status),
      ],
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime toDateOnly() {
    return DateTime(year, month, day);
  }
}
