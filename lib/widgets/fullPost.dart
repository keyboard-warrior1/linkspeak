import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'postBaseline.dart';
import 'popUpMenuButton.dart';
import 'fullPostCarousel.dart';
import 'profileImage.dart';
import 'adaptiveText.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';
import '../providers/postCarouselHelper.dart';

class FullPost extends StatelessWidget {
  final ScrollController scrollController;
  final Widget? display;
  final bool upView;
  final bool commentsView;
  final bool topicsView;
  final bool shareView;
  final dynamic handler;
  final void Function() upvote;
  final dynamic upButtonHandler;
  final void Function()? commentButtonHandler;
  final void Function()? topicButtonHandler;
  final void Function()? shareButtonHandler;
  final dynamic previewSetstate;
  FullPost({
    required this.scrollController,
    required this.display,
    required this.upView,
    required this.commentsView,
    required this.topicsView,
    required this.shareView,
    required this.handler,
    required this.upButtonHandler,
    required this.upvote,
    required this.commentButtonHandler,
    required this.topicButtonHandler,
    required this.shareButtonHandler,
    required this.previewSetstate,
  });
  String timeStamp(DateTime postedDate) {
    final String _datewithYear = DateFormat('MMMM d yyyy').format(postedDate);
    final String _dateNoYear = DateFormat('MMMM d').format(postedDate);
    final Duration _difference = DateTime.now().difference(postedDate);
    final bool _withinMinute =
        _difference <= const Duration(seconds: 59, milliseconds: 999);
    final bool _withinHour = _difference <=
        const Duration(minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinDay = _difference <=
        const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinYear = _difference <=
        const Duration(days: 364, minutes: 59, seconds: 59, milliseconds: 999);

    if (_withinMinute) {
      return 'a few seconds ago';
    } else if (_withinHour && _difference.inMinutes > 1) {
      return '${_difference.inMinutes} minutes ago';
    } else if (_withinHour && _difference.inMinutes == 1) {
      return '${_difference.inMinutes} minute ago';
    } else if (_withinDay && _difference.inHours > 1) {
      return '${_difference.inHours} hours ago';
    } else if (_withinDay && _difference.inHours == 1) {
      return '${_difference.inHours} hour ago';
    } else if (!_withinMinute && !_withinHour && !_withinDay && _withinYear) {
      return '$_dateNoYear';
    } else {
      return '$_datewithYear';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Color _primaryColor = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final void Function() helperHide = helper.hidePost;
    final void Function() helperDelete = helper.deletePost;
    final void Function() helperUnhide = helper.unhidePost;
    final String postId = helper.postId;
    final DateTime postedDate = helper.postedDate;
    final String userImageUrl = helper.userImageUrl;
    final String title = helper.title;
    final String description = helper.decription;
    final List<String> postTopics = helper.postTopics;
    final List<String> postImgUrls = helper.postImgUrls;
    final bool _noMedia = postImgUrls.isEmpty;
    final bool _withMedia = postImgUrls.isNotEmpty;
    final bool _noDescription = description.isEmpty;
    final bool _withDescription = description.isNotEmpty;
    const Widget _carousel = const FullPostCarousel();
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.only(top: 50.0),
        controller: scrollController,
        children: <Widget>[
          SizedBox(
            height:
                (_noMedia && _withDescription || _withMedia && _noDescription)
                    ? _deviceHeight * 0.9
                    : null,
            child: ChangeNotifierProvider<CarouselPhysHelp>.value(
              value: CarouselPhysHelp(),
              child: Builder(
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            TextButton(
                              onPressed: handler,
                              child: ProfileImage(
                                username: title,
                                url: userImageUrl,
                                factor: 0.10,
                                inEdit: false,
                                asset: null,
                              ),
                            ),
                            OptimisedText(
                              minWidth: _deviceWidth * 0.1,
                              maxWidth: _deviceWidth * 0.5,
                              minHeight: 50,
                              maxHeight: 50,
                              fit: BoxFit.scaleDown,
                              child: TextButton(
                                onPressed: handler,
                                child: Text(
                                  title,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            PopupMenuButton(
                              tooltip: 'More',
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
                                  child: GestureDetector(
                                    child: MyPopUpMenuButton(
                                      id: postId,
                                      postID: postId,
                                      isInProfile: false,
                                      postedByMe: title ==
                                          context.read<MyProfile>().getUsername,
                                      postTopics: postTopics,
                                      postMedia: postImgUrls,
                                      postDate: postedDate,
                                      isBlocked: false,
                                      isLinkedToMe: false,
                                      block: () {},
                                      unblock: () {},
                                      remove: () {},
                                      hidePost: helperHide,
                                      deletePost: helperDelete,
                                      unhidePost: helperUnhide,
                                      previewSetstate: previewSetstate,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      if (_withMedia && _withDescription)
                        WithMediaTextContent(
                          description: description,
                          controller: scrollController,
                        ),
                      if (_noMedia && _withDescription)
                        NoMediaTextContent(
                          description: description,
                          controller: scrollController,
                        ),
                      if (_withMedia && _noDescription) const Spacer(),
                      if (_noMedia && _withDescription ||
                          _withMedia && _noDescription)
                        const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_noMedia ||
                                _withMedia && postImgUrls.length == 1)
                              const Spacer(),
                            if (_withMedia && postImgUrls.length > 1)
                              FlutterSwitch(
                                showOnOff: true,
                                activeText: 'stop',
                                activeTextColor: Colors.white,
                                inactiveText: 'play',
                                value: Provider.of<CarouselPhysHelp>(context)
                                    .carouselPlay,
                                onToggle: (valu) {
                                  Provider.of<CarouselPhysHelp>(context,
                                          listen: false)
                                      .playCarousel();
                                },
                                activeColor: _primaryColor,
                                activeIcon: Icon(
                                  Icons.pause,
                                ),
                                activeToggleColor: _accentColor,
                                inactiveIcon: Icon(
                                  Icons.play_arrow,
                                ),
                              ),
                            if (_withMedia && postImgUrls.length > 1)
                              Flexible(
                                fit: FlexFit.loose,
                                child: Center(
                                  child: Container(
                                    height: 50.0,
                                    width: 75,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: postImgUrls.map((url) {
                                        int index = postImgUrls.indexOf(url);
                                        return Container(
                                          width: 8.0,
                                          height: 8.0,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 2.0,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border:
                                                Provider.of<CarouselPhysHelp>(
                                                                context)
                                                            .current ==
                                                        index
                                                    ? Border.all(
                                                        color: _primaryColor)
                                                    : null,
                                            color:
                                                Provider.of<CarouselPhysHelp>(
                                                                context)
                                                            .current ==
                                                        index
                                                    ? _accentColor
                                                    : _primaryColor,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            Text(
                              timeStamp(postedDate),
                              softWrap: false,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 17.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_withMedia && _noDescription) _carousel,
                      if (_withMedia && _withDescription) _carousel,
                      if (_noMedia ||
                          _withMedia &&
                              _noDescription &&
                              postImgUrls.length == 1)
                        const Spacer(),
                    ],
                  );
                },
              ),
            ),
          ),
          PostBar(
            postID: postId,
            shareView: shareView,
            shareButtonHandler: shareButtonHandler,
            isInFeed: false,
            upButtonHandler: upButtonHandler,
            commentButtonHandler: commentButtonHandler,
            topicButtonHandler: topicButtonHandler,
            upView: upView,
            commentView: commentsView,
            topicsView: topicsView,
          ),
          if (upView ||
              commentsView ||
              topicsView ||
              shareView && display != null)
            SizedBox(
              child: display,
            ),
        ],
      ),
    );
  }
}

class NoMediaTextContent extends StatelessWidget {
  const NoMediaTextContent({
    Key? key,
    required this.description,
    required this.controller,
  }) : super(key: key);

  final String? description;
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.25,
          maxHeight: _deviceHeight * 0.65,
          minWidth: _deviceWidth * 0.95,
          maxWidth: _deviceWidth * 0.95,
        ),
        child: NotificationListener<OverscrollNotification>(
          onNotification: (OverscrollNotification value) {
            if (value.overscroll < 0 &&
                controller.offset + value.overscroll <= 0) {
              if (controller.offset != 0) controller.jumpTo(0);
              return true;
            }
            if (controller.offset + value.overscroll >=
                controller.position.maxScrollExtent) {
              if (controller.offset != controller.position.maxScrollExtent)
                controller.jumpTo(controller.position.maxScrollExtent);
              return true;
            }
            controller.jumpTo(controller.offset + value.overscroll);
            return true;
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: AutoSizeText(
              '${description!}',
              softWrap: true,
              textAlign: TextAlign.start,
              minFontSize: 18.0,
              maxFontSize: 55.0,
              maxLines: 1500,
              style: TextStyle(fontFamily: 'Roboto'),
            ),
          ),
        ),
      ),
    );
  }
}

class WithMediaTextContent extends StatelessWidget {
  const WithMediaTextContent({
    Key? key,
    required this.description,
    required this.controller,
  }) : super(key: key);

  final String? description;
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.20,
          maxHeight: _deviceHeight * 0.55,
          minWidth: _deviceWidth * 0.95,
          maxWidth: _deviceWidth * 0.95,
        ),
        child: NotificationListener<OverscrollNotification>(
          onNotification: (OverscrollNotification value) {
            if (value.overscroll < 0 &&
                controller.offset + value.overscroll <= 0) {
              if (controller.offset != 0) controller.jumpTo(0);
              return true;
            }
            if (controller.offset + value.overscroll >=
                controller.position.maxScrollExtent) {
              if (controller.offset != controller.position.maxScrollExtent)
                controller.jumpTo(controller.position.maxScrollExtent);
              return true;
            }
            controller.jumpTo(controller.offset + value.overscroll);
            return true;
          },
          child: SingleChildScrollView(
            child: AutoSizeText(
              '${description!}',
              softWrap: true,
              textAlign: TextAlign.start,
              minFontSize: 18.0,
              maxFontSize: 55.0,
              maxLines: 1500,
              style: TextStyle(fontFamily: 'Roboto'),
            ),
          ),
        ),
      ),
    );
  }
}
