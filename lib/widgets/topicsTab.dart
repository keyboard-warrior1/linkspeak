import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../providers/otherProfileProvider.dart';
import '../routes.dart';
import 'adaptiveText.dart';
import 'topicChip.dart';
import 'addTopic.dart';

class TopicsTab extends StatefulWidget {
  final ScrollController scrollController;
  final bool isMyProfile;
  final bool publicProfile;
  final bool imLinkedToThem;
  final dynamic addTopic;
  final dynamic removeTopic;
  const TopicsTab({
    required this.scrollController,
    required this.isMyProfile,
    required this.publicProfile,
    required this.imLinkedToThem,
    required this.addTopic,
    required this.removeTopic,
  });

  @override
  _TopicsTabState createState() => _TopicsTabState();
}

class _TopicsTabState extends State<TopicsTab> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    late final List<String>? otherTopicNames;
    late final bool imBlocked;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _accentColor = Theme.of(context).accentColor;
    final List<String> topicNames = Provider.of<MyProfile>(context).getTopics;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    if (!widget.isMyProfile) {
      otherTopicNames =
          Provider.of<OtherProfile>(context, listen: false).getTopics;
      imBlocked = Provider.of<OtherProfile>(context, listen: false).imBlocked;
    }
    final theTopics = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _deviceHeight * 0.35,
        maxHeight: _deviceHeight * 0.85,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 0.0,
          left: 10.0,
          right: 10.0,
        ),
        child: NotificationListener<OverscrollNotification>(
          onNotification: (OverscrollNotification value) {
            if (value.overscroll < 0 &&
                widget.scrollController.offset + value.overscroll <= 0) {
              if (widget.scrollController.offset != 0)
                widget.scrollController.jumpTo(0);
              return true;
            }
            if (widget.scrollController.offset + value.overscroll >=
                widget.scrollController.position.maxScrollExtent) {
              if (widget.scrollController.offset !=
                  widget.scrollController.position.maxScrollExtent)
                widget.scrollController
                    .jumpTo(widget.scrollController.position.maxScrollExtent);
              return true;
            }
            widget.scrollController
                .jumpTo(widget.scrollController.offset + value.overscroll);
            return true;
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 55.0),
            shrinkWrap: true,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  if (widget.isMyProfile)
                    Container(
                      child: GestureDetector(
                        onTap: () => showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              31.0,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          builder: (_) {
                            return AddTopic(
                                widget.addTopic, topicNames, true, false);
                          },
                        ),
                        child: TopicChip(
                            'New topic',
                            Icon(Icons.add, color: _accentColor),
                            () => showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    31.0,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                builder: (_) {
                                  return AddTopic(
                                    widget.addTopic,
                                    topicNames,
                                    true,
                                    false,
                                  );
                                }),
                            _accentColor,
                            FontWeight.bold),
                      ),
                    ),
                  if (!widget.isMyProfile)
                    ...otherTopicNames!.map(
                      (name) {
                        int idx = topicNames.indexOf(name);
                        Future<void> _removeTopic() {
                          EasyLoading.show(
                              status: 'Loading', dismissOnTap: true);
                          final myUser =
                              firestore.collection('Users').doc('$_myUsername');
                          return myUser.update({
                            'Topics': FieldValue.arrayRemove(['$name'])
                          }).then((value) {
                            widget.removeTopic(idx);
                            EasyLoading.dismiss();
                          }).catchError((onError) {
                            EasyLoading.dismiss();
                            EasyLoading.showError(
                              'Failed',
                              dismissOnTap: true,
                              duration: const Duration(seconds: 2),
                            );
                          });
                        }

                        void _showModalBottomSheet(String topicName) {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              final TopicScreenArgs screenArgs =
                                  TopicScreenArgs(topicName);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                      )),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        horizontalTitleGap: 5.0,
                                        leading: Icon(
                                          Icons.search,
                                          color: Colors.black,
                                        ),
                                        title: Text(
                                          'Search topic',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(
                                            context,
                                            RouteGenerator.topicPostsScreen,
                                            arguments: screenArgs,
                                          );
                                        },
                                      ),
                                      if (widget.isMyProfile)
                                        ListTile(
                                          horizontalTitleGap: 5.0,
                                          leading: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          title: Text(
                                            'Remove topic',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            _removeTopic();
                                            Navigator.pop(context);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return GestureDetector(
                          onTap: () => _showModalBottomSheet(name),
                          child: Container(
                            margin: const EdgeInsets.all(
                              1.0,
                            ),
                            child: TopicChip(
                                name,
                                null,
                                null,
                                Colors.white,
                                FontWeight.normal,
                                Provider.of<OtherProfile>(context,
                                        listen: false)
                                    .getPrimaryColor),
                          ),
                        );
                      },
                    ).toList(),
                  if (widget.isMyProfile)
                    ...topicNames.map(
                      (name) {
                        int idx = topicNames.indexOf(name);
                        Future<void> _removeTopic() {
                          EasyLoading.show(
                              status: 'Loading', dismissOnTap: true);
                          final myUser =
                              firestore.collection('Users').doc('$_myUsername');
                          return myUser.update({
                            'Topics': FieldValue.arrayRemove(['$name'])
                          }).then((value) {
                            widget.removeTopic(idx);
                            EasyLoading.dismiss();
                          }).catchError((onError) {
                            EasyLoading.dismiss();
                            EasyLoading.showError(
                              'Failed',
                              dismissOnTap: true,
                              duration: const Duration(seconds: 2),
                            );
                          });
                        }

                        void _showModalBottomSheet(String topicName) {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              final TopicScreenArgs screenArgs =
                                  TopicScreenArgs(topicName);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                      )),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        horizontalTitleGap: 5.0,
                                        leading: Icon(
                                          Icons.search,
                                          color: Colors.black,
                                        ),
                                        title: Text(
                                          'Search topic',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(
                                            context,
                                            RouteGenerator.topicPostsScreen,
                                            arguments: screenArgs,
                                          );
                                        },
                                      ),
                                      if (widget.isMyProfile)
                                        ListTile(
                                          horizontalTitleGap: 5.0,
                                          leading: Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                          title: Text(
                                            'Remove topic',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            _removeTopic();
                                            Navigator.pop(context);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return GestureDetector(
                          onTap: () => _showModalBottomSheet(name),
                          child: Container(
                            margin: const EdgeInsets.all(
                              1.0,
                            ),
                            child: TopicChip(name, null, null, Colors.white,
                                FontWeight.normal),
                          ),
                        );
                      },
                    ).toList()
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final emptyTopics = Container(
      height: _deviceHeight * 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.publicProfile ||
              widget.publicProfile && widget.imLinkedToThem ||
              !widget.publicProfile && widget.imLinkedToThem)
            Center(
              child: OptimisedText(
                minWidth: _deviceWidth * 0.75,
                maxWidth: _deviceWidth * 0.75,
                minHeight: _deviceHeight * 0.05,
                maxHeight: _deviceHeight * 0.10,
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.all(
                    21.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      31.0,
                    ),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    'No topics added',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 35.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(15.0),
            bottomRight: const Radius.circular(15.0),
          ),
        ),
        child: (!widget.isMyProfile)
            ? (imBlocked)
                ? (!_myUsername.startsWith('Linkspeak'))
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.lock_outline,
                            color: Colors.black,
                            size: _deviceHeight * 0.15,
                          ),
                        ],
                      )
                    : (otherTopicNames!.isEmpty)
                        ? emptyTopics
                        : theTopics
                : (!widget.publicProfile)
                    ? (!widget.imLinkedToThem)
                        ? (!_myUsername.startsWith('Linkspeak'))
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.lock_outline,
                                    color: Colors.black,
                                    size: _deviceHeight * 0.15,
                                  ),
                                ],
                              )
                            : (otherTopicNames!.isEmpty)
                                ? emptyTopics
                                : theTopics
                        : (otherTopicNames!.isEmpty)
                            ? emptyTopics
                            : theTopics
                    : (otherTopicNames!.isEmpty)
                        ? emptyTopics
                        : theTopics
            : theTopics);
  }
}
