class PunchingModel {
  int? success;
  String? message;
  Data? data;

  PunchingModel({this.success, this.message, this.data});

  PunchingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? nameOfEmployee;
  String? date;
  String? location;
  String? latitude;
  String? longitude;

  Data(
      {this.nameOfEmployee,
        this.date,
        this.location,
        this.latitude,
        this.longitude});

  Data.fromJson(Map<String, dynamic> json) {
    nameOfEmployee = json['name_of_employee'];
    date = json['date'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name_of_employee'] = this.nameOfEmployee;
    data['date'] = this.date;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
