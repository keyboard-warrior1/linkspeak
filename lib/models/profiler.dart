import 'package:flutter/material.dart';

import '../providers/otherProfileProvider.dart';
import 'profile.dart';

class Profiler {
  final String username;
  final String additionalWebsite;
  final String additionalEmail;
  final String additionalNumber;
  final dynamic additionalAddress;
  final String additionalAddressName;
  final String imgUrl;
  final String bio;
  final String bannerUrl;
  final String status;
  final String activityStatus;
  final int numOfLinks;
  final int numOfLinkedTo;
  final int numOfPosts;
  final int joinedClubs;
  final bool bannerNSFW;
  final bool hasSpotlight;
  final bool hasUnseenCollection;
  final bool linkedToMe;
  final bool imLinkedtoThem;
  final bool linkRequestSent;
  final bool isBlocked;
  final bool imBlocked;
  final List<String> posts;
  final List<String> topics;
  final Color primaryColor;
  final Color accentColor;
  final Color likeColor;
  final OtherProfile otherProfileProvider;
  final TheVisibility visibility;
  const Profiler(
      {required this.otherProfileProvider,
      required this.visibility,
      required this.status,
      required this.username,
      required this.additionalWebsite,
      required this.additionalEmail,
      required this.additionalNumber,
      required this.additionalAddress,
      required this.additionalAddressName,
      required this.imgUrl,
      required this.bannerUrl,
      required this.bannerNSFW,
      required this.hasSpotlight,
      required this.hasUnseenCollection,
      required this.bio,
      required this.numOfLinks,
      required this.numOfLinkedTo,
      required this.numOfPosts,
      required this.joinedClubs,
      required this.topics,
      required this.posts,
      required this.linkedToMe,
      required this.imLinkedtoThem,
      required this.linkRequestSent,
      required this.isBlocked,
      required this.imBlocked,
      required this.activityStatus,
      required this.primaryColor,
      required this.accentColor,
      required this.likeColor});
}
