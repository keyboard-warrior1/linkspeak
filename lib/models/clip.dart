class Clip {
  final String posterID;
  final String clipID;
  final DateTime postedDate;
  final List<String> topics;
  final int numOfLikes;
  final int numOfComments;
  final String mediaURL;
  final bool likedByMe;
  final bool viewedByMe;
  final bool isMyClip;
  final dynamic duration;
  const Clip({
    required this.posterID,
    required this.clipID,
    required this.postedDate,
    required this.topics,
    required this.numOfLikes,
    required this.numOfComments,
    required this.mediaURL,
    required this.likedByMe,
    required this.viewedByMe,
    required this.isMyClip,
    required this.duration,
  });
}
