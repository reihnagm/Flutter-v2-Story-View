class AuthModel {
  AuthModel({
    this.status,
    this.data,
  });

  int? status;
  AuthData? data;

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    status: json["status"],
    data: AuthData.fromJson(json["data"]),
  );
}

class AuthData {
  AuthData({
    this.uid,
    this.fullname,
    this.pic,
    this.phone,
  });

  String? uid;
  String? fullname;
  String? pic;
  String? phone;

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    uid: json["uid"],
    fullname: json["fullname"],
    pic: json["pic"],
    phone: json["phone"],
  );
}
