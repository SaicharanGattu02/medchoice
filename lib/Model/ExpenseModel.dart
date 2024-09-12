class AddExpenseModel {
  Data? data;
  Settings? settings;

  AddExpenseModel({this.data, this.settings});

  AddExpenseModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? date;
  String? reason;
  String? amount;
  String? status;
  String? image;
  String? fullName;
  String? designation;

  Data(
      {this.id,
        this.date,
        this.reason,
        this.amount,
        this.status,
        this.image,
        this.fullName,
        this.designation});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    reason = json['reason'];
    amount = json['amount'];
    status = json['status'];
    image = json['image'];
    fullName = json['full_name'];
    designation = json['designation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['reason'] = this.reason;
    data['amount'] = this.amount;
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
