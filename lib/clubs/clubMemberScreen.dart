import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../widgets/common/linkObject.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';

class ClubMemberScreen extends StatefulWidget {
  final dynamic clubName;
  const ClubMemberScreen(this.clubName);

  @override
  _ClubMemberScreenState createState() => _ClubMemberScreenState();
}

class _ClubMemberScreenState extends State<ClubMemberScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  bool userSearchLoading = false;
  bool _clearable = false;
  List<MiniProfile> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullLinks = [];
  List<MiniProfile> links = [];
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLastPage = false;
  late Future<void> _getClubMembers;
  Future<void> getClubMembers() async {
    final thisClub = firestore
        .collection('Clubs')
        .doc(widget.clubName)
        .collection('Members');
    final getAllMembers = await thisClub.get();
    final allDocs = getAllMembers.docs;
    fullLinks = allDocs;
    final getMembers =
        await thisClub.orderBy('date', descending: true).limit(20).get();
    final memberDocs = getMembers.docs;
    for (var member in memberDocs) {
      final username = member.id;
      final miniUser = MiniProfile(username: username);
      links.add(miniUser);
    }
    if (memberDocs.length < 20) isLastPage = true;
    setState(() {});
  }

  Future<void> getMoreClubMembers() async {
    if (isLoading) {
    } else {
      isLoading = true;
      setState(() {});
      final thisClub = firestore
          .collection('Clubs')
          .doc(widget.clubName)
          .collection('Members');
      final lastMember = links.last.username;
      final getLast = await thisClub.doc(lastMember).get();
      final getMore = await thisClub
          .orderBy('date', descending: true)
          .startAfterDocument(getLast)
          .limit(20)
          .get();
      final moreDocs = getMore.docs;
      for (var member in moreDocs) {
        final username = member.id;
        final miniUser = MiniProfile(username: username);
        links.add(miniUser);
      }
      if (moreDocs.length < 20) isLastPage = true;
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
    _getClubMembers = getClubMembers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (isLastPage) {
        } else {
          if (!isLoading) {
            getMoreClubMembers();
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
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: _deviceHeight,
                width: _deviceWidth,
                child: FutureBuilder(
                    future: _getClubMembers,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SettingsBar('Members'),
                              const Spacer(),
                              const CircularProgressIndicator(
                                  strokeWidth: 1.50),
                              const Spacer()
                            ]);
                      }
                      if (snapshot.hasError) {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SettingsBar('Members'),
                              const Spacer(),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('An error has occured',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17.0)),
                                    const SizedBox(width: 10.0),
                                    Container(
                                        width: 100.0,
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextButton(
                                            style: ButtonStyle(
                                                padding: MaterialStateProperty
                                                    .all<EdgeInsetsGeometry?>(
                                                        const EdgeInsets
                                                                .symmetric(
                                                            vertical: 1.0,
                                                            horizontal: 5.0)),
                                                enableFeedback: false,
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color?>(_primaryColor)),
                                            onPressed: () {
                                              setState(() {
                                                _getClubMembers =
                                                    getClubMembers();
                                              });
                                            },
                                            child: Text('Retry',
                                                style: TextStyle(
                                                    fontSize: 19.0,
                                                    color: _accentColor))))
                                  ]),
                              const Spacer()
                            ]);
                      }
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SettingsBar('Members'),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: TextField(
                                    onChanged: (text) async {
                                      if (text.isEmpty) {
                                        if (userSearchResults.isNotEmpty)
                                          userSearchResults.clear();
                                      } else {
                                        if (!userSearchLoading) {
                                          if (userSearchResults.isNotEmpty)
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
                                        prefixIcon: const Icon(Icons.search,
                                            color: Colors.grey),
                                        suffixIcon: (_clearable)
                                            ? IconButton(
                                                splashColor: Colors.transparent,
                                                tooltip: 'Clear',
                                                onPressed: () {
                                                  setState(() {
                                                    _textController.clear();
                                                    userSearchResults.clear();
                                                    _clearable = false;
                                                  });
                                                },
                                                icon: const Icon(Icons.clear,
                                                    color: Colors.grey))
                                            : null,
                                        filled: true,
                                        fillColor: Colors.grey.shade200,
                                        hintText: 'Search members',
                                        hintStyle:
                                            const TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none)))),
                            if (_textController.value.text.isNotEmpty &&
                                userSearchResults.isEmpty &&
                                !userSearchLoading)
                              Container(
                                  child: const Center(
                                      child: const Text('No results found',
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 49, 49, 49))))),
                            if (userSearchResults.isNotEmpty &&
                                !userSearchLoading)
                              Expanded(
                                  child: Noglow(
                                      child: ListView(
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          children: <Widget>[
                                    ...userSearchResults.take(20).map((result) {
                                      final int index =
                                          userSearchResults.indexOf(result);
                                      final current = userSearchResults[index];
                                      final username = current.username;
                                      return LinkObject(username: username);
                                    })
                                  ]))),
                            if (_textController.value.text.isEmpty)
                              Expanded(
                                  child: Noglow(
                                      child: ListView.builder(
                                          itemCount: links.length + 1,
                                          controller: _scrollController,
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          itemBuilder: (_, index) {
                                            if (index == links.length) {
                                              if (isLoading) {
                                                return Center(
                                                    child: Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10.0),
                                                        height: 35.0,
                                                        width: 35.0,
                                                        child: Center(
                                                            child:
                                                                const CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        1.50))));
                                              }
                                              if (isLastPage) {
                                                return emptyBox;
                                              }
                                            } else {
                                              final link = links[index];
                                              final String _username =
                                                  link.username;
                                              return LinkObject(
                                                  username: _username);
                                            }
                                            return emptyBox;
                                          })))
                          ]);
                    }))));
  }
}
