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
    this.caption,
    this.media,
    this.type,
  });

  String? uid;
  String? caption;
  String? media;
  String? type;

  factory StoryUserItem.fromJson(Map<String, dynamic> json) => StoryUserItem(
    uid: json["uid"],
    caption: json["caption"],
    media: json["media"],
    type: json["type"],
  );
}
