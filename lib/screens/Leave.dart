import 'package:fieldsenses/services/UserApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../others/appbar.dart';
import '../utils/ShakeWidget.dart';

class Leave extends StatefulWidget {
  const Leave({super.key});

  @override
  State<Leave> createState() => _LeaveState();
}

class _LeaveState extends State<Leave> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isContinueClicked = false;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  @override
  void initState() {
    // _fromDateController.addListener(() {
    //   setState(() {
    //     _validateFromDate = "";
    //   });
    // });
    // _toDateController.addListener(() {
    //   setState(() {
    //     _validateToDate = "";
    //   });
    // });
    // _reasonController.addListener(() {
    //   setState(() {
    //     _validateReason = "";
    //   });
    // });
    super.initState();
  }

  String _validateFromDate="";
  String _validateToDate="";
  String _validateReason="";
  void _validateFields() {
    String validateFromDate="";
    String validateToDate="";
    String validateReason="";
    if (_fromDateController.text == "" || _fromDateController.text.isEmpty) {
      validateFromDate = "Please select from date.";
    }

    if (_toDateController.text == "" || _toDateController.text.isEmpty) {
      validateToDate = "Please select to date.";
    }


    if (_reasonController.text == "" || _reasonController.text.isEmpty) {
      validateReason = "Please give reason for leave..";
    }

    // Check if any validations failed
    if (validateFromDate != "" ||
        validateToDate != "" ||
        validateReason != "") {
      setState(() {
        _validateFromDate = validateFromDate ?? "";
        _validateToDate = validateToDate ?? "";
        _validateReason = validateReason ?? "";
        _isContinueClicked=false;
      });
      print("MEdchoice");
    } else {
      print("ahguojn");
      SubmitLeaveApi();
    }
  }

  Future<void> SubmitLeaveApi() async {
    String dateFrom = _fromDateController.text;
    String dateTo = _toDateController.text;
    String reason = _reasonController.text;
    final leaveResponse = await Userapi.LeaveApi(dateFrom, dateTo, reason);
    if (leaveResponse != null && leaveResponse.settings != null) {
      setState(() {
        if( leaveResponse.settings?.success==1){
          _isContinueClicked=false;
          Navigator.pop(context,true);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              "Leave Applied successfully!",
              style: TextStyle(color: Color(0xff000000)),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFF6821F),
          ));
        } else {
          _isContinueClicked=false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                leaveResponse?.settings?.message??"",
              style: TextStyle(color: Color(0xff000000)),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFFF6821F),
          ));
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return
      WillPopScope(
        onWillPop: () async {
          Navigator.pop(context,true);
          return false; // Prevents the back navigation
        },
        child: Scaffold(
        appBar: CustomAppBar(
          title: "Apply Leave",
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                _buildDateField("From", _fromDateController),
                if (_validateFromDate.isNotEmpty) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                    width: width * 0.8,
                    child: ShakeWidget(
                      key: Key("value"),
                      duration: Duration(milliseconds: 700),
                      child: Text(
                        _validateFromDate,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color:Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(
                    height: 20,
                  ),
                ],
                _buildDateField("To", _toDateController),
                if (_validateToDate.isNotEmpty) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                    width: width * 0.8,
                    child: ShakeWidget(
                      key: Key("value"),
                      duration: Duration(milliseconds: 700),
                      child: Text(
                        _validateToDate,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color:Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(
                    height: 20,
                  ),
                ],
                const Text(
                  "Reason For Leave",
                  style: TextStyle(
                      color: Color(0xFF32657B),
                      fontFamily: "Inter",
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 12),
                Container(
                  height: height * 0.2,
                  width: width,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E7FD).withOpacity(0.30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your reason here",
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        letterSpacing: 0,
                        height: 1.2,
                        color: Color(0xffAFAFAF),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                if (_validateReason.isNotEmpty) ...[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 8,bottom: 10,top: 5),
                    width: width * 0.8,
                    child: ShakeWidget(
                      key: Key("value"),
                      duration: Duration(milliseconds: 700),
                      child: Text(
                        _validateReason,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color:Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(
                    height: 20,
                  ),
                ],
                SizedBox(height: height * 0.1),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context,true);
                      },
                      child: Container(
                        height: 50,
                        width: 110,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA5B2BF),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        if(_isContinueClicked){

                        }else{
                          setState(() {
                            _isContinueClicked=true;
                            _validateFields();
                          });
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 110,
                        padding: const EdgeInsets.only(left: 15,right: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6821F),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child:  Center(
                          child: (_isContinueClicked)?
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                              :
                          Text(
                            "Apply",
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
            ),
      );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: Color(0xFF32657B),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            _selectDate(context, controller);
          },
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Select date",
                suffixIcon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xffF6821F),
                ),
                hintStyle: const TextStyle(
                  fontSize: 15,
                  letterSpacing: 0,
                  height: 1.2,
                  color: Color(0xffAFAFAF),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xffffffff),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(width: 1, color: Color(0xffCDE2FB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(width: 1, color: Color(0xffCDE2FB)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
