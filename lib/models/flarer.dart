import '../models/profile.dart';
import '../providers/flareProfileProvider.dart';

class Flarer {
  final String username;
  final String bannerURL;
  final String bio;
  final String currentlyShowcasing;
  final int numOfFlares;
  final int numOfViews;
  final int numOfLikes;
  final int numOfLikeNotifs;
  final int numOfCommentNotifs;
  final bool bannerNSFW;
  final bool imBlocked;
  final bool isBanned;
  final bool imLinked;
  final bool isMyProfile;
  final FlareProfile instance;
  final TheVisibility visibility;
  const Flarer(
      {required this.username,
      required this.bannerURL,
      required this.bio,
      required this.currentlyShowcasing,
      required this.numOfFlares,
      required this.numOfViews,
      required this.numOfLikes,
      required this.numOfLikeNotifs,
      required this.numOfCommentNotifs,
      required this.bannerNSFW,
      required this.imBlocked,
      required this.isBanned,
      required this.imLinked,
      required this.isMyProfile,
      required this.instance,
      required this.visibility});
}
