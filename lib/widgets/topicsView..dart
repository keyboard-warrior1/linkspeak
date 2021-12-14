import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/screenArguments.dart';
import '../routes.dart';
import 'topicChip.dart';

class TopicsView extends StatefulWidget {
  final String postID;
  final int numOfTopics;
  TopicsView({required this.numOfTopics, required this.postID});

  @override
  _TopicsViewState createState() => _TopicsViewState();
}

class _TopicsViewState extends State<TopicsView> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getTopics;
  List<String> topics = [];
  @override
  void initState() {
    super.initState();
    _getTopics = getTopics();
  }

  Future<void> getTopics() async {
    if (widget.numOfTopics == 0) {
      return;
    } else {
      final _currentPost =
          await firestore.collection('Posts').doc(widget.postID).get();

      final _currentPostTopics = _currentPost.get('topics') as List;
      topics = _currentPostTopics.map((topic) => topic as String).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    return FutureBuilder(
      future: _getTopics,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: deviceHeight * 0.3,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  const Center(
                    child: const CircularProgressIndicator(),
                  ),
                ]),
          );
        }
        if (snapshot.hasError) {
          Container(
            height: deviceHeight * 0.3,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'An error has occured, please try again',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color?>(_primaryColor),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                        const EdgeInsets.all(0.0),
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () => setState(() => _getTopics = getTopics()),
                    child: Center(
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]),
          );
        }
        return Column(
          children: <Widget>[
            if (widget.numOfTopics == 0)
              Container(
                height: deviceHeight * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(
                          17.0,
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
                            fontSize: 33.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.numOfTopics != 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 85.0),
                child: Wrap(
                  children: <Widget>[
                    ...topics.map((topic) {
                      void _showModalBottomSheet(String name) {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            final screenArgs = TopicScreenArgs(name);
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
                                child: ListTile(
                                  horizontalTitleGap: 5.0,
                                  leading: const Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                  title: const Text(
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
                              ),
                            );
                          },
                        );
                      }

                      final String _name = topic;
                      final Widget _chips = GestureDetector(
                        onTap: () => _showModalBottomSheet(_name),
                        child: TopicChip(
                          _name,
                          null,
                          null,
                          Colors.white,
                          FontWeight.normal,
                        ),
                      );
                      return _chips;
                    })
                  ],
                ),
              )
          ],
        );
      },
    );
  }
}
