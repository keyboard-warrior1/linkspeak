import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import 'profileImage.dart';
import 'adaptiveText.dart';
import 'popUpMenuButton.dart';

class PostWidgetTitle extends StatelessWidget {
  final List<String> postTopics;
  final List<String> postMedia;
  final DateTime postDate;
  final bool isInFav;
  final bool isInLikedPosts;
  final bool isInTab;
  final bool isInTopics;
  final String postId;
  final String title;
  final String userImageUrl;
  final dynamic handler;
  final void Function() preview;
  final dynamic hidePost;
  final dynamic deletePost;
  final dynamic unhidePost;
  final dynamic previewSetstate;
  const PostWidgetTitle({
    required this.isInLikedPosts,
    required this.isInFav,
    required this.isInTab,
    required this.postId,
    required this.title,
    required this.userImageUrl,
    required this.handler,
    required this.preview,
    required this.postTopics,
    required this.postMedia,
    required this.postDate,
    required this.isInTopics,
    required this.hidePost,
    required this.deletePost,
    required this.unhidePost,
    required this.previewSetstate,
  });

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceWidth = _sizeQuery.width;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (isInLikedPosts || isInFav || isInTab || isInTopics)
                ? handler
                : preview,
            child: ProfileImage(
              username: title,
              url: userImageUrl,
              factor: 0.06,
              inEdit: false,
              asset: null,
            ),
          ),
          OptimisedText(
            minWidth: _deviceWidth * 0.1,
            maxWidth: _deviceWidth * 0.75,
            minHeight: 10.0,
            maxHeight: 50.0,
            fit: BoxFit.scaleDown,
            child: TextButton(
              onPressed:
                  (isInLikedPosts || isInFav || isInTab) ? handler : preview,
              style: ButtonStyle(
                  alignment: Alignment.centerLeft,
                  splashFactory: NoSplash.splashFactory),
              child: Text(
                title,
                textAlign: TextAlign.start,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 21.0,
                ),
              ),
            ),
          ),
          const Spacer(),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: const EdgeInsets.all(0.0),
            child: const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                padding: const EdgeInsets.all(0.0),
                enabled: true,
                child: MyPopUpMenuButton(
                  id: postId,
                  postID: postId,
                  isInProfile: false,
                  postedByMe: title == context.read<MyProfile>().getUsername,
                  postTopics: postTopics,
                  postMedia: postMedia,
                  postDate: postDate,
                  isBlocked: false,
                  isLinkedToMe: false,
                  block: () {},
                  unblock: () {},
                  remove: () {},
                  hidePost: hidePost,
                  deletePost: deletePost,
                  unhidePost: unhidePost,
                  previewSetstate: previewSetstate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
