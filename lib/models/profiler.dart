import 'package:flutter/material.dart';
import 'profile.dart';
import '../providers/otherProfileProvider.dart';

class Profiler {
  final TheVisibility visibility;
  final String username;
  final String additionalWebsite;
  final String additionalEmail;
  final String additionalNumber;
  final dynamic additionalAddress;
  final String additionalAddressName;
  final String imgUrl;
  final String bannerUrl;
  final bool bannerNSFW;
  final bool hasSpotlight;
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
  final Color primaryColor;
  final Color accentColor;
  const Profiler({
    required this.otherProfileProvider,
    required this.visibility,
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
    required this.primaryColor,
    required this.accentColor,
  });
}
