import 'profile.dart';
import '../providers/otherProfileProvider.dart';

class Profiler {
  final TheVisibility visibility;
  final String username;
  final String imgUrl;
  final String bio;
  final int numOfLinks;
  final int numOfLinkedTo;
  final int numOfPosts;
  final List<String> topics;
  final List<String> posts;
  final OtherProfile otherProfileProvider;
  final bool linkedToMe;
  final bool imLinkedtoThem;
  final bool linkRequestSent;
  final bool isBlocked;
  final bool imBlocked;
  final String activityStatus;
  const Profiler({
    required this.otherProfileProvider,
    required this.visibility,
    required this.username,
    required this.imgUrl,
    required this.bio,
    required this.numOfLinks,
    required this.numOfLinkedTo,
    required this.numOfPosts,
    required this.topics,
    required this.posts,
    required this.linkedToMe,
    required this.imLinkedtoThem,
    required this.linkRequestSent,
    required this.isBlocked,
    required this.imBlocked,
    required this.activityStatus,
  });
}
