import 'package:flutter/material.dart';

import '../models/boardPostItem.dart';
import '../providers/fullPostHelper.dart';
import 'posterProfile.dart';

class Post {
  final String postID;
  final String clubName;
  final String locationName;
  final String description;
  final dynamic location;
  final int numOfLikes;
  final int numOfComments;
  final int numOfTopics;
  final bool sensitiveContent;
  final bool commentsDisabled;
  final bool isClubPost;
  final bool isLiked;
  final bool isFav;
  final bool isHidden;
  final bool isMod;
  final List<String> imgUrls;
  final List<String> topics;
  final DateTime postedDate;
  final UniqueKey key;
  final PosterProfile poster;
  final FullHelper instance;
  final PostType postType;
  final List<BoardPostItem> items;
  final Color backgroundColor;
  final Color gradientColor;
  Post(
      {required this.key,
      required this.instance,
      required this.postID,
      required this.poster,
      required this.clubName,
      required this.description,
      required this.imgUrls,
      required this.topics,
      required this.postedDate,
      required this.sensitiveContent,
      required this.commentsDisabled,
      required this.numOfTopics,
      required this.numOfLikes,
      required this.numOfComments,
      required this.location,
      required this.locationName,
      required this.isLiked,
      required this.isFav,
      required this.isHidden,
      required this.isClubPost,
      required this.isMod,
      required this.postType,
      required this.items,
      required this.backgroundColor,
      required this.gradientColor});
  void setter() {
    instance.setTitle(poster.getUsername);
    instance.setClubName(clubName);
    instance.setVisibility(poster.getVisibility);
    instance.setDescription(description);
    instance.setNumOfLikes(numOfLikes);
    instance.setNumOfComments(numOfComments);
    instance.setNumOfTopics(numOfTopics);
    instance.setTopics(topics);
    instance.setImgUrls(imgUrls);
    instance.setSensitiveContent(sensitiveContent);
    instance.setPostedDate(postedDate);
    instance.setPostID(postID);
    instance.setPosterID(poster.getUsername);
    instance.setLocation(location);
    instance.setLocationName(locationName);
    instance.setIsLiked(isLiked);
    instance.setIsFav(isFav);
    instance.setIsHidden(isHidden);
    instance.setIsClubPost(isClubPost);
    instance.setIsMod(isMod);
    instance.setCommentsDisabled(commentsDisabled);
    instance.setPostType(postType);
    instance.setBoardPostItems(items);
    instance.setBoardPostBackground(backgroundColor);
    instance.setBoardPostGradient(gradientColor);
  }
}
