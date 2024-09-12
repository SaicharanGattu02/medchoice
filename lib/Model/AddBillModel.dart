class AddBillModel {
  Data? data;
  Settings? settings;

  AddBillModel({this.data, this.settings});

  AddBillModel.fromJson(Map<String, dynamic> json) {
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
  String? patient;
  String? treatment;
  String? totalAmount;
  String? time;
  String? paymentMethod;
  String? createdAt;
  String? orderId;
  String? image;

  Data(
      {this.patient,
        this.treatment,
        this.totalAmount,
        this.time,
        this.paymentMethod,
        this.createdAt,
        this.orderId,
        this.image});

  Data.fromJson(Map<String, dynamic> json) {
    patient = json['patient'];
    treatment = json['treatment'];
    totalAmount = json['total_amount'];
    time = json['time'];
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    orderId = json['order_id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['patient'] = this.patient;
    data['treatment'] = this.treatment;
    data['total_amount'] = this.totalAmount;
    data['time'] = this.time;
    data['payment_method'] = this.paymentMethod;
    data['created_at'] = this.createdAt;
    data['order_id'] = this.orderId;
    data['image'] = this.image;
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
