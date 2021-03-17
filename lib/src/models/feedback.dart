class FeedBack {
  String id;
  String uid;
  String orderId;
  int orderNumber;
  int rating;
  String notes;
  List<String> images;
  DateTime createdAt;
  DateTime lastUpdated;
  FeedBackReply lastReply;
}

class FeedBackReply {
  String id;
  String uid;
  String userName;
  String message;
  String image;
  DateTime createdAt;
  bool isRead;
}
