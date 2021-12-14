import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'Feed.dart';
import 'addPostScreen.dart';
import 'messagesTab.dart';
import '../models/profile.dart';
import '../providers/appBarProvider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/addPostScreenState.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../widgets/bottomNavBar.dart';
import '../widgets/preview.dart';
import '../widgets/shareWidget.dart';
import '../widgets/titleButton.dart';
import '../widgets/appBar.dart';
import '../widgets/scrollBar.dart';
import '../widgets/findPostFAB.dart';

enum ScrollMode { downward, upward, paused }

class FeedScreen extends StatefulWidget {
  static bool sheetOpen = false;
  static bool shareSheetOpen = false;
  static PersistentBottomSheetController? _controller;
  static PersistentBottomSheetController? _shareController;
  static final ScrollController scrollController =
      ScrollController(keepScrollOffset: true);
  static void sharePost(BuildContext context, String postID) {
    _shareController = showBottomSheet(
      context: context,
      builder: (context) {
        if (sheetOpen = false) sheetOpen = false;
        final Widget _shareWidget = ShareWidget(
            isInFeed: true,
            bottomSheetController: _shareController,
            postID: postID);
        return _shareWidget;
      },
      backgroundColor: Colors.transparent,
    );
    shareSheetOpen = true;
    _shareController?.closed.then((value) {
      shareSheetOpen = false;
    });
  }

  static void showPreview(
      final BuildContext context,
      final String title,
      final dynamic _handler,
      final TheVisibility visibility,
      final String userImageUrl,
      final String bio,
      final int numOfLinks,
      final int numOfLinkedTos,
      final bool imLinkedToThem) {
    _controller = showBottomSheet(
      context: context,
      builder: (context) {
        if (shareSheetOpen) shareSheetOpen = false;
        final Widget _preview = Preview(
            controller: _controller!,
            title: title,
            imLinkedToThem: imLinkedToThem,
            handler: _handler,
            visibility: visibility,
            userImageUrl: userImageUrl,
            bio: bio,
            numOfLinks: numOfLinks,
            numOfLinkedTos: numOfLinkedTos);
        return _preview;
      },
      backgroundColor: Colors.transparent,
    );
    sheetOpen = true;
    _controller?.closed.then((value) => sheetOpen = false);
  }

  const FeedScreen();
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {
  bool showBar = true;
  bool isScrollingDown = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ScrollMode _scrollMode = ScrollMode.paused;
  late Future<void> Function() _goOnline;
  late Future<void> Function() _goOffline;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _goOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _goOffline();
        break;
    }
  }

  Future<void> goOnline(String myUsername) {
    final _users = firestore.collection('Users');
    return _users.doc(myUsername).set({
      'Activity': 'Online',
      'Sign-in': DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<void> goOffline(String myUsername) {
    final _users = firestore.collection('Users');
    return _users.doc(myUsername).set({
      'Activity': 'Away',
      'Sign-out': DateTime.now(),
    }, SetOptions(merge: true));
  }

  void _scrollDown(int _speedFactor) {
    final bottom = FeedScreen.scrollController.position.maxScrollExtent;
    final double currentPosition = FeedScreen.scrollController.position.pixels;
    final double distance = currentPosition - bottom;
    final double factor = -_speedFactor / 20;
    final double _num = distance / factor;
    final Duration duration = Duration(milliseconds: _num.round());
    if (FeedScreen._controller != null && FeedScreen.sheetOpen) {
      FeedScreen._controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        FeedScreen.scrollController
            .animateTo(bottom, duration: duration, curve: Curves.linear);
      });
      FeedScreen._controller!.close();
    } else if (FeedScreen._shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen._shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
        FeedScreen.scrollController
            .animateTo(bottom, duration: duration, curve: Curves.linear);
      });
      FeedScreen._shareController!.close();
    } else {
      FeedScreen.scrollController
          .animateTo(bottom, duration: duration, curve: Curves.linear);
    }
  }

  void _scrollUp(int _speedFactor) {
    final top = FeedScreen.scrollController.position.minScrollExtent;
    final double currentPosition = FeedScreen.scrollController.position.pixels;
    final double distance = top - currentPosition;
    final double factor = -_speedFactor / 20;
    final double _num = distance / factor;
    final Duration duration = Duration(milliseconds: _num.round());
    if (FeedScreen._controller != null && FeedScreen.sheetOpen) {
      FeedScreen._controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        FeedScreen.scrollController
            .animateTo(top, duration: duration, curve: Curves.linear);
      });
      FeedScreen._controller!.close();
    } else if (FeedScreen._shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen._shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
        FeedScreen.scrollController
            .animateTo(top, duration: duration, curve: Curves.linear);
      });
      FeedScreen._shareController!.close();
    } else {
      FeedScreen.scrollController
          .animateTo(top, duration: duration, curve: Curves.linear);
    }
  }

  void playButtonHandler(void Function(View) _changeView) {
    if (FeedScreen._controller != null && FeedScreen.sheetOpen) {
      FeedScreen._controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
      });
      FeedScreen._controller!.close();
    } else if (FeedScreen._shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen._shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
      });
      FeedScreen._shareController!.close();
    }
    _changeView(View.autoScroll);
  }

  void startHandler(int _speedFactor, Scroll scrollMode,
      void Function(Scroll) _changeScroll) {
    if (scrollMode != Scroll.scrolling) {
      _changeScroll(Scroll.scrolling);
    }
    if (_scrollMode == ScrollMode.upward) {
      _scrollUp(_speedFactor);
    } else {
      _scrollMode = ScrollMode.downward;
      _changeScroll(Scroll.scrolling);
      _scrollDown(_speedFactor);
    }
  }

  void pauseHandler(void Function(Scroll) _changeScroll) {
    if (_scrollMode == ScrollMode.upward) {
      _scrollMode = ScrollMode.upward;
      _changeScroll(Scroll.paused);
      FeedScreen.scrollController.animateTo(FeedScreen.scrollController.offset,
          duration: const Duration(seconds: 0), curve: Curves.linear);
    } else if (_scrollMode == ScrollMode.downward) {
      _scrollMode = ScrollMode.downward;
      _changeScroll(Scroll.paused);
      FeedScreen.scrollController.animateTo(FeedScreen.scrollController.offset,
          duration: const Duration(seconds: 0), curve: Curves.linear);
    } else {
      _scrollMode = ScrollMode.paused;
      _changeScroll(Scroll.paused);
      FeedScreen.scrollController.animateTo(FeedScreen.scrollController.offset,
          duration: const Duration(seconds: 0), curve: Curves.linear);
    }
  }

  void reverseHandler(int _speedFactor) {
    if (_scrollMode == ScrollMode.downward ||
        FeedScreen.scrollController.position.pixels ==
            FeedScreen.scrollController.position.maxScrollExtent) {
      _scrollMode = ScrollMode.upward;
      _scrollUp(_speedFactor);
    } else if (_scrollMode == ScrollMode.upward) {
      _scrollMode = ScrollMode.downward;
      _scrollDown(_speedFactor);
    }
  }

  void stopHandler(
      void Function(View) _changeView, void Function(Scroll) _changeScroll) {
    if (FeedScreen._controller != null && FeedScreen.sheetOpen) {
      FeedScreen._controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        _changeView(View.normal);
        _scrollMode = ScrollMode.paused;
        _changeScroll(Scroll.paused);
        FeedScreen.scrollController.animateTo(
            FeedScreen.scrollController.offset,
            duration: const Duration(seconds: 0),
            curve: Curves.linear);
      });
      FeedScreen._controller!.close();
    } else if (FeedScreen._shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen._shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
      });
      FeedScreen._shareController!.close();
      _changeView(View.normal);
      _scrollMode = ScrollMode.paused;
      _changeScroll(Scroll.paused);
      FeedScreen.scrollController.animateTo(FeedScreen.scrollController.offset,
          duration: const Duration(seconds: 0), curve: Curves.linear);
    } else {
      _changeView(View.normal);
      _scrollMode = ScrollMode.paused;
      _changeScroll(Scroll.paused);
      FeedScreen.scrollController.animateTo(FeedScreen.scrollController.offset,
          duration: const Duration(seconds: 0), curve: Curves.linear);
    }
  }

  void pageHandler(BuildContext context, int index, void Function() showBar,
      void Function() clearNewPost) {
    FocusScope.of(context).unfocus();
    showBar();
    if (FeedScreen._controller != null && FeedScreen.sheetOpen) {
      FeedScreen._controller!.closed.then((value) {
        FeedScreen.sheetOpen = false;
      });
      FeedScreen._controller!.close();
      Provider.of<AppBarProvider>(context, listen: false).changeTab(index);
      pageController.animateToPage(
        index,
        curve: Curves.easeInOut,
        duration: kThemeAnimationDuration,
      );
    } else if (FeedScreen._shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen._shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
      });
      FeedScreen._shareController!.close();
      Provider.of<AppBarProvider>(context, listen: false).changeTab(index);
      pageController.animateToPage(
        index,
        curve: Curves.easeInOut,
        duration: kThemeAnimationDuration,
      );
    } else {
      Provider.of<AppBarProvider>(context, listen: false).changeTab(index);
      pageController.animateToPage(
        index,
        curve: Curves.easeInOut,
        duration: kThemeAnimationDuration,
      );
    }
    clearNewPost();
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      fcm.requestPermission();
    }
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _goOnline = () => goOnline(myUsername);
    _goOffline = () => goOffline(myUsername);
    WidgetsBinding.instance!.addObserver(this);
    FeedScreen.scrollController.addListener(() {
      if (mounted) {
        if (FeedScreen.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          Provider.of<AppBarProvider>(context, listen: false).hideBar();
        }
        if (FeedScreen.scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          Provider.of<AppBarProvider>(context, listen: false).showbar();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    // FeedScreen.scrollController.removeListener(() {});
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    View viewMode = Provider.of<AppBarProvider>(context).viewMode;
    Scroll scrollMode = Provider.of<AppBarProvider>(context).scrollMode;
    int _speedFactor = Provider.of<AppBarProvider>(context).speedFactor;
    final _postStateNoListen = context.read<NewPostHelper>();
    final void Function() clear = _postStateNoListen.clear;
    final void Function(View) _changeView =
        Provider.of<AppBarProvider>(context, listen: false).changeView;
    final void Function(Scroll) _changeScroll =
        Provider.of<AppBarProvider>(context, listen: false).changeScroll;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _changeTab(int ind, void Function() clearPost) {
      FocusScope.of(context).unfocus();
      Provider.of<AppBarProvider>(context, listen: false).changeTab(ind);
      clearPost();
      EasyLoading.dismiss();
      pageController.jumpToPage(ind);
      FeedScreen.sheetOpen = false;
      FeedScreen.shareSheetOpen = false;
    }

    final Widget _myAppBar = MyAppBar(() => playButtonHandler(_changeView));
    const Widget _title = const TitleButton();

    final Widget _scrollBar = ScrollBar(
        startHandler: () =>
            startHandler(_speedFactor, scrollMode, _changeScroll),
        pauseHandler: () => pauseHandler(_changeScroll),
        reverseHandler: () => reverseHandler(_speedFactor),
        stopHandler: () => stopHandler(_changeView, _changeScroll));
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:
            (myUsername.startsWith('Linkspeak')) ? const FindPostFAB() : null,
        key: _scaffoldKey,
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white10,
        appBar: null,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                  return false;
                },
                child: PageView(
                  children: const [
                    const Feed(),
                    const NewPost(),
                    const MessagesTab()
                  ],
                  controller: pageController,
                  onPageChanged: (index) => pageHandler(
                      context,
                      index,
                      Provider.of<AppBarProvider>(context, listen: false)
                          .showbar,
                      clear),
                  physics: (viewMode == View.normal)
                      ? AlwaysScrollableScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                ),
              ),
              _title,
              _myAppBar,
              _scrollBar,
              BottomNavBar(
                handler: _changeTab,
                feedController: FeedScreen.scrollController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
