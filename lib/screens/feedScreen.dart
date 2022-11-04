import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../admin/widgets/Misc/adminFAB.dart';
import '../flares/flaresTab.dart';
import '../general.dart';
import '../models/profile.dart';
import '../providers/appBarProvider.dart';
import '../providers/myProfileProvider.dart';
import '../widgets/common/noglow.dart';
import '../widgets/home/appBar.dart';
import '../widgets/home/bottomNavBar.dart';
import '../widgets/home/scrollBar.dart';
import '../widgets/misc/titleButton.dart';
import '../widgets/profile/preview.dart';
import '../widgets/share/shareWidget.dart';
import 'Feed.dart';
import 'addPostScreen.dart';
import 'clubsTab.dart';
import 'messagesTab.dart';

enum ScrollMode { downward, upward, paused }

class FeedScreen extends StatefulWidget {
  static bool sheetOpen = false;
  static bool shareSheetOpen = false;
  static ScrollMode scrollMode = ScrollMode.paused;
  static PersistentBottomSheetController? controller;
  static PersistentBottomSheetController? shareController;
  static final ScrollController scrollController =
      ScrollController(keepScrollOffset: true);
  static final ScrollController clubScrollController =
      ScrollController(keepScrollOffset: true);
  static final ScrollController spotlightScrollController =
      ScrollController(keepScrollOffset: true);
  static final PageController pageController = PageController();
  static void sharePost(
      BuildContext context, String postID, String clubName, bool isClubPost) {
    shareController = showBottomSheet(
      context: context,
      builder: (context) {
        if (sheetOpen = false) sheetOpen = false;
        final Widget _shareWidget = ShareWidget(
          isInFeed: true,
          bottomSheetController: shareController,
          postID: postID,
          clubName: clubName,
          isClubPost: isClubPost,
          isFlare: false,
          flarePoster: '',
          collectionID: '',
          flareID: '',
        );
        return _shareWidget;
      },
      backgroundColor: Colors.transparent,
    );
    shareSheetOpen = true;
    shareController?.closed.then((value) {
      shareSheetOpen = false;
    });
  }

  static void scrollDown(int _speedFactor, bool isInClubTab) {
    final bottom = !isInClubTab
        ? FeedScreen.scrollController.position.maxScrollExtent
        : FeedScreen.clubScrollController.position.maxScrollExtent;
    final double currentPosition = !isInClubTab
        ? FeedScreen.scrollController.position.pixels
        : FeedScreen.clubScrollController.position.pixels;
    final double distance = currentPosition - bottom;
    final double factor = -_speedFactor / 20;
    final double _num = distance / factor;
    final Duration duration = Duration(milliseconds: _num.round());
    if (FeedScreen.controller != null && FeedScreen.sheetOpen) {
      FeedScreen.controller!.closed.then((_) {
        FeedScreen.sheetOpen = false;
        if (!isInClubTab)
          FeedScreen.scrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
        else
          FeedScreen.clubScrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
      });
      FeedScreen.controller!.close();
    } else if (FeedScreen.shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen.shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
        if (!isInClubTab)
          FeedScreen.scrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
        else
          FeedScreen.clubScrollController
              .animateTo(bottom, duration: duration, curve: Curves.linear);
      });
      FeedScreen.shareController!.close();
    } else {
      if (!isInClubTab)
        FeedScreen.scrollController
            .animateTo(bottom, duration: duration, curve: Curves.linear);
      else
        FeedScreen.clubScrollController
            .animateTo(bottom, duration: duration, curve: Curves.linear);
    }
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
    controller = showBottomSheet(
      context: context,
      builder: (context) {
        if (shareSheetOpen) shareSheetOpen = false;
        final Widget _preview = Preview(
            controller: controller!,
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
    controller?.closed.then((value) => sheetOpen = false);
  }

  const FeedScreen();
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with WidgetsBindingObserver {
  final feedController = FeedScreen.scrollController;
  final clubController = FeedScreen.clubScrollController;
  final spotlightController = FeedScreen.spotlightScrollController;
  bool showBar = true;
  bool isScrollingDown = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<void> Function() _goOnline;
  late Future<void> Function() _goOffline;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _goOnline();
        break;
      case AppLifecycleState.inactive:
        _goOffline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> goOnline(String myUsername) {
    final _users = firestore.collection('Users');
    return _users.doc(myUsername).set({
      'Activity': 'Online',
      'Sign-in': DateTime.now(),
    }, SetOptions(merge: true)).then((value) {
      return firestore
          .collection('Control')
          .doc('Details')
          .update({'online': FieldValue.increment(1)}).then((value) async {
        General.addDailyOnline();
        return await General.login(myUsername);
      });
    });
  }

  Future<void> goOffline(String myUsername) {
    final _users = firestore.collection('Users');
    return _users.doc(myUsername).set({
      'Activity': 'Away',
      'Sign-out': DateTime.now(),
    }, SetOptions(merge: true)).then((value) {
      return firestore
          .collection('Control')
          .doc('Details')
          .update({'online': FieldValue.increment(-1)}).then((value) async {
        General.subtractDailyOnline();
        return await General.logout(myUsername);
      });
    });
  }

  void pageHandler(int index) {
    FocusScope.of(context).unfocus();
    if (FeedScreen.controller != null && FeedScreen.sheetOpen) {
      FeedScreen.controller!.closed.then((value) {
        FeedScreen.sheetOpen = false;
      });
      FeedScreen.controller!.close();
      Provider.of<AppBarProvider>(context, listen: false).changeTab(index);
      FeedScreen.pageController.animateToPage(
        index,
        curve: Curves.easeInOut,
        duration: kThemeAnimationDuration,
      );
    } else if (FeedScreen.shareController != null &&
        FeedScreen.shareSheetOpen) {
      FeedScreen.shareController!.closed.then((value) {
        FeedScreen.shareSheetOpen = false;
      });
      FeedScreen.shareController!.close();
      Provider.of<AppBarProvider>(context, listen: false).changeTab(index);
      FeedScreen.pageController.animateToPage(
        index,
        curve: Curves.easeInOut,
        duration: kThemeAnimationDuration,
      );
    } else {
      Provider.of<AppBarProvider>(context, listen: false).changeTab(index);
      FeedScreen.pageController.animateToPage(
        index,
        curve: Curves.easeInOut,
        duration: kThemeAnimationDuration,
      );
    }
    EasyLoading.dismiss();
  }

  void handleScrollListeners(ScrollController controller) {
    final direction = controller.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      Provider.of<AppBarProvider>(context, listen: false).hideBar();
      Provider.of<AppBarProvider>(context, listen: false)
          .changeScroll(Scroll.paused);
    }
    if (direction == ScrollDirection.forward) {
      Provider.of<AppBarProvider>(context, listen: false).showbar();
      Provider.of<AppBarProvider>(context, listen: false)
          .changeScroll(Scroll.paused);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isIOS) fcm.requestPermission();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _goOnline = () => goOnline(myUsername);
    _goOffline = () => goOffline(myUsername);
    WidgetsBinding.instance.addObserver(this);
    feedController.addListener(() {
      if (mounted) {
        handleScrollListeners(feedController);
      }
    });
    clubController.addListener(() {
      if (mounted) {
        handleScrollListeners(clubController);
      }
    });
    spotlightController.addListener(() {
      if (mounted) {
        handleScrollListeners(spotlightController);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton:
            (myUsername.startsWith('Linkspeak')) ? const AdminFAB() : null,
        key: _scaffoldKey,
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Noglow(
                child: PageView(
                  children: const [
                    const Feed(),
                    const FlaresTab(),
                    const NewPost(),
                    const ClubsTab(),
                    const MessagesTab(),
                  ],
                  controller: FeedScreen.pageController,
                  onPageChanged: pageHandler,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
              const TitleButton(),
              const MyAppBar(),
              const ScrollBar(),
              const BottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}
