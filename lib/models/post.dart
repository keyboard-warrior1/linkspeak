import 'package:flutter/material.dart';
import 'posterProfile.dart';
import '../providers/fullPostHelper.dart';

class Post {
  final UniqueKey key;
  final FullHelper instance;
  final String postID;
  final PosterProfile poster;
  final String description;
  final List<String> imgUrls;
  final List<String> topics;
  final int numOfLikes;
  final int numOfComments;
  final int numOfTopics;
  final DateTime postedDate;
  final bool sensitiveContent;
  Post({
    required this.key,
    required this.instance,
    required this.postID,
    required this.poster,
    required this.description,
    required this.imgUrls,
    required this.topics,
    required this.postedDate,
    required this.sensitiveContent,
    required this.numOfTopics,
    required this.numOfLikes,
    required this.numOfComments,
  });
  void setter() {
    instance.setUserImgUrl(poster.getProfileImage);
    instance.setTitle(poster.getUsername);
    instance.setVisibility(poster.getVisibility);
    instance.setNumOfLinks(poster.getNumberOflinks);
    instance.setNumOfLinkedTos(poster.getNumberOfLinkedTos);
    instance.setBio(poster.getBio);
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
    // instance.setInstance(instance);
  }
}
