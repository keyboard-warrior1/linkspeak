import 'package:flutter/material.dart';

import 'generalTab.dart';

class GeneralTabs extends StatelessWidget {
  final TabController tabController;
  final bool isProfiles;
  final bool isClubs;
  final bool isPosts;
  final bool isPostComments;
  final bool isPostCommentReplies;
  final bool isFlares;
  final bool isFlareComments;
  final bool isFlareCommentReplies;
  final bool showReports;
  final bool showWatchList;
  final bool showBanned;
  final bool showProhibited;
  final bool showReviewals;
  const GeneralTabs(
      {required this.tabController,
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
      required this.showReviewals});
  String reportsTab() {
    if (isProfiles) return 'Profile reports';
    if (isClubs) return 'Club reports';
    if (isPosts) return 'Post reports';
    if (isPostComments) return 'Comment reports';
    if (isPostCommentReplies) return 'Reply reports';
    if (isFlares) return 'Flare reports';
    if (isFlareComments) return 'Comment reports';
    if (isFlareCommentReplies) return 'Reply reports';
    return '';
  }

  String watchList() {
    if (isProfiles) return 'User watchlist';
    if (isClubs) return 'Club watchlist';
    return '';
  }

  String giveReviewalsWhere() {
    if (isProfiles) return 'isProfileBanner';
    if (isClubs) return 'isClubBanner';
    if (isPosts) return 'isPost';
    if (isPostComments) return 'isComment';
    if (isPostCommentReplies) return 'isReply';
    if (isFlares) return 'isFlare';
    if (isFlareComments) return 'isFlareComment';
    if (isFlareCommentReplies) return 'isFlareReply';
    return '';
  }

  Widget buildGeneralTab(
          {required collectionAddress,
          required where,
          required whereIS,
          required orderBy,
          required inReports,
          required inWatchlist,
          required inProhibited,
          required inBanned,
          required inReview}) =>
      GeneralTab(
          collectionAddress: collectionAddress,
          where: where,
          whereIS: whereIS,
          orderBy: orderBy,
          isProfiles: isProfiles,
          isClubs: isClubs,
          isPosts: isPosts,
          isPostComments: isPostComments,
          isPostCommentReplies: isPostCommentReplies,
          isFlares: isFlares,
          isFlareComments: isFlareComments,
          isFlareCommentReplies: isFlareCommentReplies,
          inReports: inReports,
          inWatchlist: inWatchlist,
          inProhibited: inProhibited,
          inBanned: inBanned,
          inReview: inReview);
  @override
  Widget build(BuildContext context) => Expanded(
          child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
            if (showReports)
              buildGeneralTab(
                  collectionAddress: reportsTab(),
                  where: null,
                  whereIS: null,
                  orderBy: 'date',
                  inReports: true,
                  inWatchlist: false,
                  inProhibited: false,
                  inBanned: false,
                  inReview: false),
            if (showWatchList)
              buildGeneralTab(
                  collectionAddress: watchList(),
                  where: null,
                  whereIS: null,
                  orderBy: 'date added',
                  inReports: false,
                  inWatchlist: true,
                  inProhibited: false,
                  inBanned: false,
                  inReview: false),
            if (showProhibited)
              buildGeneralTab(
                  collectionAddress: 'Prohibited Clubs',
                  where: 'isBanned',
                  whereIS: true,
                  orderBy: 'ban date',
                  inReports: false,
                  inWatchlist: false,
                  inProhibited: true,
                  inBanned: false,
                  inReview: false),
            if (showBanned)
              buildGeneralTab(
                  collectionAddress: 'Banned',
                  where: 'isBanned',
                  whereIS: true,
                  orderBy: 'ban date',
                  inReports: false,
                  inWatchlist: false,
                  inProhibited: false,
                  inBanned: true,
                  inReview: false),
            if (showReviewals)
              buildGeneralTab(
                  collectionAddress: 'Review',
                  where: giveReviewalsWhere(),
                  whereIS: true,
                  orderBy: 'date',
                  inReports: false,
                  inWatchlist: false,
                  inProhibited: false,
                  inBanned: false,
                  inReview: true)
          ]));
}
