import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/profile.dart';
import '../../models/screenArguments.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/profileScrollProvider.dart';
import '../../routes.dart';
import '../common/adaptiveText.dart';
import '../common/nestedScroller.dart';
import '../topics/addTopic.dart';
import '../topics/topicChip.dart';

class TopicsTab extends StatefulWidget {
  final bool isMyProfile;
  const TopicsTab({required this.isMyProfile});

  @override
  _TopicsTabState createState() => _TopicsTabState();
}

class _TopicsTabState extends State<TopicsTab> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool publicProfile = false;
  bool imLinkedToThem = false;
  late void Function(String) addTopic;
  late void Function(int) removeTopic;
  late final ScrollController profileScrollController;
  @override
  void initState() {
    super.initState();
    addTopic = Provider.of<MyProfile>(context, listen: false).addTopic;
    removeTopic = Provider.of<MyProfile>(context, listen: false).removeTopic;
    if (widget.isMyProfile)
      profileScrollController =
          Provider.of<ProfileScrollProvider>(context, listen: false)
              .profileScrollController;
    else
      profileScrollController =
          Provider.of<OtherProfile>(context, listen: false)
              .getProfileScrollController;

    if (!widget.isMyProfile) {
      publicProfile =
          Provider.of<OtherProfile>(context, listen: false).getVisibility ==
              TheVisibility.public;
      imLinkedToThem =
          Provider.of<OtherProfile>(context, listen: false).imLinkedToThem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    late final List<String>? otherTopicNames;
    late final bool imBlocked;
    late final bool isBanned;
    final double _deviceWidth = General.widthQuery(context);
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final List<String> topicNames = Provider.of<MyProfile>(context).getTopics;
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    if (!widget.isMyProfile) {
      otherTopicNames =
          Provider.of<OtherProfile>(context, listen: false).getTopics;
      imBlocked = Provider.of<OtherProfile>(context, listen: false).imBlocked;
      isBanned = Provider.of<OtherProfile>(context, listen: false).isBanned;
    }
    final theTopics = ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: _deviceHeight * 0.35, maxHeight: _deviceHeight * 0.85),
        child: Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0),
            child: NestedScroller(
                controller: profileScrollController,
                child: ListView(
                    padding: const EdgeInsets.only(bottom: 55.0),
                    shrinkWrap: true,
                    children: <Widget>[
                      Wrap(children: <Widget>[
                        if (widget.isMyProfile)
                          Container(
                              child: GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(31.0)),
                                      backgroundColor: Colors.white,
                                      builder: (_) {
                                        return AddTopic(addTopic, topicNames,
                                            true, false, false);
                                      }),
                                  child: TopicChip(
                                      lang.clubs_newPost22,
                                      Icon(Icons.add, color: _accentColor),
                                      () => showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(31.0)),
                                          backgroundColor: Colors.white,
                                          builder: (_) {
                                            return AddTopic(addTopic,
                                                topicNames, true, false, false);
                                          }),
                                      _accentColor,
                                      FontWeight.bold))),
                        if (!widget.isMyProfile)
                          ...otherTopicNames!.map(
                            (name) {
                              return GestureDetector(
                                  onTap: () {
                                    final TopicScreenArgs screenArgs =
                                        TopicScreenArgs(name);
                                    Navigator.pushNamed(context,
                                        RouteGenerator.topicPostsScreen,
                                        arguments: screenArgs);
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.all(1.0),
                                      child: TopicChip(
                                          name,
                                          null,
                                          null,
                                          Colors.white,
                                          FontWeight.normal,
                                          Provider.of<OtherProfile>(context,
                                                  listen: false)
                                              .getPrimaryColor)));
                            },
                          ).toList(),
                        if (widget.isMyProfile)
                          ...topicNames.map(
                            (name) {
                              int idx = topicNames.indexOf(name);
                              Future<void> _removeTopic() {
                                EasyLoading.show(
                                    status: lang.flares_comments1,
                                    dismissOnTap: true);
                                var batch = firestore.batch();
                                final myUser = firestore
                                    .collection('Users')
                                    .doc('$_myUsername');
                                final thisTopic =
                                    firestore.collection('Topics').doc(name);
                                final thisTopicProfile = thisTopic
                                    .collection('profiles removed')
                                    .doc(_myUsername);
                                batch.update(myUser, {
                                  'Topics': FieldValue.arrayRemove(['$name'])
                                });
                                batch.set(
                                    thisTopic,
                                    {
                                      'profiles': FieldValue.increment(-1),
                                      'profiles removed':
                                          FieldValue.increment(1)
                                    },
                                    SetOptions(merge: true));
                                batch.set(
                                    thisTopicProfile,
                                    {
                                      'times': FieldValue.increment(1),
                                      'date': DateTime.now()
                                    },
                                    SetOptions(merge: true));
                                return batch.commit().then((value) {
                                  removeTopic(idx);
                                  EasyLoading.dismiss();
                                }).catchError((onError) {
                                  EasyLoading.dismiss();
                                  EasyLoading.showError(lang.clubs_manage13,
                                      dismissOnTap: true,
                                      duration: const Duration(seconds: 2));
                                });
                              }

                              void _showModalBottomSheet(String topicName) {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (_) {
                                      final TopicScreenArgs screenArgs =
                                          TopicScreenArgs(topicName);
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  5.0))),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    ListTile(
                                                        horizontalTitleGap: 5.0,
                                                        leading: const Icon(
                                                            Icons.search,
                                                            color:
                                                                Colors.black),
                                                        title: Text(
                                                            lang
                                                                .widgets_profile23,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pushNamed(
                                                              context,
                                                              RouteGenerator
                                                                  .topicPostsScreen,
                                                              arguments:
                                                                  screenArgs);
                                                        }),
                                                    if (widget.isMyProfile)
                                                      ListTile(
                                                          horizontalTitleGap:
                                                              5.0,
                                                          leading: const Icon(
                                                              Icons.cancel,
                                                              color:
                                                                  Colors.red),
                                                          title: Text(
                                                              lang
                                                                  .widgets_profile24,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                          onTap: () {
                                                            _removeTopic();
                                                            Navigator.pop(
                                                                context);
                                                          })
                                                  ])));
                                    });
                              }

                              return GestureDetector(
                                  onTap: () => _showModalBottomSheet(name),
                                  child: Container(
                                      margin: const EdgeInsets.all(1.0),
                                      child: TopicChip(name, null, null,
                                          Colors.white, FontWeight.normal)));
                            },
                          ).toList()
                      ])
                    ]))));
    final emptyTopics = Container(
        height: _deviceHeight * 0.5,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (publicProfile ||
                  publicProfile && imLinkedToThem ||
                  !publicProfile && imLinkedToThem)
                Center(
                    child: OptimisedText(
                        minWidth: _deviceWidth * 0.75,
                        maxWidth: _deviceWidth * 0.75,
                        minHeight: _deviceHeight * 0.05,
                        maxHeight: _deviceHeight * 0.10,
                        fit: BoxFit.scaleDown,
                        child: Container(
                            padding: const EdgeInsets.all(21.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(31.0),
                                border: Border.all(color: Colors.grey)),
                            child: Text(lang.clubs_topics6,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 35.0)))))
            ]));
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(15.0),
                bottomRight: const Radius.circular(15.0))),
        child: (!widget.isMyProfile)
            ? (imBlocked || isBanned)
                ? (!_myUsername.startsWith('Linkspeak'))
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Icon(Icons.lock_outline,
                                color: Colors.black, size: _deviceHeight * 0.15)
                          ])
                    : (otherTopicNames!.isEmpty)
                        ? emptyTopics
                        : theTopics
                : (!publicProfile)
                    ? (!imLinkedToThem)
                        ? (!_myUsername.startsWith('Linkspeak'))
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    Icon(Icons.lock_outline,
                                        color: Colors.black,
                                        size: _deviceHeight * 0.15)
                                  ])
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
