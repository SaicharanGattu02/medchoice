class GetPunchInStatusModel {
  Data? data;
  String? status;
  Settings? settings;

  GetPunchInStatusModel({this.data, this.status, this.settings});

  factory GetPunchInStatusModel.fromJson(Map<String, dynamic> json) {
    return GetPunchInStatusModel(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      status: json['status'] as String?,
      settings: json['settings'] != null ? Settings.fromJson(json['settings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'status': status,
      'settings': settings?.toJson(),
    };
  }
}

class Data {
  // Define properties here (e.g., String? someProperty; etc.)

  Data();

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      // Initialize properties from json here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Return properties in json format here
    };
  }
}

class Settings {
  int? success;
  String? message;
  int? status;

  Settings({this.success, this.message, this.status});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      success: json['success'] as int?,
      message: json['message'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
    };
  }
}
