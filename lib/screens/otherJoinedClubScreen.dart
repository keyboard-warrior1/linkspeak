import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../models/miniClub.dart';
import '../my_flutter_app_icons.dart' as customIcons;
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/clubObject.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class OtherJoinedClubs extends StatefulWidget {
  final dynamic username;
  const OtherJoinedClubs(this.username);

  @override
  _OtherJoinedClubsState createState() => _OtherJoinedClubsState();
}

class _OtherJoinedClubsState extends State<OtherJoinedClubs> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getMyLinks;
  List<MiniClub> links = [];
  final _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool userSearchLoading = false;
  bool _clearable = false;
  List<MiniClub> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullLinks = [];
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> getMyLinks() async {
    final users = firestore.collection('Users');
    final myUser = users.doc(widget.username);
    final myLinks = myUser
        .collection('Joined Clubs')
        .orderBy('date', descending: true)
        .limit(20);
    final myFullClubs = await myUser.collection('Joined Clubs').get();
    final fullLinkDocs = myFullClubs.docs;
    fullLinks = fullLinkDocs;
    final getLinks = await myLinks.get();
    final linksDocs = getLinks.docs;

    for (var link in linksDocs) {
      final username = link.id;
      final MiniClub mini = MiniClub(clubName: username);
      links.add(mini);
    }
    if (linksDocs.length < 20) {
      isLastPage = true;
    }
    setState(() {});
  }

  Future<void> getMoreLinks() async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final lastLink = links.last.clubName;
      final users = firestore.collection('Users');
      final myUser = users.doc(widget.username);
      final lastLinkDoc =
          await myUser.collection('Joined Clubs').doc(lastLink).get();
      final myLinks = myUser
          .collection('Joined Clubs')
          .orderBy('date', descending: true)
          .startAfterDocument(lastLinkDoc)
          .limit(20);
      final getLinks = await myLinks.get();
      final linksDocs = getLinks.docs;

      for (var link in linksDocs) {
        final username = link.id;
        final MiniClub mini = MiniClub(clubName: username);
        links.add(mini);
      }
      if (linksDocs.length < 20) {
        isLastPage = true;
      }
      isLoading = false;
      setState(() {});
    }
  }

  void getUserResults(String name) {
    final lowerCaseName = name.toLowerCase();
    fullLinks.forEach((doc) {
      if (userSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String clubName = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.clubName == clubName)) {
          final MiniClub mini = MiniClub(clubName: clubName);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.clubName == clubName)) {
          final MiniClub mini = MiniClub(clubName: clubName);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.clubName == clubName)) {
          final MiniClub mini = MiniClub(clubName: clubName);
          userSearchResults.add(mini);
          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getMyLinks = getMyLinks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreLinks();
          }
        }
      }
    });
    _textController.addListener(() {
      if (_textController.value.text.isNotEmpty) {
        if (!_clearable)
          setState(() {
            _clearable = true;
          });
      } else {}

      if (_textController.value.text.isEmpty) {
        if (_clearable)
          setState(() {
            _clearable = false;
          });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    _textController.removeListener(() {});
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final _primaryColor = theme.colorScheme.primary;
    final _accentColor = theme.colorScheme.secondary;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    return (links.length == 0)
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  const SettingsBar('Clubs'),
                  const Spacer(),
                  Icon(customIcons.MyFlutterApp.clubs,
                      color: Colors.grey.shade300, size: 85.0),
                  const SizedBox(height: 10.0),
                  Center(
                      child: OptimisedText(
                          minWidth: _deviceWidth * 0.90,
                          maxWidth: _deviceWidth * 0.90,
                          minHeight: _deviceHeight * 0.05,
                          maxHeight: _deviceHeight * 0.10,
                          fit: BoxFit.scaleDown,
                          child: Text("User hasn't joined any clubs yet",
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 25.0)))),
                  const Spacer()
                ])))
        : Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SafeArea(
                    child: FutureBuilder(
                        future: _getMyLinks,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return SizedBox(
                                height: _deviceHeight,
                                width: _deviceWidth,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const SettingsBar('Clubs'),
                                      const Spacer(),
                                      const CircularProgressIndicator(
                                          strokeWidth: 1.50),
                                      const Spacer()
                                    ]));

                          if (snapshot.hasError)
                            return SizedBox(
                                height: _deviceHeight,
                                width: _deviceWidth,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const SettingsBar('Clubs'),
                                      const Spacer(),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text('An error has occured',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17.0)),
                                            const SizedBox(width: 10.0),
                                            Container(
                                                width: 100.0,
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: TextButton(
                                                    style: ButtonStyle(
                                                        padding: MaterialStateProperty.all<
                                                                EdgeInsetsGeometry?>(
                                                            const EdgeInsets.symmetric(
                                                                vertical: 1.0,
                                                                horizontal:
                                                                    5.0)),
                                                        enableFeedback: false,
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color?>(
                                                                    _primaryColor)),
                                                    onPressed: () {
                                                      setState(() {
                                                        _getMyLinks =
                                                            getMyLinks();
                                                      });
                                                    },
                                                    child: Text('Retry',
                                                        style: TextStyle(
                                                            fontSize: 19.0,
                                                            color: _accentColor))))
                                          ]),
                                      const Spacer()
                                    ]));

                          return Builder(builder: (context) {
                            return SizedBox(
                                height: _deviceHeight,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const SettingsBar('Clubs'),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 8.0),
                                          child: TextField(
                                              onChanged: (text) async {
                                                if (text.isEmpty) {
                                                  if (userSearchResults
                                                      .isNotEmpty)
                                                    userSearchResults.clear();
                                                } else {
                                                  if (!userSearchLoading) {
                                                    if (userSearchResults
                                                        .isNotEmpty)
                                                      userSearchResults.clear();
                                                  }
                                                  if (!userSearchLoading) {
                                                    setState(() {
                                                      userSearchLoading = true;
                                                    });
                                                  }
                                                  getUserResults(text);
                                                  setState(() {
                                                    userSearchLoading = false;
                                                  });
                                                }
                                              },
                                              controller: _textController,
                                              decoration: InputDecoration(
                                                  prefixIcon: const Icon(
                                                      Icons.search,
                                                      color: Colors.grey),
                                                  suffixIcon: (_clearable)
                                                      ? IconButton(
                                                          splashColor: Colors
                                                              .transparent,
                                                          tooltip: 'Clear',
                                                          onPressed: () {
                                                            setState(() {
                                                              _textController
                                                                  .clear();
                                                              userSearchResults
                                                                  .clear();
                                                              _clearable =
                                                                  false;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.clear,
                                                              color:
                                                                  Colors.grey))
                                                      : null,
                                                  filled: true,
                                                  fillColor:
                                                      Colors.grey.shade200,
                                                  hintText: 'Search clubs',
                                                  hintStyle: const TextStyle(
                                                      color: Colors.grey),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      borderSide:
                                                          BorderSide.none)))),
                                      if (_textController
                                              .value.text.isNotEmpty &&
                                          userSearchResults.isEmpty &&
                                          !userSearchLoading)
                                        Container(
                                            child: const Center(
                                                child: const Text(
                                                    'No results found',
                                                    style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255,
                                                            49,
                                                            49,
                                                            49))))),
                                      if (userSearchResults.isNotEmpty &&
                                          !userSearchLoading)
                                        Expanded(
                                            child: Noglow(
                                                child: ListView(
                                                    keyboardDismissBehavior:
                                                        ScrollViewKeyboardDismissBehavior
                                                            .onDrag,
                                                    children: <Widget>[
                                              ...userSearchResults
                                                  .take(20)
                                                  .map((result) {
                                                final int index =
                                                    userSearchResults
                                                        .indexOf(result);
                                                final current =
                                                    userSearchResults[index];
                                                final username =
                                                    current.clubName;
                                                return ClubObject(
                                                    clubName: username);
                                              })
                                            ]))),
                                      if (_textController.value.text.isEmpty)
                                        Expanded(
                                            child: Noglow(
                                                child: ListView.builder(
                                                    itemCount: links.length + 1,
                                                    controller:
                                                        _scrollController,
                                                    keyboardDismissBehavior:
                                                        ScrollViewKeyboardDismissBehavior
                                                            .onDrag,
                                                    itemBuilder: (_, index) {
                                                      if (index ==
                                                          links.length) {
                                                        if (isLoading) {
                                                          return Center(
                                                              child: Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          10.0),
                                                                  height: 35.0,
                                                                  width: 35.0,
                                                                  child: Center(
                                                                      child: const CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              1.50))));
                                                        }
                                                        if (isLastPage) {
                                                          return emptyBox;
                                                        }
                                                      } else {
                                                        final link =
                                                            links[index];
                                                        final String _username =
                                                            link.clubName;
                                                        return ClubObject(
                                                            clubName:
                                                                _username);
                                                      }
                                                      return emptyBox;
                                                    })))
                                    ]));
                          });
                        }))));
  }
}
