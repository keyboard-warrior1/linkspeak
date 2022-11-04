import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../my_flutter_app_icons.dart' as customIcons;
import '../../providers/appBarProvider.dart';
import '../../providers/myProfileProvider.dart';
import '../../screens/feedScreen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar();
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final feedController = FeedScreen.scrollController;
  final clubController = FeedScreen.clubScrollController;
  final spotlightController = FeedScreen.spotlightScrollController;
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

  void _changeTab(int ind) {
    FocusScope.of(context).unfocus();
    Provider.of<AppBarProvider>(context, listen: false).changeTab(ind);
    FeedScreen.pageController.jumpToPage(ind);
    FeedScreen.sheetOpen = false;
    FeedScreen.shareSheetOpen = false;
  }

  static const BottomNavigationBarItem _feed = const BottomNavigationBarItem(
    label: 'Home',
    icon: const Icon(
      customIcons.MyFlutterApp.feed,
    ),
  );
  static const BottomNavigationBarItem _spotlight =
      const BottomNavigationBarItem(
    label: 'Flares',
    icon: const Icon(
      customIcons.MyFlutterApp.spotlight,
      size: 30.0,
    ),
  );
  static const BottomNavigationBarItem _newPost = BottomNavigationBarItem(
    label: 'Publish',
    icon: const Icon(
      customIcons.MyFlutterApp.add_cross_outlined_symbol,
    ),
  );
  static const BottomNavigationBarItem _clubs = const BottomNavigationBarItem(
    label: 'Clubs',
    icon: const Icon(
      customIcons.MyFlutterApp.clubs,
    ),
  );
  void sameIndexHandler(ScrollController controller) {
    final double top = controller.position.minScrollExtent;
    final double currentPosition = controller.position.pixels;
    final double distance = top - currentPosition;
    final double _num = distance / -15;
    final Duration duration = Duration(milliseconds: _num.round());
    controller.animateTo(top, duration: duration, curve: Curves.linear);
  }

  void handleNavTapper(int selectedIndex, int index) {
    if (selectedIndex == 0 && index == 0) {
      sameIndexHandler(feedController);
    } else if (selectedIndex == 1 && index == 1) {
      sameIndexHandler(spotlightController);
    } else if (selectedIndex == 3 && index == 3) {
      sameIndexHandler(clubController);
    } else {
      _changeTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final Color _primarySwatch = _theme.colorScheme.primary;
    final Color _accentColor = _theme.colorScheme.secondary;
    int selectedIndex = Provider.of<AppBarProvider>(context).selectedIndex;
    View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    bool showbar = Provider.of<AppBarProvider>(context).showBar;
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
      showSelectedLabels: true,
      backgroundColor: _primarySwatch.withOpacity(0.71),
      elevation: 30.0,
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.white,
      currentIndex: selectedIndex,
      selectedItemColor: _accentColor,
      onTap: (index) => handleNavTapper(selectedIndex, index),
      items: [
        _feed,
        _spotlight,
        _newPost,
        _clubs,
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
        height: (viewMode == View.normal && showbar) ? 61.0 : 0.0,
        child: _sizedBox,
      ),
    );
  }
}
