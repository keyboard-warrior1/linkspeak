import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../my_flutter_app_icons.dart' as customIcons;
import '../providers/appBarProvider.dart';
import '../providers/addPostScreenState.dart';
import '../providers/myProfileProvider.dart';

class BottomNavBar extends StatefulWidget {
  final void Function(int, void Function()) handler;
  final ScrollController feedController;
  const BottomNavBar({
    required this.handler,
    required this.feedController,
  });
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _existUnReadMessages = false;
  @override
  void initState() {
    super.initState();
    final String _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final chatsCollection =
        firestore.collection('Users/$_myUsername/chats').snapshots();
    chatsCollection.listen((event) {
      final info = event.docs;
      if (info.any((element) => element.get('isRead') == false)) {
        if (!_existUnReadMessages) {
          setState(() {
            _existUnReadMessages = true;
          });
        }
      } else {
        if (_existUnReadMessages) {
          setState(() {
            _existUnReadMessages = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.primaryColor;
    final Color _accentColor = _theme.accentColor;
    int selectedIndex = Provider.of<AppBarProvider>(context).selectedIndex;
    View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    bool showbar = Provider.of<AppBarProvider>(context).showBar;
    final void Function() clearPost =
        Provider.of<NewPostHelper>(context, listen: false).clear;
    const BottomNavigationBarItem _feed = const BottomNavigationBarItem(
      label: 'Feed',
      icon: const Icon(
        customIcons.MyFlutterApp.feed,
      ),
    );
    const BottomNavigationBarItem _newPost = BottomNavigationBarItem(
      label: 'Publish',
      icon: const Icon(
        customIcons.MyFlutterApp.add_cross_outlined_symbol,
      ),
    );
    final BottomNavigationBarItem _chats = BottomNavigationBarItem(
      label: 'Chats',
      icon: Stack(
        children: <Widget>[
          Center(
            child: const Icon(
              customIcons.MyFlutterApp.chats,
            ),
          ),
          _existUnReadMessages
              ? Align(
                  alignment: Alignment(0.20, -0.55),
                  child: Container(
                    height: 10.0,
                    width: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent[400],
                      border: Border.all(
                        color: Colors.black,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
    final BottomNavigationBar _navBar = BottomNavigationBar(
      showUnselectedLabels: false,
      showSelectedLabels: false,
      backgroundColor: _primarySwatch.withOpacity(0.71),
      elevation: 30.0,
      unselectedItemColor: Colors.white,
      currentIndex: selectedIndex,
      selectedItemColor: _accentColor,
      onTap: (int index) {
        if (selectedIndex == 0 && index == 0) {
          final double top = widget.feedController.position.minScrollExtent;
          final double currentPosition = widget.feedController.position.pixels;
          final double distance = top - currentPosition;
          final double _num = distance / -15;
          final Duration duration = Duration(milliseconds: _num.round());
          widget.feedController
              .animateTo(top, duration: duration, curve: Curves.linear);
        } else {
          widget.handler(index, clearPost);
        }
      },
      items: [
        _feed,
        _newPost,
        _chats,
      ],
    );
    final _sizedBox = Theme(
      data: ThemeData(
          splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: _navBar,
    );
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: (viewMode == View.normal && showbar) ? 45.0 : 0.0,
        child: _sizedBox,
      ),
    );
  }
}
