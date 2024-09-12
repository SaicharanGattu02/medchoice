import 'dart:convert';
import 'dart:io';
import 'package:fieldsenses/Model/AssignmentModel.dart';
import 'package:fieldsenses/Model/ExpenseModel.dart';
import 'package:http/http.dart' as http;
import 'package:fieldsenses/Model/LeaveModel.dart';

import '../Model/AddBillModel.dart';
import '../Model/ApplyLeaveModel.dart';
import '../Model/AssignmentBill.dart';
import '../Model/AttendenceModel.dart';
import '../Model/BillingHistoryModel.dart';
import '../Model/GetExpenseModel.dart';
import '../Model/GetPunchInStatusModel.dart';
import '../Model/OtpVerifyingModel.dart';
import '../Model/ProfileModel.dart';
import '../Model/PunchingModel.dart';
import '../Model/SendModel.dart';
import '../Model/TypesOfExpenseModel.dart';
import 'apicalls.dart';
import 'otherservices.dart';

class Userapi {
  static const String host = "http://192.168.0.169:8080";
  // static const String host = "https://admin.pixlapps.net";

  static Future<ApplyLeaveModel?> LeaveApi(
    String dateFrom,
    String dateTo,
    String reason,
  ) async {
    try {
      Map<String, String> data = {
        "date_from": dateFrom,
        "date_to": dateTo,
        "reason": reason,
      };
      final url = Uri.parse("${host}/api/apply-leave");
      final headers = await getheader();
      final response = await http.post(url, headers: headers,body: jsonEncode(data));
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ApplyLeaveModel.fromJson(jsonResponse);
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  static Future<AssignmentModel?> GetCustomerDataApi() async {
    final url = Uri.parse("$host/api/my-tasks");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (response != null) {
        print("GetCustomerDataApi response:${response.body}");
        return AssignmentModel.fromJson(jsonDecode(response.body));
      } else {
        print("Null Response");
        return null;
      }
    } else {
      print("error:${response.statusCode}");
    }
  }

  static Future<BillingHistoryModel?> GetBillingApi() async {
    final url = Uri.parse("$host/api/my-billings");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      if (response != null) {
        print("GetBillingApi response:${response.body}");
        return BillingHistoryModel.fromJson(jsonDecode(response.body));
      } else {
        print("Null Response");
        return null;
      }
    } else {
      print("error:${response.statusCode}");
    }
  }

  static Future<LeaveModel?> GetLeaveApi() async {
    final url = Uri.parse("$host/api/my-leaves");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // print("Response:${jsonResponse}");
      if (response != null) {
        print("GetLeaveApi response:${response.body}");
        return LeaveModel.fromJson(jsonDecode(response.body));
      } else {
        print("Null Response");
        return null;
      }
    } else {
      print("error:${response.statusCode}");
    }
  }

  static Future<GetExpenseModel?> GetRecentExpences() async {
    final url = Uri.parse("${host}/api/my-expense");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("GetRecentExpences Response:${jsonResponse}");
      if (response != null) {
        print("GetRecentExpences response:${response.body}");
        return GetExpenseModel.fromJson(jsonDecode(response.body));
      } else {
        print("Null Response");
        return null;
      }
    } else {
      print("error:${response.statusCode}");
    }
  }

  static Future<AddExpenseModel?> AddExpenseApi(
      String description, String reason, String amount,
      File image) async {
    try {
      Map<String, String> data = {
        "description": description,
        "reason": reason,
        "amount": amount,
      };
      print("AddExpenseApi data: $data");
      final headers = await getheader();
      final res = await postImage(data,"$host/api/staff-expense", headers, image);
      if (res != null && res.isNotEmpty) {
        print("AddExpenseApi Response: $res");
        final parsedRes = jsonDecode(res);
        return AddExpenseModel.fromJson(parsedRes);
      } else {
        print("Null or empty response");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  static Future<AddExpenseModel?> UploadProfie(File image) async {
    try {
      final headers = await getheader();
      final res = await postImage({},"$host/api/staff-profile", headers, image);
      if (res != null && res.isNotEmpty) {
        print("UploadProfie Response: $res");
        final parsedRes = jsonDecode(res);
        return AddExpenseModel.fromJson(parsedRes);
      } else {
        print("Null or empty response");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }


  static Future<Map<String, dynamic>> GetAttendenceData() async {
    try {
      final url = Uri.parse("${host}/api/my-attendance");
      final headers = await getheader();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print("GetAttendenceData Status:${response.body}");
        return jsonResponse;
      } else {
        print("Request failed with status: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("Error occurred: $e");
      return {};
    }
  }


  // static Future<TreatmentBillModel?> GetCustomerBill(String uid) async {
  //   print("Requesting bill for UID: $uid");
  //
  //   final url = Uri.parse("${host}/api/single-assignment/${uid}");
  //   final headers = await getheader();
  //   final response = await http.get(url, headers: headers);
  //
  //   print("Response Status Code: ${response.statusCode}");
  //
  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(response.body);
  //     // print("Response JSON: $jsonResponse");
  //
  //     if (jsonResponse != null) {
  //       print("GetCustomerBill response: ${response.body}");
  //       return TreatmentBillModel.fromJson(jsonDecode(response.body));
  //     } else {
  //       print("Null JSON Response");
  //       return null;
  //     }
  //   } else {
  //     print("Error: ${response.statusCode} - ${response.reasonPhrase}");
  //     print("Response Body: ${response.body}");
  //     return null;
  //   }
  // }

  static Future<TreatmentBillModel?> GetCustomerBill(String uid) async {
    print("Requesting bill for UID: $uid");
    final url = Uri.parse("${host}/api/single-assignment/${uid}");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);

    print("Response Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // print("Response JSON: $jsonResponse");

      if (jsonResponse != null) {
        print("GetCustomerBill response: ${response.body}");
        return TreatmentBillModel.fromJson(jsonDecode(response.body));
      } else {
        print("Null JSON Response");
        return null;
      }
    } else {
      print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      print("Response Body: ${response.body}");
      return null;
    }
  }

  static Future<TreatmentBillModel?> PutTreatment(
      String uid, String treatment) async {
    print("Requesting bill for UID: $uid");
    print("Requesting bill for UID: $treatment");

    final url = Uri.parse("${host}/api/single-assignment/${uid}?status=${treatment}");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("PutTreatment Status:${response.body}");
      return TreatmentBillModel.fromJson(jsonResponse);
    } else {
      // print("Request failed with status: ${response.statusCode}");
      // return null;
    }
  }

  static Future<TreatmentBillModel?> PostPunchInAPI(
        String lat, String long,String location,) async {
    try {
      Map<String, String> data = {
        "punch_in_latitude": lat,
        "punch_in_longitude": long,
        "punch_in_address": location,
      };
      print("Punching data: $data");

      final url = Uri.parse("${host}/api/punch");
      final headers = await getheader();
      final response = await http.post(url, headers: headers,body: jsonEncode(data));
      if (response!=null) {
        final jsonResponse = jsonDecode(response.body);
        print("Punchin response:${response.body}");
        return TreatmentBillModel.fromJson(jsonResponse);
      } else {
        return null;
      }

    } catch (e) {}
  }

  static Future<TreatmentBillModel?> SendingLocationUpdatesApi(
      String lat, String long,String location,) async {
    try {
      Map<String, String> data = {
        "latitude": lat,
        "longitude": long,
        "location": location,
      };
      print("SendingLocationUpdatesApi data: $data");

      final url = Uri.parse("${host}/api/punch");
      final headers = await getheader();
      final response = await http.post(url, headers: headers,body: jsonEncode(data));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("SendingLocationUpdatesApi Status:${response.body}");
        return TreatmentBillModel.fromJson(jsonResponse);
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}"); // Add this line
        return null;
      }

    } catch (e) {}
  }

  static Future<AddBillModel?> AddbillApi(String patient_id, String service_id,String total_amount,String payment_method, File? image,uid) async {
    try {
      Map<String, String> data = {
        "payment_method": payment_method,
        "patient_id": patient_id,
        "service_id": service_id,
        "total_amount": total_amount,
        "assignment": uid,
      };
      print("AddbillApi data: $data");

      final headers = await getheader();
      final response = await postImage1(data,"${host}/api/add-billing", headers, image);
      if (response != null && response.isNotEmpty) {
        print("AddbillApi Response: $response");
        final parsedRes = jsonDecode(response);
        return AddBillModel.fromJson(parsedRes);
      } else {
        print("Null or empty response");
        return null;
      }
    } catch (e) {}
  }

  static Future<TreatmentBillModel?> PostPunchOutAPI(
      String lat, String long,String location,) async {
    try {
      Map<String, String> data = {
        "punch_out_latitude": lat,
        "punch_out_longitude": long,
        "punch_out_address": location,
      };
      print("PostPunchOutAPI data: $data");

      final url = Uri.parse("${host}/api/punch");
      final headers = await getheader();
      final response = await http.put(url, headers: headers,body: jsonEncode(data));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("PostPunchOutAPI response:${response.body}");
        return TreatmentBillModel.fromJson(jsonResponse);
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}"); // Add this line
        return null;
      }

    } catch (e) {}
  }

  static Future<GetPunchInStatusModel?>GetPuchInStatusApi() async {
    try {
      final url = Uri.parse("${host}/api/punch");
      final headers = await getheader();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("Punchinout Status:${response.body}");
        return GetPunchInStatusModel.fromJson(jsonResponse);
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}"); // Add this line
        return null;
      }
    } catch (e) {}
  }




  static Future<LoginModel?> PostLogin(String mail, String password) async {
    try {
      Map<String, String> data = {
        "email": mail,
        "password": password,
      };
      print("PostLogin : $data");
      final url = Uri.parse("${host}/auth/login");
      final headers = await getheader1();
      final response = await http.post(url, headers: headers,body: jsonEncode(data));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("PostLogin Status:${response.body}");
        return LoginModel.fromJson(jsonResponse);
      } else {
        print("Request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

  static Future<ProfileModel?>GetProfile() async {
    try {
      final url = Uri.parse("${host}/api/staff-profile");
      final headers = await getheader();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("GetProfile Status:${response.body}");
        return ProfileModel.fromJson(jsonResponse);
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Response body: ${response.body}"); // Add this line
        return null;
      }
    } catch (e) {}
  }

  static Future<TypesOfExpenseModel?> GetTypesOfExpensesApi() async {
    final url = Uri.parse("$host/api/expense-type");
    final headers = await getheader();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      if (response != null) {
        print("GetTypesOfExpensesApi response:${response.body}");
        return TypesOfExpenseModel.fromJson(jsonDecode(response.body));
      } else {
        print("Null Response");
        return null;
      }
    } else {
      print("error:${response.statusCode}");
    }
  }
}
