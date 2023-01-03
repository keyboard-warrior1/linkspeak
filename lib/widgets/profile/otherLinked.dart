import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../models/miniProfile.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';
import '../common/adaptiveText.dart';
import '../common/linkObject.dart';
import '../common/noglow.dart';
import '../common/settingsBar.dart';

class OtherLinked extends StatefulWidget {
  final dynamic instance;
  final String username;
  const OtherLinked(this.instance, this.username);

  @override
  _OtherLinkedState createState() => _OtherLinkedState();
}

class _OtherLinkedState extends State<OtherLinked> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getMyLinks;
  List<MiniProfile> links = [];
  final _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool userSearchLoading = false;
  bool _clearable = false;
  List<MiniProfile> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullLinks = [];
  bool isLoading = false;
  bool isLastPage = false;
  Future<void> getMyLinks() async {
    final users = firestore.collection('Users');
    final myUser = users.doc(widget.username);
    final myFullLinked = await myUser.collection('Linked').get();
    final fullLinked = myFullLinked.docs;
    fullLinks = fullLinked;
    final myLinks =
        myUser.collection('Linked').orderBy('date', descending: true).limit(20);
    final getLinks = await myLinks.get();
    final linksDocs = getLinks.docs;
    for (var link in linksDocs) {
      final username = link.id;
      final MiniProfile mini = MiniProfile(username: username);
      links.insert(0, mini);
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
      final lastLink = links.last.username;
      final users = firestore.collection('Users');
      final myUser = users.doc(widget.username);
      final lastLinkDoc = await myUser.collection('Linked').doc(lastLink).get();
      final myLinks = myUser
          .collection('Linked')
          .orderBy('date', descending: true)
          .startAfterDocument(lastLinkDoc)
          .limit(20);
      final getLinks = await myLinks.get();
      final linksDocs = getLinks.docs;

      for (var link in linksDocs) {
        final username = link.id;
        final MiniProfile mini = MiniProfile(username: username);
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
        final String username = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
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
    final lang = General.language(context);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);
    final _primaryColor = theme.colorScheme.primary;
    final _accentColor = theme.colorScheme.secondary;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    const Widget emptyBox = SizedBox(height: 0, width: 0);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return ChangeNotifierProvider<OtherProfile>.value(
        value: widget.instance,
        child: Builder(builder: (context) {
          final int numOfLinks =
              Provider.of<OtherProfile>(context).getNumberOfLinkedTos;
          final bool imBlocked =
              Provider.of<OtherProfile>(context, listen: false).imBlocked;
          if (numOfLinks == 0)
            return SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  SettingsBar(lang.widgets_profile8_title),
                  const Spacer(),
                  Icon(Icons.person_add_alt,
                      color: Colors.grey.shade300, size: 85.0),
                  const SizedBox(height: 10.0),
                  Center(
                      child: OptimisedText(
                          minWidth: _deviceWidth * 0.90,
                          maxWidth: _deviceWidth * 0.90,
                          minHeight: _deviceHeight * 0.05,
                          maxHeight: _deviceHeight * 0.10,
                          fit: BoxFit.scaleDown,
                          child: Text(lang.widgets_profile16,
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 25.0)))),
                  const Spacer()
                ]));

          if (imBlocked && !myUsername.startsWith('Linkspeak'))
            return SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  SettingsBar(lang.widgets_profile8_title),
                  const Spacer(),
                  Center(
                      child: Icon(Icons.lock_outline,
                          color: Colors.black, size: _deviceHeight * 0.15)),
                  const Spacer()
                ]));

          return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                  child: FutureBuilder(
                      future: _getMyLinks,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return SizedBox(
                              height: _deviceHeight,
                              width: _deviceWidth,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SettingsBar(lang.widgets_profile8_title),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SettingsBar(lang.widgets_profile8_title),
                                    const Spacer(),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(lang.clubs_members2,
                                              style: const TextStyle(
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
                                                              horizontal: 5.0)),
                                                      enableFeedback: false,
                                                      backgroundColor:
                                                          MaterialStateProperty.all<Color?>(
                                                              _primaryColor)),
                                                  onPressed: () {
                                                    setState(() {
                                                      _getMyLinks =
                                                          getMyLinks();
                                                    });
                                                  },
                                                  child: Text(
                                                      lang.clubs_members3,
                                                      style: TextStyle(
                                                          fontSize: 19.0,
                                                          color:
                                                              _accentColor))))
                                        ]),
                                    const Spacer()
                                  ]));

                        return Builder(builder: (context) {
                          final myProfile =
                              Provider.of<OtherProfile>(context, listen: false);
                          final setMyLinks = myProfile.setMyLinkedTos;
                          setMyLinks(links);
                          return Builder(builder: (context) {
                            final List<MiniProfile> links =
                                Provider.of<OtherProfile>(context,
                                        listen: false)
                                    .getMyLinkedTos;
                            return SizedBox(
                                height: _deviceHeight,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SettingsBar(lang.widgets_profile8_title),
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
                                                          tooltip: lang
                                                              .clubs_assignAdmin5,
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
                                                                  Colors.grey),
                                                        )
                                                      : null,
                                                  filled: true,
                                                  fillColor:
                                                      Colors.grey.shade200,
                                                  hintText:
                                                      lang.widgets_profile10,
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
                                            child: Center(
                                                child: Text(
                                                    lang.clubs_assignAdmin7,
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
                                                    current.username;
                                                return LinkObject(
                                                    username: username);
                                              })
                                            ]))),
                                      if (_textController.value.text.isEmpty)
                                        Expanded(
                                            child: Noglow(
                                                child: ListView.builder(
                                                    keyboardDismissBehavior:
                                                        ScrollViewKeyboardDismissBehavior
                                                            .onDrag,
                                                    controller:
                                                        _scrollController,
                                                    itemCount: links.length + 1,
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
                                                            link.username;
                                                        return LinkObject(
                                                            username:
                                                                _username);
                                                      }
                                                      return emptyBox;
                                                    })))
                                    ]));
                          });
                        });
                      })));
        }));
  }
}
