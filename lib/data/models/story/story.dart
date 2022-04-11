class StoryModel {
  StoryModel({
    this.status,
    this.data,
  });

  int? status;
  List<StoryData>? data;

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
    status: json["status"],
    data: List<StoryData>.from(json["data"].map((x) => StoryData.fromJson(x))),
  );
}

class StoryData{
  StoryData({
    this.id,
    this.uid,
    this.caption,
    this.media,
    this.type,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? uid;
  String? caption;
  String? media;
  String? type;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory StoryData.fromJson(Map<String, dynamic> json) => StoryData(
    id: json["id"],
    uid: json["uid"],
    caption: json["caption"],
    media: json["media"],
    type: json["type"],
    userId: json["user_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );
}
