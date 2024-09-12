import 'dart:io';

import 'package:fieldsenses/screens/home.dart';
import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Model/GetExpenseModel.dart';
import '../others/appbar.dart';
import 'AddExpense.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  // bool isactive = true;
  bool loading = true; // Ensure loading is true initially until data is fetched

  List<Data> Expenses = [];

  @override
  void initState() {
    GetExpencesData();
    super.initState();
  }

  Future<void> GetExpencesData() async {
    final data = await Userapi.GetRecentExpences();
    if (data != null) {
      setState(() {
        if (data.settings?.success == 1) {
          loading = false;
          Expenses = data.data ?? [];
        }
      });
    } else {
      print("Data is not fetching");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return
      WillPopScope(
        onWillPop: () async {
          Navigator.pop(context,true);
          return false; // Prevents the back navigation
        },
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFF6821F),
          toolbarHeight: height * 0.056,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context, true);
              },
              child: Icon(
                Icons.arrow_back,
                color: Color(0xFFFFFFFF),
              )),
          title: Text(
            "Expense History ",
            style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: "Inter"),
          ),
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF6821F),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExpenses(),
                          ),
                        );
                        if (res == true) {
                          setState(() {
                            loading = true;
                            GetExpencesData();
                          });
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 170,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F5FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                "Add Expense",
                                style: TextStyle(
                                  color: Color(0xFF32657B),
                                  fontFamily: "Inter",
                                  decorationColor: Color(0xff32657B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.add,
                                color: Color(0xFF32657B),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    if (Expenses.length != 0) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: Expenses.length,
                        itemBuilder: (context, index) {
                          final expense = Expenses[index];
                          return Card(
                            margin: EdgeInsets.only(top: 20),
                            color: Color(0xFFF8FDFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: width,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFE1E7FD),
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Expense",
                                        style: TextStyle(
                                          color: Color(0xFFF6821F),
                                          fontSize: 13,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Date: ${expense.createdAt}",
                                        style: TextStyle(
                                          color: Color(0xFF32657B),
                                          fontSize: 13,
                                          fontFamily: "Inter",
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Time: ${expense.time}",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFF32657B),
                                            fontSize: 13,
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  _buildExpenseDetailRow(
                                      "Expense Reason", expense.reason),
                                  // SizedBox(height: 5),
                                  // _buildExpenseDetailRow("Expense Description", expense.),
                                  SizedBox(height: 5),
                                  _buildExpenseDetailRow("Bill", expense.amount),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        height: height * 0.17,
                      ),
                      Center(
                        child: Lottie.asset(
                          'assets/animations/nodata1.json',
                          height: 360,
                          width: 360,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
      );
  }

  Widget _buildExpenseDetailRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF32657B),
            fontSize: 13,
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value ?? '',
          style: TextStyle(
            color: Color(0xFF32657B),
            fontSize: 13,
            fontFamily: "Inter",
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
