import 'post.dart';

enum TheVisibility {
  public,
  private,
}

abstract class Profile {
  late String _username;
  late String _email;
  late String _name;
  late String _surname;
  late String _bio;
  late String _activity;
  late String _status;
  late int _age;
  late TheVisibility _visibility;
  String _profileImageUrl;
  String _profileBannerUrl;
  String _additionalWebsite;
  String _additionalEmail;
  String _additionalNumber;
  bool _hasSpotlight;
  dynamic _additionalAddress;
  String _additionalAddressName;
  List<Map<String, String>> _postLikesNotifs;
  List<String> _newLinksNotifs;
  List<String> _linkRequestsNotifs;
  List<String> _linkedToNotifs;
  List<List<Map<String, String>>> _commentNotifs;
  int _commentsRemovedNotifs;
  int _postsRemovedNotifs;
  List<Post> _posts;
  List<String> _postIDs;
  List<String> _topics;
  List<Profile> _links;
  List<String> _linkIDs;
  List<Profile> _linkedTo;
  List<String> _linkedIDs;
  List<Profile> _blockedUsers;
  List<String> _blockedIDs;

  Profile({
    required String username,
    required String email,
    required String name,
    required String surname,
    required String bio,
    required String activity,
    required String status,
    required bool hasSpotlight,
    required int age,
    TheVisibility visibility = TheVisibility.public,
    required String profileImageUrl,
    required String profileBannerUrl,
    required String additionalWebsite,
    required String additionalEmail,
    required String additionalNumber,
    required dynamic additionalAddress,
    required String additionalAddressName,
    required String userID,
    required List<String> postIDs,
    required List<String> linkIDs,
    required List<String> linkedIDs,
    required List<String> blockedIDs,
    required List<Map<String, String>> postLikesNotifs,
    required List<String> newLinksNotifs,
    required List<String> linkRequestsNotifs,
    required List<String> linkedToNotifs,
    required List<List<Map<String, String>>> commentNotifs,
    required int commentsRemovedNotifs,
    required int postsRemovedNotifs,
  })  : this._visibility = visibility,
        this._username = username,
        this._email = email,
        this._name = name,
        this._surname = surname,
        this._bio = bio,
        this._activity = activity,
        this._status = status,
        this._hasSpotlight = hasSpotlight,
        this._age = age,
        this._profileImageUrl = profileImageUrl,
        this._profileBannerUrl = profileBannerUrl,
        this._additionalWebsite = additionalWebsite,
        this._additionalEmail = additionalEmail,
        this._additionalNumber = additionalNumber,
        this._additionalAddress = additionalAddress,
        this._additionalAddressName = additionalAddressName,
        this._posts = <Post>[],
        this._topics = <String>[],
        this._links = <Profile>[],
        this._linkedTo = <Profile>[],
        this._postIDs = postIDs,
        this._linkIDs = linkIDs,
        this._linkedIDs = linkedIDs,
        this._blockedIDs = blockedIDs,
        this._blockedUsers = <Profile>[],
        this._postLikesNotifs = [],
        this._newLinksNotifs = [],
        this._linkRequestsNotifs = [],
        this._linkedToNotifs = [],
        this._commentNotifs = [],
        this._commentsRemovedNotifs = 0,
        this._postsRemovedNotifs = 0;
  TheVisibility get getVisibility => _visibility;
  String get getUsername => _username;
  String get getEmail => _email;
  String get getName => _name;
  String get getSurname => _surname;
  String get getBio => _bio;
  String get getActivity => _activity;
  String get getStatus => _status;
  bool get getHasSpotlight => _hasSpotlight;
  int get getAge => _age;
  List<Profile> get getlinks => _links;
  List<String> get getLinkIDs => _linkIDs;
  int get getNumberOflinks => _links.length;
  List<Profile> get getLinkedTos => _linkedTo;
  List<String> get getLinkedIDs => _linkedIDs;
  int get getNumberOfLinkedTos => _linkedTo.length;
  List<Profile> get getBlockedUsers => _blockedUsers;
  List<String> get getBlockedIDs => _blockedIDs;
  List<Post> get getPosts => _posts;
  List<String> get getPostIDs => _postIDs;
  int get getNumberOfPosts => _posts.length;
  List<String> get getTopics => _topics;
  String get getProfileImage => _profileImageUrl;
  String get getProfileBanner => _profileBannerUrl;
  String get getAdditionalWebsite => _additionalWebsite;
  String get getAdditionalEmail => _additionalEmail;
  String get getAdditionalNumber => _additionalNumber;
  dynamic get getAdditionalAddress => _additionalAddress;
  String get getAdditionalAddressName => _additionalAddressName;
  List<Map<String, String>> get getpostLikesNotifs => _postLikesNotifs;
  List<String> get getnewLinksNotifs => _newLinksNotifs;
  List<String> get getlinkRequestNotifs => _linkRequestsNotifs;
  List<String> get getlinkedToNotifs => _linkedToNotifs;
  List<List<Map<String, String>>> get getcommentNotifs => _commentNotifs;
  int get getcommentRemovedNotifs => _commentsRemovedNotifs;
  int get getpostsRemovedNotifs => _postsRemovedNotifs;
  set setpostLikesNotifs(List<Map<String, String>> postLikesNotifs) {
    _postLikesNotifs = postLikesNotifs;
  }

  set setnewLinksNotifs(List<String> newLinksNotifs) {
    _newLinksNotifs = newLinksNotifs;
  }

  set setlinkRequestNotifs(List<String> linkRequestNotifs) {
    _linkRequestsNotifs = linkRequestNotifs;
  }

  set setlinkedToNotifs(List<String> linkedToNotifs) {
    _linkedToNotifs = linkedToNotifs;
  }

  set setcommentNotifs(List<List<Map<String, String>>> commentNotifs) {
    _commentNotifs = commentNotifs;
  }

  set setcommentRemovedNotifs(int commentsRemoved) {
    _commentsRemovedNotifs = commentsRemoved;
  }

  set setpostsRemovedNotifs(int postsRemoved) {
    _postsRemovedNotifs = postsRemoved;
  }

  set setUsername(String username) {
    _username = username;
  }

  set setEmail(String email) {
    _email = email;
  }

  set setName(String name) {
    _name = name;
  }

  set setSurname(String surname) {
    _surname = surname;
  }

  set setAge(int age) {
    _age = age;
  }

  set setBio(String bio) {
    _bio = bio;
  }

  set setActivity(String activity) {
    _activity = activity;
  }

  set setStatus(String status) {
    _status = status;
  }

  set setHasSpotlight(bool hasSpotlight) {
    _hasSpotlight = hasSpotlight;
  }

  set setPosts(List<Post> posts) {
    _posts = posts;
  }

  set setPostIDs(List<String> postIds) {
    _postIDs = postIds;
  }

  set setLinks(List<Profile> links) {
    _links = links;
  }

  set setlinkIDs(List<String> linkIds) {
    _linkIDs = linkIds;
  }

  set setLinkedTos(List<Profile> linkedTos) {
    _linkedTo = linkedTos;
  }

  set setLinkedIDs(List<String> linkedIds) {
    _linkedIDs = linkedIds;
  }

  set setBlockedIDs(List<String> blockedIds) {
    _blockedIDs = blockedIds;
  }

  set setBlockedUsers(List<Profile> blockedUsers) {
    _blockedUsers = blockedUsers;
  }

  set setTopics(List<String> topics) {
    _topics = topics;
  }

  set setProfileImage(String imgUrl) {
    _profileImageUrl = imgUrl;
  }

  set setProfileBanner(String bannerUrl) {
    _profileBannerUrl = bannerUrl;
  }

  set setAdditionalWebsite(String website) {
    _additionalWebsite = website;
  }

  set setAdditionalEmail(String email) {
    _additionalEmail = email;
  }

  set setAdditionalNumber(String number) {
    _additionalNumber = number;
  }

  set setAdditionalAddress(dynamic address) {
    _additionalAddress = address;
  }

  set setAdditionalAddressName(String name) {
    _additionalAddressName = name;
  }
}
