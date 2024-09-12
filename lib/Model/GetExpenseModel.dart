class GetExpenseModel {
  List<Data>? data;
  Settings? settings;

  GetExpenseModel({this.data, this.settings});

  GetExpenseModel.fromJson(Map<String, dynamic> json) {
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
  String? createdAt;
  String? reason;
  String? amount;
  String? time;
  String? status;
  String? image;
  String? fullName;
  String? designation;

  Data(
      {this.id,
        this.createdAt,
        this.reason,
        this.amount,
        this.time,
        this.status,
        this.image,
        this.fullName,
        this.designation});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    reason = json['reason'];
    amount = json['amount'];
    time = json['time'];
    status = json['status'];
    image = json['image'];
    fullName = json['full_name'];
    designation = json['designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['reason'] = this.reason;
    data['amount'] = this.amount;
    data['time'] = this.time;
    data['status'] = this.status;
    data['image'] = this.image;
    data['full_name'] = this.fullName;
    data['designation'] = this.designation;
    return data;
  }
}

class Settings {
  int? success;
  String? message;
  int? status;
  int? currPage;
  Null? nextPage;
  Null? prevPage;

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
