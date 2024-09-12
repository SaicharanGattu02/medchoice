class BillingHistoryModel {
  List<Data>? data;
  Settings? settings;

  BillingHistoryModel({this.data, this.settings});

  BillingHistoryModel.fromJson(Map<String, dynamic> json) {
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
