class AssignmentModel {
  List<Data>? data;
  Settings? settings;

  AssignmentModel({this.data, this.settings});

  AssignmentModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.settings != null) {
      data['settings'] = this.settings!.toJson();
    }
    return data;
  }
}

class Data {
  String? patientName;
  String? treatment;
  String? address;
  String? patientId;
  String? uid;
  String? status;

  Data(
      {this.patientName,
        this.treatment,
        this.address,
        this.patientId,
        this.uid,
        this.status});

  Data.fromJson(Map<String, dynamic> json) {
    patientName = json['patient_name'];
    treatment = json['treatment'];
    address = json['address'];
    patientId = json['patient_id'];
    uid = json['uid'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patient_name'] = this.patientName;
    data['treatment'] = this.treatment;
    data['address'] = this.address;
    data['patient_id'] = this.patientId;
    data['uid'] = this.uid;
    data['status'] = this.status;
    return data;
  }
}

class Settings {
  int? success;
  String? message;
  int? status;
  int? currPage;
  String? nextPage;
  String? prevPage;

  Settings(
      {this.success,
        this.message,
        this.status,
        this.currPage,
        this.nextPage,
        this.prevPage});

  Settings.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    status = json['status'];
    currPage = json['curr_page'];
    nextPage = json['next_page'];
    prevPage = json['prev_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['status'] = this.status;
    data['curr_page'] = this.currPage;
    data['next_page'] = this.nextPage;
    data['prev_page'] = this.prevPage;
    return data;
  }
}
