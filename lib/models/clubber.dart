import '../providers/clubProvider.dart';

class Clubber {
  final String clubName;
  final String clubAvatarURL;
  final String clubDescription;
  final String clubBannerUrl;
  final ClubVisibility clubVisibility;
  final int numOfMembers;
  final int numOfPosts;
  final int numOfJoinRequests;
  final int numOfNewMembers;
  final int maxDailyPostsByMembers;
  final int numOfBannedMembers;
  final bool isDisabled;
  final bool isProhibited;
  final bool memberCanPost;
  final bool bannerNSFW;
  final bool isJoined;
  final bool isRequested;
  final bool isMod;
  final bool isBanned;
  final bool isFounder;
  final bool allowQuickJoin;
  final List<String> clubTopics;
  final ClubProvider instance;
  const Clubber(
      {required this.clubName,
      required this.clubAvatarURL,
      required this.clubDescription,
      required this.clubBannerUrl,
      required this.clubVisibility,
      required this.numOfMembers,
      required this.numOfPosts,
      required this.numOfJoinRequests,
      required this.numOfNewMembers,
      required this.maxDailyPostsByMembers,
      required this.numOfBannedMembers,
      required this.isDisabled,
      required this.isProhibited,
      required this.memberCanPost,
      required this.bannerNSFW,
      required this.isJoined,
      required this.isRequested,
      required this.isMod,
      required this.isBanned,
      required this.isFounder,
      required this.allowQuickJoin,
      required this.clubTopics,
      required this.instance});
}
