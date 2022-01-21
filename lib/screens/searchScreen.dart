import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link_speak/routes.dart';
import '../models/topicSearch.dart';
import '../models/miniProfile.dart';
import '../widgets/searchTabBar.dart';
import '../widgets/userResult.dart';
import '../widgets/topicResult.dart';

class SearchTab extends StatefulWidget {
  const SearchTab();
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with SingleTickerProviderStateMixin {
  final FocusNode _searchNode = FocusNode();
  bool userSearchLoading = false;
  bool topicSearchLoading = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final TabController _controller;
  final TextEditingController _textController = TextEditingController();
  static const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890_';
  Random random = Random();
  List<MiniProfile> userSearchResults = [];
  List<TopicSearchResult> topicSearchResults = [];
  bool _clearable = false;
  int index = 0;
  _handleTabSelection() {
    if (_controller.indexIsChanging) {
      setState(() {
        index = _controller.index;
      });
    }
  }

  Future<void> getUserResults(String name, bool insert) async {
    final usersCollection = firestore.collection('Users');
    final getResults = usersCollection.where('Username', isEqualTo: name);
    final results = await getResults.get();
    final docs = results.docs;
    for (var result in docs) {
      final username = result.id;
      final user = await usersCollection.doc(username).get();
      final image = user.get('Avatar');
      final MiniProfile mini = MiniProfile(username: username, imgUrl: image);
      if (insert) {
        if (!userSearchResults.any((result) => result.username == name))
          userSearchResults.insert(0, mini);
      } else {
        if (!userSearchResults.any((result) => result.username == name))
          userSearchResults.add(mini);
      }
    }
    setState(() {});
  }

  Future<void> getTopicResults(String name, bool insert) async {
    final topic = await firestore.collection('Topics').doc(name).get();
    if (topic.exists) {
      final numOfPosts = topic.get('count');
      final result = TopicSearchResult(topicName: name, numOfPosts: numOfPosts);
      if (insert) {
        if (!topicSearchResults.any((result) => result.topicName == name)) {
          topicSearchResults.insert(0, result);
        }
      } else {
        if (!topicSearchResults.any((result) => result.topicName == name))
          topicSearchResults.add(result);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      length: 3,
      vsync: this,
    );

    _controller.addListener(_handleTabSelection);
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
    _controller.removeListener(() {});
    _textController.removeListener(() {});
    _controller.dispose();
    _textController.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    String getRandomString() {
      String finalString = '';
      for (var i = 0; i <= 1; i++) {
        int randomNum = random.nextInt(chars.length);
        var generate = Iterable.generate(1, (_) => chars.codeUnitAt(randomNum));
        var string = String.fromCharCodes(generate);
        finalString = finalString + string;
      }

      return finalString;
    }

    final Container _searchField = Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
              tooltip: 'back',
              splashColor: Colors.black38,
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
          SizedBox(
            width: _deviceWidth * 0.75,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                focusNode: _searchNode,
                onChanged: (text) async {
                  if (text.isEmpty) {
                    if (userSearchResults.isNotEmpty) userSearchResults.clear();
                    if (topicSearchResults.isNotEmpty)
                      topicSearchResults.clear();
                    return;
                  } else {
                    if (index == 0) {
                      if (!userSearchLoading) {
                        if (userSearchResults.isNotEmpty)
                          userSearchResults.clear();
                      }
                      if (!userSearchLoading) {
                        setState(() {
                          userSearchLoading = true;
                        });
                      }
                      getUserResults(text, true);
                      String generatedText = text + getRandomString();
                      for (var i = 0; i <= 7; i++) {
                        getUserResults(generatedText, false);
                      }

                      setState(() {
                        userSearchLoading = false;
                      });
                    } else {
                      if (!topicSearchLoading) {
                        if (topicSearchResults.isNotEmpty)
                          topicSearchResults.clear();
                      }
                      if (!topicSearchLoading) {
                        setState(() {
                          topicSearchLoading = true;
                        });
                      }
                      getTopicResults(text, true);
                      String generatedText = text + getRandomString();
                      for (var i = 0; i <= 7; i++) {
                        getTopicResults(generatedText, false);
                      }

                      setState(() {
                        topicSearchLoading = false;
                      });
                    }
                  }
                },
                controller: _textController,
                decoration: InputDecoration(
                  prefixIcon: (index == 0)
                      ? IconButton(
                          onPressed: () {
                            _searchNode.unfocus();
                            _searchNode.canRequestFocus = false;
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _searchNode.canRequestFocus = true;
                            });
                            Navigator.pushNamed(
                                context, RouteGenerator.scannerScreen);
                          },
                          icon: FittedBox(
                            fit: BoxFit.contain,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.qr_code_scanner,
                                    color: Colors.black),
                                const Text('SCAN',
                                    style: TextStyle(color: Colors.black))
                              ],
                            ),
                          ))
                      : const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: (_clearable)
                      ? IconButton(
                          splashColor: Colors.transparent,
                          tooltip: 'Clear',
                          onPressed: () {
                            setState(() {
                              _textController.clear();
                              userSearchResults.clear();
                              topicSearchResults.clear();
                              _clearable = false;
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  hintText: 'Search Linkspeak',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final Widget _searchBar = SearchTabBar(_controller);
    final Widget _searchResults = Container(
      color: Colors.white,
      child: SizedBox(
        height: _deviceHeight * 0.90,
        width: _deviceWidth,
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _controller,
          children: [
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 50.0),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      if (_textController.value.text.isEmpty)
                        Container(
                          child: const Center(
                            child: const Text(
                              'Search for people',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      if (_textController.value.text.isNotEmpty &&
                          userSearchResults.isEmpty &&
                          !userSearchLoading)
                        Container(
                          child: const Center(
                            child: const Text(
                              'Sorry, no results found',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      if (userSearchResults.isNotEmpty && !userSearchLoading)
                        ...userSearchResults.map((result) {
                          final int index = userSearchResults.indexOf(result);
                          final current = userSearchResults[index];
                          final username = current.username;
                          final img = current.imgUrl;
                          return UserResult(
                            username: username,
                            img: img,
                          );
                        }),
                    ],
                  ),
                ],
              ),
            ),
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 50.0),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      if (_textController.value.text.isEmpty)
                        Container(
                          child: const Center(
                            child: const Text(
                              'Search for topics',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      if (_textController.value.text.isNotEmpty &&
                          topicSearchResults.isEmpty &&
                          !topicSearchLoading)
                        Container(
                          child: const Center(
                            child: const Text(
                              'Sorry, no results found',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      if (topicSearchResults.isNotEmpty && !topicSearchLoading)
                        ...topicSearchResults.map((result) {
                          final int index = topicSearchResults.indexOf(result);
                          final current = topicSearchResults[index];
                          final name = current.topicName;
                          final number = current.numOfPosts;
                          return TopicResult(name, number);
                        }),
                      if (userSearchLoading)
                        SizedBox(
                          height: _deviceHeight * 0.90,
                          width: _deviceWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const <Widget>[
                              const Center(
                                child: const CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 50.0),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      if (_textController.value.text.isEmpty)
                        Container(
                          child: const Center(
                            child: const Text(
                              'Search for clubs',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: null,
        body: SafeArea(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
              return false;
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: _deviceHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _searchField,
                    _searchBar,
                    Expanded(child: _searchResults),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
