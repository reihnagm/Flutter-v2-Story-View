class StoryModel {
  StoryModel({
    this.status,
    this.data,
  });

  int? status;
  List<StoryUser>? data;

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
    status: json["status"],
    data: List<StoryUser>.from(json["data"].map((x) => StoryUser.fromJson(x))),
  );
}

class StoryUser {
  StoryUser({
    this.user,
  });

  UserItem? user;

  factory StoryUser.fromJson(Map<String, dynamic> json) => StoryUser(
    user: UserItem.fromJson(json["user"]),
  );
}

class UserItem {
  UserItem({
    this.uid,
    this.fullname,
    this.pic,
    this.created,
    this.itemCount,
    this.items,
  });

  String? uid;
  String? fullname;
  String? pic;
  String? created;
  int? itemCount;
  List<StoryUserItem>? items;

  factory UserItem.fromJson(Map<String, dynamic> json) => UserItem(
    uid: json["uid"],
    fullname: json["fullname"],
    pic: json["pic"],
    created: json["created"],
    itemCount: json["item_count"],
    items: List<StoryUserItem>.from(json["items"].map((x) => StoryUserItem.fromJson(x))),
  );
}

class StoryUserItem {
  StoryUserItem({
    this.uid,
    this.backgroundColor,
    this.textColor,
    this.user,
    this.caption,
    this.media,
    this.type,
    this.duration
  });

  String? uid; 
  String? backgroundColor;
  String? textColor;
  String? caption;
  String? media;
  String? type;
  StoryUserData? user;
  String? duration;

  factory StoryUserItem.fromJson(Map<String, dynamic> json) => StoryUserItem(
    uid: json["uid"],
    backgroundColor: json["backgroundColor"],
    textColor: json["textColor"],
    user: StoryUserData.fromJson(json["user"]),
    caption: json["caption"],
    media: json["media"],
    type: json["type"],
    duration: json["duration"]
  );
}


class StoryUserData {
  StoryUserData({
    this.uid,
    this.fullname,
    this.pic,
    this.created,
  });

  String? uid;
  String? fullname;
  String? pic;
  String? created;

  factory StoryUserData.fromJson(Map<String, dynamic> json) => StoryUserData(
    uid: json["uid"],
    fullname: json["fullname"],
    created: json["created"],
    pic: json["pic"]
  );
}