import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'models/screenArguments.dart';
import 'screens/scanner.dart';
import 'screens/themeScreen.dart';
import 'screens/loginScreen.dart';
import 'screens/feedScreen.dart';
import 'screens/postScreen.dart';
import 'screens/searchScreen.dart';
import 'screens/topicPostsScreen.dart';
import 'screens/notificationScreen.dart';
import 'screens/MyprofileScreen.dart';
import 'screens/otherProfileScreen.dart';
import 'screens/settingsScreen.dart';
import 'screens/linksScreen.dart';
import 'screens/linkedToScreen.dart';
import 'screens/favoritePostsScreen.dart';
import 'screens/editProfile.dart';
import 'screens/likedPostScreen.dart';
import 'screens/notificationSettingsScreen.dart';
import 'screens/termScreen.dart';
import 'screens/privacyPolicyScreen.dart';
import 'screens/LinksNotifScreen.dart';
import 'screens/linkRequestsScreen.dart';
import 'screens/LinkedNotifScreen.dart';
import 'screens/postLikesNotifScreen.dart';
import 'screens/PostCommentsNotifScreen.dart';
import 'screens/commentRepliesNotifScreen.dart';
import 'screens/commentRepliesScreen.dart';
import 'screens/blockedUserScreen.dart';
import 'screens/aboutScreen.dart';
import 'screens/helpScreen.dart';
import 'screens/chatScreen.dart';
import 'screens/finishSetup.dart';
import 'screens/splashScreen.dart';
import 'screens/pickUsernameScreen.dart';
import 'screens/commentLikesScreen.dart';
import 'screens/findPostScreen.dart';

class RouteGenerator {
  static const loginScreen = '/login';
  static const feedScreen = '/feed';
  static const postScreen = '/post';
  static const searchScreen = '/search';
  static const topicPostsScreen = '/topicPosts';
  static const notificationScreen = '/notification';
  static const myProfileScreen = '/myprofile';
  static const posterProfileScreen = '/posterProfile';
  static const settingsScreen = '/settings';
  static const errorScreen = '/error';
  static const linksScreen = '/links';
  static const linkedToScreen = '/linkedTo';
  static const favPostScreen = '/favPosts';
  static const editProfileScreen = '/editProfile';
  static const notificationSettingScreen = '/notificationSettings';
  static const likedPostScreen = '/likedPosts';
  static const termScreen = '/terms';
  static const privacyPolicyScreen = 'privacyPolicy';
  static const linksNotifsScreen = '/linksNotifs';
  static const linkRequestScreen = '/linkRequests';
  static const linkedNotifScreen = '/linkedNotifs';
  static const postLikesNotifScreen = '/postLikes';
  static const postCommentsNotifScreen = '/postComments';
  static const commentRepliesNotifScreen = '/commentRepliesNotifs';
  static const commentLikesScreen = '/commentLikes';
  static const commentRepliesScreen = '/commentReplies';
  static const blockedUserScreen = '/blockedUsers';
  static const aboutScreen = '/about';
  static const helpScreen = '/help';
  static const setupScreen = '/setup';
  static const chatScreen = '/chat';
  static const scannerScreen = '/scanner';
  static const splashScreen = '/splash';
  static const themeScreen = '/themes';
  static const pickUsernameScreen = '/pickUsername';
  static const findPostScreen = '/findPost';
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case pickUsernameScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final PickNameArgs pickUsername = args as PickNameArgs;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 100),
          child:
              PickUsernameScreen(pickUsername.emailXid, pickUsername.isGmail),
        );
      case chatScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ChatScreenArgs chatScreenArgs = args as ChatScreenArgs;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 100),
          child: ChatScreen(
            chatId: chatScreenArgs.chatID,
            comeFromProfile: chatScreenArgs.comeFromProfile,
          ),
        );
      case loginScreen:
        return PageTransition(
          type: PageTransitionType.fade,
          child: const LoginScreen(),
        );
      case helpScreen:
        return PageTransition(
          type: PageTransitionType.leftToRight,
          child: const HelpScreen(),
        );
      case scannerScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 0),
          pageBuilder: (ctx, dbl, _) => const Scanner(),
        );
      case findPostScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 0),
          pageBuilder: (ctx, dbl, _) => const FindPostScreen(),
        );
      case setupScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 0),
          pageBuilder: (ctx, dbl, _) => const SetupProfileScreen(),
        );
      case splashScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 0),
          pageBuilder: (ctx, dbl, _) => const SplashScreen(),
        );
      case feedScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 0),
          pageBuilder: (ctx, dbl, _) => const FeedScreen(),
        );
      case postScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final PostScreenArguments postArgs = args as PostScreenArguments;
        final Widget _screen = PostScreen(
          instance: postArgs.instance,
          viewMode: postArgs.viewMode,
          previewSetstate: postArgs.previewSetstate,
          isNotif: postArgs.isNotif,
          postID: postArgs.postID,
        );
        return PageRouteBuilder(
          transitionDuration: const Duration(seconds: 0),
          pageBuilder: (_, __, ___) => _screen,
        );

      case commentRepliesScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CommentRepliesScreenArguments commentRepliesScreenArguments =
            args as CommentRepliesScreenArguments;
        return PageTransition(
          reverseDuration: const Duration(milliseconds: 0),
          type: PageTransitionType.rightToLeft,
          curve: Curves.linear,
          duration: const Duration(milliseconds: 100),
          child: CommentRepliesScreen(
            postID: commentRepliesScreenArguments.postID,
            commentID: commentRepliesScreenArguments.commentID,
            instance: commentRepliesScreenArguments.instance,
            isNotif: commentRepliesScreenArguments.isNotif,
          ),
        );
      case commentLikesScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CommentLikesScreenArgs commentRepliesScreenArguments =
            args as CommentLikesScreenArgs;
        return PageTransition(
          reverseDuration: const Duration(milliseconds: 0),
          type: PageTransitionType.rightToLeft,
          curve: Curves.linear,
          duration: const Duration(milliseconds: 100),
          child: CommentLikesScreen(
            postID: commentRepliesScreenArguments.postID,
            commentID: commentRepliesScreenArguments.commentID,
            instance: commentRepliesScreenArguments.instance,
          ),
        );
      case myProfileScreen:
        return PageTransition(
          type: PageTransitionType.bottomToTop,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 125),
          child: const MyProfileScreen(),
        );
      case posterProfileScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final OtherProfileScreenArguments otherProfileArgs =
            args as OtherProfileScreenArguments;
        final Widget _screen =
            OtherProfileScreen(userID: otherProfileArgs.otherProfileId);
        return PageTransition(
            duration: const Duration(milliseconds: 125),
            type: PageTransitionType.bottomToTop,
            curve: Curves.fastOutSlowIn,
            child: _screen);
      case linksScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) {
            final ScreenArguments args = settings.arguments as ScreenArguments;
            final LinkScreenArguments linkScreenArgs =
                args as LinkScreenArguments;
            return LinksScreen(
              userID: linkScreenArgs.userID,
              publicProfile: linkScreenArgs.publicProfile,
              imLinkedToThem: linkScreenArgs.imLinkedToThem,
              instance: linkScreenArgs.instance,
            );
          },
        );
      case linkedToScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) {
            final ScreenArguments args = settings.arguments as ScreenArguments;
            final LinkedToScreenArguments linkedToScreenArgs =
                args as LinkedToScreenArguments;
            return LinkedToScreen(
              userID: linkedToScreenArgs.userID,
              publicProfile: linkedToScreenArgs.publicProfile,
              imLinkedToThem: linkedToScreenArgs.imLinkedToThem,
              instance: linkedToScreenArgs.instance,
            );
          },
        );
      case searchScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const SearchTab(),
        );
      case topicPostsScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final TopicScreenArgs topicArgs = args as TopicScreenArgs;
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => TopicPostsScreen(topicArgs.topicName),
        );
      case notificationScreen:
        return PageTransition(
          duration: const Duration(milliseconds: 150),
          type: PageTransitionType.topToBottom,
          child: const NotificationScreen(),
        );

      case linksNotifsScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const NewLinksScreen(),
        );
      case linkRequestScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const LinkRequestsScreen(),
        );
      case linkedNotifScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const NewLinkedScreen(),
        );
      case postLikesNotifScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const PostLikeNotifScreen(),
        );
      case postCommentsNotifScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const PostCommentsNotifScreen(),
        );
      case commentRepliesNotifScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const CommentRepliesNotifscreen(),
        );
      case settingsScreen:
        return PageTransition(
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.fastOutSlowIn,
          childCurrent: const MyProfileScreen(),
          child: const Settings(),
        );
      case themeScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const ThemeScreen(),
        );
      case favPostScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const FavPostScreen(),
        );
      case editProfileScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const EditProfileScreen(),
        );
      case blockedUserScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const BlockedUserScreen(),
        );
      case notificationSettingScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const NotificationSettings(),
        );
      case likedPostScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const LikedPostScreen(),
        );
      case termScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const TermScreen(),
        );
      case privacyPolicyScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const PrivacyPolicyScreen(),
        );
      case aboutScreen:
        return PageRouteBuilder(
          transitionDuration: const Duration(
            seconds: 0,
          ),
          pageBuilder: (_, __, ___) => const AboutScreen(),
        );
      default:
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 0),
          pageBuilder: (ctx, dbl, _) => const FeedScreen(),
        );
    }
  }
}
