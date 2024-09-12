class LeaveModel {
  List<Data>? data;
  Settings? settings;

  LeaveModel({this.data, this.settings});

  LeaveModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? staff;
  String? dateFrom;
  String? dateTo;
  String? reason;
  String? status;
  String? name;

  Data(
      {this.id,
        this.staff,
        this.dateFrom,
        this.dateTo,
        this.reason,
        this.status,
        this.name});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    staff = json['staff'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    reason = json['reason'];
    status = json['status'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['staff'] = this.staff;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['name'] = this.name;
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
