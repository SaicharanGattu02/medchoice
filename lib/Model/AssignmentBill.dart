class TreatmentBillModel {
  Data? data;
  Settings? settings;

  TreatmentBillModel({this.data, this.settings});

  TreatmentBillModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.settings != null) {
      data['settings'] = this.settings!.toJson();
    }
    return data;
  }
}

class Data {
  Patient? patient;
  String? status;
  String? agentAssigned;
  String? dueDate;
  String? amount;
  String? treatment;
  String? patientId;
  String? treatmentId;
  String? timeTaken;

  Data(
      {this.patient,
        this.status,
        this.agentAssigned,
        this.dueDate,
        this.amount,
        this.treatment,
        this.patientId,
        this.treatmentId,
        this.timeTaken});

  Data.fromJson(Map<String, dynamic> json) {
    patient =
    json['patient'] != null ? new Patient.fromJson(json['patient']) : null;
    status = json['status'];
    agentAssigned = json['agent_assigned'];
    dueDate = json['due_date'];
    amount = json['amount'];
    treatment = json['treatment'];
    patientId = json['patient_id'];
    treatmentId = json['treatment_id'];
    timeTaken = json['time_taken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.patient != null) {
      data['patient'] = this.patient!.toJson();
    }
    data['status'] = this.status;
    data['agent_assigned'] = this.agentAssigned;
    data['due_date'] = this.dueDate;
    data['amount'] = this.amount;
    data['treatment'] = this.treatment;
    data['patient_id'] = this.patientId;
    data['treatment_id'] = this.treatmentId;
    data['time_taken'] = this.timeTaken;
    return data;
  }
}

class Patient {
  String? uid;
  String? patientName;
  String? gender;
  int? age;
  Null? diagnosis;
  String? mobile;
  String? address;

  Patient(
      {this.uid,
        this.patientName,
        this.gender,
        this.age,
        this.diagnosis,
        this.mobile,
        this.address});

  Patient.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    patientName = json['patient_name'];
    gender = json['gender'];
    age = json['age'];
    diagnosis = json['diagnosis'];
    mobile = json['mobile'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['patient_name'] = this.patientName;
    data['gender'] = this.gender;
    data['age'] = this.age;
    data['diagnosis'] = this.diagnosis;
    data['mobile'] = this.mobile;
    data['address'] = this.address;
    return data;
  }
}

class Settings {
  int? success;
  String? message;
  int? status;

  Settings({this.success, this.message, this.status});

  Settings.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}
