import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/miniProfile.dart';
import '../providers/myProfileProvider.dart';
import 'settingsBar.dart';
import 'adaptiveText.dart';
import 'linkObject.dart';

class MyLinked extends StatefulWidget {
  const MyLinked();

  @override
  _MyLinkedState createState() => _MyLinkedState();
}

class _MyLinkedState extends State<MyLinked> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getMyLinks;
  List<MiniProfile> links = [];
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> getMyLinks(
      String myUsername, void Function(List<MiniProfile>) setMyLinks) async {
    final users = firestore.collection('Users');
    final myUser = users.doc(myUsername);
    final myLinks = myUser.collection('Linked').limit(20);
    final getLinks = await myLinks.get();
    final linksDocs = getLinks.docs;

    for (var link in linksDocs) {
      final username = link.id;
      final getUser = await users.doc(username).get();
      if (getUser.exists) {
        final avatar = getUser.get('Avatar');
        final MiniProfile mini =
            MiniProfile(username: username, imgUrl: avatar);
        links.add(mini);
      } else {
        final MiniProfile mini = MiniProfile(username: username, imgUrl: '');
        links.add(mini);
      }
    }
    if (linksDocs.length < 20) {
      isLastPage = true;
    }
    setMyLinks(links);
    setState(() {});
  }

  Future<void> getMoreLinks(
      String myUsername, void Function(List<MiniProfile>) setMyLinks) async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final lastLink = links.last.username;
      final users = firestore.collection('Users');
      final myUser = users.doc(myUsername);
      final lastLinkDoc = await myUser.collection('Linked').doc(lastLink).get();
      final myLinks =
          myUser.collection('Linked').startAfterDocument(lastLinkDoc).limit(20);
      final getLinks = await myLinks.get();
      final linksDocs = getLinks.docs;

      for (var link in linksDocs) {
        final username = link.id;
        final getUser = await users.doc(username).get();
        if (getUser.exists) {
          final avatar = getUser.get('Avatar');
          final MiniProfile mini =
              MiniProfile(username: username, imgUrl: avatar);
          links.add(mini);
        } else {
          final MiniProfile mini = MiniProfile(username: username, imgUrl: '');
          links.add(mini);
        }
      }
      if (linksDocs.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setMyLinks(links);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final profileNo = Provider.of<MyProfile>(context, listen: false);
    final setMyLinks = profileNo.setMyLinkedTos;
    final myUsername = profileNo.getUsername;
    _getMyLinks = getMyLinks(myUsername, setMyLinks);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLinks(myUsername, setMyLinks);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final _primaryColor = theme.primaryColor;
    final _accentColor = theme.accentColor;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final setMyLinks = myProfile.setMyLinkedTos;
    final int numOfLinks = myProfile.getNumberOfLinkedTos;
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return (numOfLinks == 0)
        ? SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SettingsBar('Linked'),
                const Spacer(),
                Icon(
                  Icons.person_add_alt,
                  color: Colors.grey.shade300,
                  size: 85.0,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: OptimisedText(
                    minWidth: _deviceWidth * 0.90,
                    maxWidth: _deviceWidth * 0.90,
                    minHeight: _deviceHeight * 0.05,
                    maxHeight: _deviceHeight * 0.10,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Your profile is not linked to anyone',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          )
        : SafeArea(
            child: FutureBuilder(
                future: _getMyLinks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: _deviceHeight,
                      width: _deviceWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SettingsBar('Linked'),
                          const Spacer(),
                          const CircularProgressIndicator(),
                          const Spacer(),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: _deviceHeight,
                      width: _deviceWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SettingsBar('Linked'),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'An error has occured',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.0,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Container(
                                width: 100.0,
                                padding: const EdgeInsets.all(5.0),
                                child: TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry?>(
                                      const EdgeInsets.symmetric(
                                        vertical: 1.0,
                                        horizontal: 5.0,
                                      ),
                                    ),
                                    enableFeedback: false,
                                    backgroundColor:
                                        MaterialStateProperty.all<Color?>(
                                            _primaryColor),
                                  ),
                                  onPressed: () {
                                    _getMyLinks = getMyLinks(
                                        myProfile.getUsername, setMyLinks);
                                  },
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(
                                      fontSize: 19.0,
                                      color: _accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer()
                        ],
                      ),
                    );
                  }
                  return Builder(
                    builder: (context) {
                      final List<MiniProfile> links =
                          Provider.of<MyProfile>(context, listen: false)
                              .getMyLinkedTos;
                      return SizedBox(
                        height: _deviceHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SettingsBar('Linked'),
                            Expanded(
                              child: NotificationListener<
                                  OverscrollIndicatorNotification>(
                                onNotification: (overscroll) {
                                  overscroll.disallowGlow();
                                  return false;
                                },
                                child: ListView.builder(
                                    itemCount: links.length + 1,
                                    controller: _scrollController,
                                    itemBuilder: (_, index) {
                                      if (index == links.length) {
                                        if (isLoading) {
                                          return Center(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              height: 35.0,
                                              width: 35.0,
                                              child: Center(
                                                child:
                                                    const CircularProgressIndicator(),
                                              ),
                                            ),
                                          );
                                        }
                                        if (isLastPage) {
                                          return emptyBox;
                                        }
                                      } else {
                                        final link = links[index];
                                        final String _username = link.username;
                                        final String _imgUrl = link.imgUrl;
                                        return LinkObject(
                                          imgUrl: _imgUrl,
                                          username: _username,
                                        );
                                      }
                                      return emptyBox;
                                    }),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          );
  }
}
