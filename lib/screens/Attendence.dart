import 'package:fieldsenses/Model/LeaveModel.dart';
import 'package:fieldsenses/screens/Leave.dart';
import 'package:fieldsenses/screens/calender.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';
import '../others/appbar.dart';
import 'home.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  bool _loading = true;
  TextEditingController DateController = TextEditingController();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;


  @override
  void initState() {
    super.initState();
    GetLeaveHistory();
    LeaveData();
    // _initializeDates();
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Sets to hold present and absent dates
  Set<DateTime> _presentDates = {};
  Set<DateTime> _absentDates = {};
  Set<DateTime> _leavetDates = {};


  // void _initializeDates() {
  //   final response = {
  //     "data": {
  //       "present_dates": [
  //         "2024-09-06",
  //         "2024-09-03",
  //         "2024-09-05"
  //       ],
  //       "leave_dates": [],
  //       "absent_dates": [
  //         "2024-09-01",
  //         "2024-09-02",
  //         "2024-09-04"
  //       ]
  //     },
  //     "settings": {
  //       "success": 1,
  //       "message": "Data found successfully.",
  //       "status": 200
  //     }
  //   };
  //
  //   setState(() {
  //     _presentDates = (response['data']!['present_dates'] as List)
  //         .map((date) => DateTime.parse(date).toLocal().toDateOnly())
  //         .toSet();
  //
  //     _absentDates = (response['data']!['absent_dates'] as List)
  //         .map((date) => DateTime.parse(date).toLocal().toDateOnly())
  //         .toSet();
  //
  //     _leavetDates = (response['data']!['leave_dates'] as List)
  //         .map((date) => DateTime.parse(date).toLocal().toDateOnly())
  //         .toSet();
  //
  //     print('Present Dates: $_presentDates');
  //     print('Absent Dates: $_absentDates');
  //   });
  // }

  // Future<void> _selectMonthYear(BuildContext context) async {
  //   final DateTime now = DateTime.now();
  //   final List<int> years = List.generate(50, (index) => now.year - index);
  //
  //   final DateTime? picked = await showDialog<DateTime>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select Month and Year'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButton<int>(
  //               value: selectedMonth,
  //               items: List.generate(12, (index) {
  //                 return DropdownMenuItem(
  //                   value: index + 1,
  //                   child:
  //                       Text(DateFormat('MMMM').format(DateTime(0, index + 1))),
  //                 );
  //               }),
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedMonth = value!;
  //                 });
  //               },
  //             ),
  //             DropdownButton<int>(
  //               value: selectedYear,
  //               items: years.map((year) {
  //                 return DropdownMenuItem(
  //                   value: year,
  //                   child: Text('$year'),
  //                 );
  //               }).toList(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedYear = value!;
  //                 });
  //               },
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 DateController.text = DateFormat('MM-yyyy')
  //                     .format(DateTime(selectedYear, selectedMonth));
  //                 if (DateController.text.isNotEmpty) {
  //                   LeaveData();
  //                 }
  //               });
  //               Navigator.of(context)
  //                   .pop(DateTime(selectedYear, selectedMonth));
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   if (picked != null) {
  //     setState(() {
  //       DateController.text = DateFormat('MM-yyyy').format(picked);
  //       LeaveData();
  //     });
  //   }
  // }

  List<Data> leaveData = [];
  Future<void> GetLeaveHistory() async {
    final data = await Userapi.GetLeaveApi();
    if (data != null) {
      setState(() {
        if (data.settings?.success == 1) {
          _loading = false;
          leaveData = data.data ?? [];
        }
      });
    } else {
      print("data is Not Fetching");
      _loading = false;
    }
  }

  Future<void> LeaveData() async {
    final response = await Userapi.GetAttendenceData();
    print(response);

    if (response.isNotEmpty) {
      setState(() {
        final data = response['data'] as Map<String, dynamic>;

        // Safely access 'present_dates' field and handle possible null values
        final presentDates = data['present_dates'] as List?;
        final absentDates = data['absent_dates'] as List?;
        final leaveDates = data['leave_dates'] as List?;

        _presentDates = (presentDates ?? [])
            .map((date) => DateTime.parse(date).toLocal().toDateOnly())
            .toSet();
        _absentDates = (absentDates ?? [])
            .map((date) => DateTime.parse(date).toLocal().toDateOnly())
            .toSet();
        _leavetDates = (leaveDates ?? [])
            .map((date) => DateTime.parse(date).toLocal().toDateOnly())
            .toSet();

        print('Present Dates: $_presentDates');
        print('Absent Dates: $_absentDates');
        print('Leave Dates: $_leavetDates');
      });
    } else {
      print("Data is not fetching");
      setState(() {
        _loading = false;  // Assuming _loading is defined somewhere in your class
      });
    }
  }



  Future<void> _refreshData() async {
    setState(() {
      _loading = true;
    });
    await GetLeaveHistory();
    await LeaveData();
  }

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: CustomAppBar(
          title: "Attendence",
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF6821F),
                ),
              )
            : RefreshIndicator(color: Color(0xFFF6821F),
          onRefresh: () async{
            HapticFeedback.lightImpact();
            
            await _refreshData();

            },


              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Padding(
                      //   padding:
                      //       const EdgeInsets.only(left: 24, right: 24, top: 20),
                      //   child: Row(
                      //     children: [
                      //       InkWell(
                      //         onTap: () {
                      //           setState(() {
                      //             _loading = true;
                      //           });
                      //           _selectMonthYear(context);
                      //         },
                      //         child: Container(
                      //           child: Row(
                      //             children: [
                      //               Icon(
                      //                 Icons.calendar_month_outlined,
                      //                 size: 20,
                      //                 color: Color(0xFFF6821F),
                      //               ),
                      //               SizedBox(width: 15),
                      //               Text(
                      //                 DateController.text.isEmpty
                      //                     ? "Select Date"
                      //                     : DateController.text,
                      //                 style: TextStyle(
                      //                     color: Color(0xFF000000),
                      //                     fontWeight: FontWeight.w400,
                      //                     fontSize: 16,
                      //                     fontFamily: "Inter"),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //       Spacer(),
                            InkWell(
                              onTap: () async {
                                var res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Leave(),
                                  ),
                                );
                                if (res == true) {
                                  setState(() {
                                    _loading = true;
                                    GetLeaveHistory();
                                  });
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 170,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(right: 15,top: 15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F5FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(
                                        "Apply Leave",
                                        style: TextStyle(
                                          color: Color(0xFF32657B),
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.arrow_circle_right_outlined),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //   padding: EdgeInsets.all(20),
                      //   margin: EdgeInsets.only(top: 30, bottom: 30),
                      //   width: width,
                      //   decoration: BoxDecoration(
                      //       color: Color(0xFFECE3FF).withOpacity(0.30)),
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //         children: [
                      //           Column(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               Container(
                      //                 height: 80,
                      //                 width: 80,
                      //                 decoration: BoxDecoration(
                      //                     color: Color(0xffCAE8C7),
                      //                     borderRadius:
                      //                         BorderRadius.circular(100)),
                      //                 child: Center(
                      //                   child: Text(
                      //                     "${workingDays}",
                      //                     style: TextStyle(
                      //                         color: Color(0xff574AA7),
                      //                         fontWeight: FontWeight.w400,
                      //                         fontFamily: "Inter",
                      //                         fontSize: 22),
                      //                   ),
                      //                 ),
                      //               ),
                      //               SizedBox(
                      //                 height: 20,
                      //               ),
                      //               Text(
                      //                 "Working Days",
                      //                 style: TextStyle(
                      //                     color: Color(0xff574AA7),
                      //                     fontWeight: FontWeight.w400,
                      //                     fontFamily: "Inter",
                      //                     fontSize: 15),
                      //               )
                      //             ],
                      //           ),
                      //           SizedBox(
                      //             width: 30,
                      //           ),
                      //           Column(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               Container(
                      //                 height: 80,
                      //                 width: 80,
                      //                 decoration: BoxDecoration(
                      //                     color: Color(0xffFAFBBD),
                      //                     borderRadius:
                      //                         BorderRadius.circular(100)),
                      //                 child: Center(
                      //                   child: Text(
                      //                     "${absentDays}",
                      //                     style: TextStyle(
                      //                         color: Color(0xff574AA7),
                      //                         fontWeight: FontWeight.w400,
                      //                         fontFamily: "Inter",
                      //                         fontSize: 22),
                      //                   ),
                      //                 ),
                      //               ),
                      //               SizedBox(
                      //                 height: 20,
                      //               ),
                      //               Text(
                      //                 "Absent",
                      //                 style: TextStyle(
                      //                     color: Color(0xff574AA7),
                      //                     fontWeight: FontWeight.w400,
                      //                     fontFamily: "Inter",
                      //                     fontSize: 15),
                      //               )
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Column(
                        children: [
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
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(100),
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
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(100),
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
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(100),
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
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(100),
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
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(100),
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
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.circular(100),
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
                              _buildStatusIndicator(Colors.blue, 'Leave'),
                            ],
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, bottom: 20,top: 20),
                          child: Text(
                            "Leaves",
                            style: TextStyle(
                              color: Color(0xFFF6821F),
                              fontFamily: "Inter",
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xffF6821F),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),

                      if(leaveData.length!=0)...[
                        Container(
                          margin: EdgeInsets.all(15),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: leaveData.length,
                            itemBuilder: (context, index) {
                              final leaveHistory = leaveData[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(15),
                                width: width,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFAF7FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "From: ${leaveHistory.dateFrom}",
                                          style: TextStyle(
                                              color: Color(0xFF32657B),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Inter"),
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          "To: ${leaveHistory.dateTo}",
                                          style: TextStyle(
                                              color: Color(0xFF32657B),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Inter"),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          "Reason: ${leaveHistory.reason}",
                                          style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Inter"),
                                        ),
                                        Spacer(),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            height: 35,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                color:
                                                leaveHistory.status == "approved"
                                                    ? Colors.green
                                                    : leaveHistory.status == "pending"
                                                    ? Colors.blue:Colors.red

                                            ),
                                            child: Center(
                                              child: Text(
                                                leaveHistory.status!,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: "Inter"),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                       ]else...[
                        // SizedBox(height: height*0.17,),
                        Center(
                          child: Lottie.asset(
                            'assets/animations/nodata1.json',
                            height: 360,
                            width: 360,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ));
  }
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

