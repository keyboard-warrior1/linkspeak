class ScreenArguments extends Object {
  final Object? argument;
  const ScreenArguments({this.argument});
}

class NoteScreenArgs extends ScreenArguments {
  final Object? handler;
  final Object? preexistingText;
  final Object? editHandler;
  final Object? isBranch;
  const NoteScreenArgs(
      {required this.handler,
      required this.preexistingText,
      required this.editHandler,
      required this.isBranch});
}

class CustomizeFlareScreenArgs extends ScreenArguments {
  final Object? backgroundColor;
  final Object? gradientColor;
  final Object? saveHandler;
  final Object? asset;
  const CustomizeFlareScreenArgs(
      {required this.backgroundColor,
      required this.gradientColor,
      required this.saveHandler,
      required this.asset});
}

class UserDailyCollectionDocScreenArgs extends ScreenArguments {
  final Object? dayID;
  final Object? userID;
  final Object? collectionID;
  final Object? docs;
  const UserDailyCollectionDocScreenArgs(
      this.dayID, this.userID, this.collectionID, this.docs);
}

class UserDailyCollectionScreenArgs extends ScreenArguments {
  final Object? dayID;
  final Object? userID;
  const UserDailyCollectionScreenArgs(this.dayID, this.userID);
}

class UserDailyDetailsArgs extends ScreenArguments {
  final Object? details;
  final Object? dayID;
  final Object? userID;
  const UserDailyDetailsArgs(this.userID, this.details, this.dayID);
}

class ControlDailyLoginSearchArgs extends ScreenArguments {
  final Object? dayID;
  final Object? allLogins;
  const ControlDailyLoginSearchArgs(this.dayID, this.allLogins);
}

class ControlDailyLoginsArgs extends ScreenArguments {
  final Object? dayID;
  final Object? logins;
  final Object? allLogins;
  const ControlDailyLoginsArgs(this.dayID, this.logins, this.allLogins);
}

class ControlDailyDetailsScreenArgs extends ScreenArguments {
  final Object? details;
  final Object? dayID;
  const ControlDailyDetailsScreenArgs(this.details, this.dayID);
}

class UserDailyScreenArgs extends ScreenArguments {
  final Object? dayID;
  final Object? userID;
  const UserDailyScreenArgs(this.dayID, this.userID);
}

class ControlDayScreenArgs extends ScreenArguments {
  final Object? dayID;
  const ControlDayScreenArgs(this.dayID);
}

class AdminUserClubScreenArgs extends ScreenArguments {
  final Object? isUser;
  const AdminUserClubScreenArgs(this.isUser);
}

class ArchiveItemScreenArgs extends ScreenArguments {
  final Object? deletedPosts;
  final Object? deletedComments;
  final Object? deletedReplies;
  final Object? deletedFlares;
  final Object? deletedUsers;
  final Object? deletedFlareProfiles;
  final Object? unbannedUsers;
  final Object? unprohibitedClubs;
  final Object? disabledClubs;
  final Object? showFinder;
  final Object? findMode;
  const ArchiveItemScreenArgs(
      {required this.deletedPosts,
      required this.deletedComments,
      required this.deletedReplies,
      required this.deletedUsers,
      required this.deletedFlareProfiles,
      required this.deletedFlares,
      required this.unbannedUsers,
      required this.unprohibitedClubs,
      required this.disabledClubs,
      required this.showFinder,
      required this.findMode});
}

class ArchiveFindScreenArgs extends ScreenArguments {
  final Object? searchMode;
  const ArchiveFindScreenArgs(this.searchMode);
}

class ProfanityItemScreenArgs extends ScreenArguments {
  final Object? isProfileBio;
  final Object? isClubAbout;
  final Object? isFlareProfileBio;
  final Object? isPostDescription;
  final Object? isPostComments;
  final Object? isPostCommentReplies;
  final Object? isFlareComments;
  final Object? isFlareCommentReplies;
  const ProfanityItemScreenArgs(
      {required this.isProfileBio,
      required this.isClubAbout,
      required this.isFlareProfileBio,
      required this.isPostDescription,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlareComments,
      required this.isFlareCommentReplies});
}

class GeneralItemScreenArgs extends ScreenArguments {
  final Object? numOfTabs;
  final Object? isProfiles;
  final Object? isClubs;
  final Object? isPosts;
  final Object? isPostComments;
  final Object? isPostCommentReplies;
  final Object? isFlares;
  final Object? isFlareComments;
  final Object? isFlareCommentReplies;
  final Object? showReports;
  final Object? showWatchList;
  final Object? showBanned;
  final Object? showProhibited;
  final Object? showReviewals;
  final Object? showFab;
  final Object? findMode;
  const GeneralItemScreenArgs(
      {required this.numOfTabs,
      required this.isProfiles,
      required this.isClubs,
      required this.isPosts,
      required this.isPostComments,
      required this.isPostCommentReplies,
      required this.isFlares,
      required this.isFlareComments,
      required this.isFlareCommentReplies,
      required this.showReports,
      required this.showWatchList,
      required this.showBanned,
      required this.showProhibited,
      required this.showReviewals,
      required this.showFab,
      required this.findMode});
}

class GeneralFindScreenArgs extends ScreenArguments {
  final Object? searchMode;
  const GeneralFindScreenArgs(this.searchMode);
}

class SingleFlareScreenArgs extends ScreenArguments {
  final Object? flarePoster;
  final Object? collectionID;
  final Object? flareID;
  final Object? isComment;
  final Object? isLike;
  final Object? section;
  final Object? singleCommentID;
  const SingleFlareScreenArgs(
      {required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.isComment,
      required this.isLike,
      required this.section,
      required this.singleCommentID});
}

class FlareCommentLikesArgs extends ScreenArguments {
  final Object? instance;
  final Object? flarePoster;
  final Object? collectionID;
  final Object? flareID;
  final Object? commentID;
  const FlareCommentLikesArgs(
      {required this.instance,
      required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.commentID});
}

class FlareReplyScreenArgs extends ScreenArguments {
  final Object? instance;
  final Object? flarePoster;
  final Object? collectionID;
  final Object? flareID;
  final Object? commentID;
  final Object? isNotif;
  final Object? commenterName;
  final Object? section;
  final Object? singleReplyID;
  const FlareReplyScreenArgs(
      {required this.instance,
      required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.commentID,
      required this.commenterName,
      required this.isNotif,
      required this.section,
      required this.singleReplyID});
}

class CollectionFlareScreenArgs extends ScreenArguments {
  final Object? collections;
  final Object? index;
  final Object? comeFromProfile;
  const CollectionFlareScreenArgs(
      {required this.collections,
      required this.index,
      required this.comeFromProfile});
}

class FlareAlertScreenArgs extends ScreenArguments {
  final Object? username;
  final Object? numOfLikes;
  final Object? numOfComments;
  final Object? zeroNotifs;
  const FlareAlertScreenArgs(
      {required this.username,
      required this.numOfLikes,
      required this.numOfComments,
      required this.zeroNotifs});
}

class FlareProfileScreenArgs extends ScreenArguments {
  final Object? userID;
  const FlareProfileScreenArgs(this.userID);
}

class MediaScreenArgs extends ScreenArguments {
  final Object? mediaUrls;
  final Object? currentIndex;
  final Object? isInComment;
  const MediaScreenArgs(
      {required this.mediaUrls,
      required this.currentIndex,
      required this.isInComment});
}

class PlaceScreenArgs extends ScreenArguments {
  final Object? locationName;
  final Object? location;
  final Object? placeID;
  const PlaceScreenArgs(
      {required this.locationName,
      required this.location,
      required this.placeID});
}

class ManageClubScreenArgs extends ScreenArguments {
  final Object? clubName;
  final Object? clubAbout;
  final Object? clubTopics;
  final Object? clubAvatarUrl;
  final Object? clubVisibility;
  final Object? instance;
  final Object? membersCanPost;
  final Object? allowQuickJoin;
  final Object? isDisabled;
  final Object? maxDailyPosts;
  const ManageClubScreenArgs(
      {required this.clubName,
      required this.clubAbout,
      required this.clubTopics,
      required this.clubAvatarUrl,
      required this.instance,
      required this.clubVisibility,
      required this.membersCanPost,
      required this.allowQuickJoin,
      required this.isDisabled,
      required this.maxDailyPosts});
}

class ClubMemberScreenArgs extends ScreenArguments {
  final Object? clubName;
  const ClubMemberScreenArgs(this.clubName);
}

class BanMemberScreenArgs extends ScreenArguments {
  final Object? clubName;
  final Object? addBanned;
  final Object? removeBanned;
  const BanMemberScreenArgs(
      {required this.clubName,
      required this.addBanned,
      required this.removeBanned});
}

class BannedMemberScreenArgs extends ScreenArguments {
  final Object? clubName;
  const BannedMemberScreenArgs(this.clubName);
}

class AssignAdminScreenArgs extends ScreenArguments {
  final Object? clubName;
  final Object? addAdmin;
  final Object? removeAdmin;
  const AssignAdminScreenArgs(
      {required this.clubName,
      required this.addAdmin,
      required this.removeAdmin});
}

class AdminScreenArgs extends ScreenArguments {
  final Object? isFounder;
  final Object? clubName;
  const AdminScreenArgs({required this.isFounder, required this.clubName});
}

class PublishClubArgs extends ScreenArguments {
  final Object? clubInstance;
  const PublishClubArgs(this.clubInstance);
}

class ClubAlertArgs extends ScreenArguments {
  final Object? clubName;
  final Object? numOfNewMembers;
  final Object? numOfRequests;
  final Object? zeroNotifs;
  final Object? decreaseNotifs;
  final Object? addMembers;
  const ClubAlertArgs(
      {required this.clubName,
      required this.numOfNewMembers,
      required this.numOfRequests,
      required this.zeroNotifs,
      required this.decreaseNotifs,
      required this.addMembers});
}

class ClubRequestsArgs extends ScreenArguments {
  final Object? clubName;
  final Object? decreaseNotifs;
  final Object? addMembers;
  const ClubRequestsArgs(
      {required this.clubName,
      required this.decreaseNotifs,
      required this.addMembers});
}

class OtherJoinedClubsArgs extends ScreenArguments {
  final Object? username;
  const OtherJoinedClubsArgs(this.username);
}

class ClubScreenArgs extends ScreenArguments {
  final Object? clubName;
  const ClubScreenArgs(this.clubName);
}

class CreateClubArgs extends ScreenArguments {
  final Object? addClub;
  const CreateClubArgs(this.addClub);
}

class BrowserScreenArgs extends ScreenArguments {
  final Object? url;
  const BrowserScreenArgs(this.url);
}

class ProfilePickAddressScreenArgs extends ScreenArguments {
  final Object? isInPost;
  final Object? isInChat;
  final Object? somethingChanged;
  final Object? changeAddress;
  final Object? changeAddressName;
  final Object? changeStateAddressName;
  final Object? changePoint;
  final Object? chatHandler;
  const ProfilePickAddressScreenArgs(
      {required this.isInPost,
      required this.isInChat,
      required this.somethingChanged,
      required this.changeAddress,
      required this.changeAddressName,
      required this.changeStateAddressName,
      required this.changePoint,
      required this.chatHandler});
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
  final Object? clubName;
  final Object? section;
  final Object? singleCommentID;
  const PostScreenArguments(
      {required this.viewMode,
      required this.instance,
      required this.previewSetstate,
      required this.isNotif,
      required this.postID,
      required this.clubName,
      required this.section,
      required this.singleCommentID});
}

class CommentRepliesScreenArguments extends ScreenArguments {
  final Object? instance;
  final Object? postID;
  final Object? commentID;
  final Object? isNotif;
  final Object? commenterName;
  final Object? isClubPost;
  final Object? clubName;
  final Object? posterName;
  final Object? section;
  final Object? singleReplyID;
  const CommentRepliesScreenArguments(
      {required this.instance,
      required this.postID,
      required this.commentID,
      required this.isNotif,
      required this.commenterName,
      required this.isClubPost,
      required this.clubName,
      required this.posterName,
      required this.section,
      required this.singleReplyID});
}

class CommentLikesScreenArgs extends ScreenArguments {
  final Object? instance;
  final Object? postID;
  final Object? commentID;
  final Object? isClubPost;
  final Object? clubName;
  const CommentLikesScreenArgs(
      {required this.instance,
      required this.postID,
      required this.commentID,
      required this.isClubPost,
      required this.clubName});
}

class ReplyLikesScreenArgs extends ScreenArguments {
  final Object? postID;
  final Object? isInFlare;
  final Object? flarePoster;
  final Object? collectionID;
  final Object? flareID;
  final Object? replyID;
  final Object? commentID;
  final Object? isClubPost;
  final Object? clubName;
  const ReplyLikesScreenArgs(
      {required this.postID,
      required this.isInFlare,
      required this.flarePoster,
      required this.collectionID,
      required this.flareID,
      required this.replyID,
      required this.commentID,
      required this.isClubPost,
      required this.clubName});
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
  const LinkScreenArguments(
      {required this.userID,
      required this.publicProfile,
      required this.imLinkedToThem,
      required this.instance});
}

class LinkedToScreenArguments extends ScreenArguments {
  final Object? userID;
  final Object? publicProfile;
  final Object? imLinkedToThem;
  final Object? instance;
  const LinkedToScreenArguments(
      {required this.userID,
      required this.publicProfile,
      required this.imLinkedToThem,
      required this.instance});
}
