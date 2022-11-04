import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../clubs/clubAvatar.dart';
import '../../general.dart';
import '../../models/screenArguments.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/chatProfileImage.dart';
import '../common/popUpMenuButton.dart';

class PostWidgetTitle extends StatelessWidget {
  final List<String> postTopics;
  final List<String> postMedia;
  final DateTime postDate;
  final bool isInFav;
  final bool isInLikedPosts;
  final bool isInTab;
  final bool inOtherProfile;
  final String postId;
  final String title;
  final dynamic hidePost;
  final dynamic deletePost;
  final dynamic unhidePost;
  final dynamic helperFav;
  final dynamic previewSetstate;
  const PostWidgetTitle({
    required this.isInLikedPosts,
    required this.isInFav,
    required this.isInTab,
    required this.postId,
    required this.title,
    required this.postTopics,
    required this.postMedia,
    required this.postDate,
    required this.inOtherProfile,
    required this.hidePost,
    required this.deletePost,
    required this.unhidePost,
    required this.helperFav,
    required this.previewSetstate,
  });
  @override
  Widget build(BuildContext context) {
    void visitProfile(String myUsername) {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: title);
      Navigator.pushNamed(
        context,
        (title == myUsername)
            ? RouteGenerator.myProfileScreen
            : RouteGenerator.posterProfileScreen,
        arguments: (title == myUsername) ? null : args,
      );
    }

    final double _deviceWidth = General.widthQuery(context);
    final bool isFav = Provider.of<FullHelper>(context).isFav;
    final bool isClubPost =
        Provider.of<FullHelper>(context, listen: false).isClubPost;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final String clubName =
        Provider.of<FullHelper>(context, listen: false).clubName;
    final bool isMod = Provider.of<FullHelper>(context, listen: false).isMod;
    return (!isClubPost)
        ? Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                      onTap: () => visitProfile(myUsername),
                      child: ChatProfileImage(
                          username: title,
                          factor: 0.045,
                          inEdit: false,
                          asset: null,
                          inOtherProfile: inOtherProfile)),
                  OptimisedText(
                      minWidth: _deviceWidth * 0.1,
                      maxWidth: _deviceWidth * 0.75,
                      minHeight: 10.0,
                      maxHeight: 50.0,
                      fit: BoxFit.scaleDown,
                      child: TextButton(
                          onPressed: () => visitProfile(myUsername),
                          style: const ButtonStyle(
                              alignment: Alignment.centerLeft,
                              splashFactory: NoSplash.splashFactory),
                          child: Text(title,
                              textAlign: TextAlign.start,
                              softWrap: false,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.0)))),
                  const Spacer(),
                  PopupMenuButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(Icons.more_vert, color: Colors.grey.shade400),
                      itemBuilder: (_) => [
                            PopupMenuItem(
                                padding: const EdgeInsets.all(0.0),
                                enabled: true,
                                child: MyPopUpMenuButton(
                                    id: postId,
                                    postID: postId,
                                    isFav: isFav,
                                    helperFav: helperFav,
                                    prohibitClub: () {},
                                    isInProfile: false,
                                    isInClubScreen: false,
                                    isBanned: false,
                                    isProhibited: false,
                                    isMod: false,
                                    postedByMe: title ==
                                        context.read<MyProfile>().getUsername,
                                    postTopics: postTopics,
                                    postMedia: postMedia,
                                    postDate: postDate,
                                    isBlocked: false,
                                    isLinkedToMe: false,
                                    isClubPost: false,
                                    clubName: '',
                                    block: () {},
                                    unblock: () {},
                                    remove: () {},
                                    banUser: () {},
                                    unbanUser: () {},
                                    hidePost: hidePost,
                                    deletePost: deletePost,
                                    unhidePost: unhidePost,
                                    previewSetstate: previewSetstate,
                                    flareProfileID: '',
                                    isInFlareProfile: false))
                          ])
                ]))
        : Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                      onTap: () => visitProfile(myUsername),
                      child: ChatProfileImage(
                          username: title,
                          factor: 0.045,
                          inEdit: false,
                          asset: null,
                          inOtherProfile: inOtherProfile)),
                  OptimisedText(
                      minWidth: _deviceWidth * 0.1,
                      maxWidth: _deviceWidth * 0.75,
                      minHeight: 10.0,
                      maxHeight: 50.0,
                      fit: BoxFit.scaleDown,
                      child: TextButton(
                          onPressed: () => visitProfile(myUsername),
                          style: const ButtonStyle(
                              alignment: Alignment.centerLeft,
                              splashFactory: NoSplash.splashFactory),
                          child: Text(title,
                              textAlign: TextAlign.start,
                              softWrap: false,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.0)))),
                  const Spacer(),
                  PopupMenuButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Icon(Icons.more_vert, color: Colors.grey.shade400),
                      itemBuilder: (_) => [
                            PopupMenuItem(
                                padding: const EdgeInsets.all(0.0),
                                enabled: true,
                                child: MyPopUpMenuButton(
                                    isBanned: false,
                                    id: postId,
                                    postID: postId,
                                    clubName: clubName,
                                    isMod: isMod,
                                    isFav: isFav,
                                    helperFav: helperFav,
                                    prohibitClub: () {},
                                    isInProfile: false,
                                    isInClubScreen: false,
                                    isClubPost: true,
                                    isProhibited: false,
                                    postedByMe: title ==
                                        context.read<MyProfile>().getUsername,
                                    postTopics: postTopics,
                                    postMedia: postMedia,
                                    postDate: postDate,
                                    isBlocked: false,
                                    isLinkedToMe: false,
                                    block: () {},
                                    unblock: () {},
                                    remove: () {},
                                    banUser: () {},
                                    unbanUser: () {},
                                    hidePost: hidePost,
                                    deletePost: deletePost,
                                    unhidePost: unhidePost,
                                    previewSetstate: previewSetstate,
                                    isInFlareProfile: false,
                                    flareProfileID: ''))
                          ])
                ]));
    // : ClubTitle(
    //     isInLikedPosts: isInLikedPosts,
    //     isInFav: isInFav,
    //     isInTab: isInTab,
    //     postId: postId,
    //     title: title,
    //     postTopics: postTopics,
    //     postMedia: postMedia,
    //     postDate: postDate,
    //     inOtherProfile: inOtherProfile,
    //     hidePost: hidePost,
    //     deletePost: deletePost,
    //     unhidePost: unhidePost,
    //     helperFav: helperFav,
    //     previewSetstate: previewSetstate);
  }
}

class ClubTitle extends StatelessWidget {
  final List<String> postTopics;
  final List<String> postMedia;
  final DateTime postDate;
  final bool isInFav;
  final bool isInLikedPosts;
  final bool isInTab;
  final bool inOtherProfile;
  final String postId;
  final String title;
  final dynamic hidePost;
  final dynamic deletePost;
  final dynamic unhidePost;
  final dynamic helperFav;
  final dynamic previewSetstate;
  const ClubTitle({
    required this.isInLikedPosts,
    required this.isInFav,
    required this.isInTab,
    required this.postId,
    required this.title,
    required this.postTopics,
    required this.postMedia,
    required this.postDate,
    required this.inOtherProfile,
    required this.hidePost,
    required this.deletePost,
    required this.unhidePost,
    required this.helperFav,
    required this.previewSetstate,
  });

  @override
  Widget build(BuildContext context) {
    final double _deviceWidth = General.widthQuery(context);
    final bool isFav = Provider.of<FullHelper>(context).isFav;
    final String clubName =
        Provider.of<FullHelper>(context, listen: false).clubName;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool isMod = Provider.of<FullHelper>(context, listen: false).isMod;
    void visitProfile(String myUsername) {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: title);
      Navigator.pushNamed(
        context,
        (title == myUsername)
            ? RouteGenerator.myProfileScreen
            : RouteGenerator.posterProfileScreen,
        arguments: (title == myUsername) ? null : args,
      );
    }

    void visitClub() {
      final ClubScreenArgs args = ClubScreenArgs(clubName);
      Navigator.pushNamed(context, RouteGenerator.clubScreen, arguments: args);
    }

    return OptimisedText(
            minWidth: _deviceWidth * 0.1,
            maxWidth: _deviceWidth * 0.98,
            minHeight: 10.0,
            maxHeight: 50.0,
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          OptimisedText(
                            minWidth: _deviceWidth * 0.01,
                            maxWidth: _deviceWidth * 0.09,
                            minHeight: 10.0,
                            maxHeight: 45.0,
                            fit: BoxFit.scaleDown,
                            child:
                                Stack(fit: StackFit.expand, children: <Widget>[
                              GestureDetector(
                                  onTap: visitClub,
                                  child: ClubAvatar(
                                      clubName: clubName,
                                      radius: 20,
                                      inEdit: false,
                                      asset: null,
                                      fontSize: 14)),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                      onTap: () => visitProfile(myUsername),
                                      child: ChatProfileImage(
                                          username: title,
                                          factor: 0.02,
                                          inEdit: false,
                                          asset: null,
                                          inOtherProfile: inOtherProfile)))
                            ]),
                          ),
                          OptimisedText(
                              minWidth: _deviceWidth * 0.1,
                              maxWidth: _deviceWidth * 0.75,
                              minHeight: 10.0,
                              maxHeight: 25.0,
                              fit: BoxFit.scaleDown,
                              child: TextButton(
                                  onPressed: visitClub,
                                  style: const ButtonStyle(
                                      alignment: Alignment.centerLeft,
                                      splashFactory: NoSplash.splashFactory),
                                  child: Text(clubName,
                                      textAlign: TextAlign.start,
                                      softWrap: false,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18.0)))),
                          PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              padding: const EdgeInsets.all(0.0),
                              child: Icon(Icons.more_vert,
                                  color: Colors.grey.shade400),
                              itemBuilder: (_) => [
                                    PopupMenuItem(
                                        padding: const EdgeInsets.all(0.0),
                                        enabled: true,
                                        child: MyPopUpMenuButton(
                                            isBanned: false,
                                            id: postId,
                                            postID: postId,
                                            clubName: clubName,
                                            isMod: isMod,
                                            isFav: isFav,
                                            helperFav: helperFav,
                                            prohibitClub: () {},
                                            isInProfile: false,
                                            isInClubScreen: false,
                                            isClubPost: true,
                                            isProhibited: false,
                                            postedByMe: title ==
                                                context
                                                    .read<MyProfile>()
                                                    .getUsername,
                                            postTopics: postTopics,
                                            postMedia: postMedia,
                                            postDate: postDate,
                                            isBlocked: false,
                                            isLinkedToMe: false,
                                            block: () {},
                                            unblock: () {},
                                            remove: () {},
                                            banUser: () {},
                                            unbanUser: () {},
                                            hidePost: hidePost,
                                            deletePost: deletePost,
                                            unhidePost: unhidePost,
                                            previewSetstate: previewSetstate,
                                            isInFlareProfile: false,
                                            flareProfileID: ''))
                                  ])
                        ]),
                    OptimisedText(
                        minWidth: _deviceWidth * 0.1,
                        maxWidth: _deviceWidth * 0.75,
                        minHeight: 10.0,
                        maxHeight: 25.0,
                        fit: BoxFit.scaleDown,
                        child: TextButton(
                            onPressed: () => visitProfile(myUsername),
                            style: const ButtonStyle(
                                alignment: Alignment.centerLeft,
                                splashFactory: NoSplash.splashFactory),
                            child: Text(title,
                                textAlign: TextAlign.start,
                                softWrap: false,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.0)))),
                  ]),
            ))
        // )
        ;
  }
}
