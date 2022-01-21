class ScreenArguments extends Object {
  final Object? argument;
  const ScreenArguments({this.argument});
}

class BrowserScreenArgs extends ScreenArguments {
  final Object? url;
  const BrowserScreenArgs(this.url);
}

class ProfilePickAddressScreenArgs extends ScreenArguments {
  final Object? isInPost;
  final Object? somethingChanged;
  final Object? changeAddress;
  final Object? changeAddressName;
  final Object? changeStateAddressName;
  final Object? changePoint;
  const ProfilePickAddressScreenArgs({
    required this.isInPost,
    required this.somethingChanged,
    required this.changeAddress,
    required this.changeAddressName,
    required this.changeStateAddressName,
    required this.changePoint,
  });
}

class MapScreenArgs extends ScreenArguments {
  final Object? address;
  final Object? addressName;
  const MapScreenArgs({required this.address, required this.addressName});
}

class PickNameArgs extends ScreenArguments {
  final Object? emailXid;
  final Object? isGmail;
  const PickNameArgs(this.emailXid, this.isGmail);
}

class ChatScreenArgs extends ScreenArguments {
  final Object? comeFromProfile;
  final Object? chatID;
  const ChatScreenArgs({required this.chatID, required this.comeFromProfile});
}

class TopicScreenArgs extends ScreenArguments {
  final Object? topicName;
  const TopicScreenArgs(this.topicName);
}

class PostScreenArguments extends ScreenArguments {
  final Object? viewMode;
  final Object? instance;
  final Object? previewSetstate;
  final Object? isNotif;
  final Object? postID;
  const PostScreenArguments({
    required this.viewMode,
    required this.instance,
    required this.previewSetstate,
    required this.isNotif,
    required this.postID,
  });
}

class CommentRepliesScreenArguments extends ScreenArguments {
  final Object? instance;
  final Object? postID;
  final Object? commentID;
  final Object? isNotif;
  final Object? commenterName;
  const CommentRepliesScreenArguments({
    required this.instance,
    required this.postID,
    required this.commentID,
    required this.isNotif,
    required this.commenterName,
  });
}

class CommentLikesScreenArgs extends ScreenArguments {
  final Object? instance;
  final Object? postID;
  final Object? commentID;
  const CommentLikesScreenArgs({
    required this.instance,
    required this.postID,
    required this.commentID,
  });
}

class OtherProfileScreenArguments extends ScreenArguments {
  final Object? otherProfileId;

  const OtherProfileScreenArguments({required this.otherProfileId});
}

class LinkScreenArguments extends ScreenArguments {
  final Object? userID;
  final Object? publicProfile;
  final Object? imLinkedToThem;
  final Object? instance;
  const LinkScreenArguments({
    required this.userID,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.instance,
  });
}

class LinkedToScreenArguments extends ScreenArguments {
  final Object? userID;
  final Object? publicProfile;
  final Object? imLinkedToThem;
  final Object? instance;
  const LinkedToScreenArguments({
    required this.userID,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.instance,
  });
}
