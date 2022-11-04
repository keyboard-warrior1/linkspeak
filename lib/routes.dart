import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'admin/screens/adminFeeedbackScreen.dart';
import 'admin/screens/allPostsScreen.dart';
import 'admin/screens/allUserClubsScreen.dart';
import 'admin/screens/archiveFindScreen.dart';
import 'admin/screens/archiveItemsScreen.dart';
import 'admin/screens/controlDailyDetails.dart';
import 'admin/screens/controlDailyLoginSearch.dart';
import 'admin/screens/controlDailyLogins.dart';
import 'admin/screens/controlDailyScreen.dart';
import 'admin/screens/controlDayScreen.dart';
import 'admin/screens/findScreen.dart';
import 'admin/screens/generalControlScreen.dart';
import 'admin/screens/generalItemsScreen.dart';
import 'admin/screens/mainAdminScreen.dart';
import 'admin/screens/mainArchiveScreen.dart';
import 'admin/screens/mainControlScreen.dart';
import 'admin/screens/mainProfanityScreen.dart';
import 'admin/screens/newFlaresScreen.dart';
import 'admin/screens/profanityItemsScreen.dart';
import 'admin/screens/userCollectionDocsScreen.dart';
import 'admin/screens/userDailyCollectionsScreen.dart';
import 'admin/screens/userDailyDetailsScreen.dart';
import 'admin/screens/userDailyScreen.dart';
import 'clubs/adminsScreen.dart';
import 'clubs/assignAdminScreen.dart';
import 'clubs/banMemberScreen.dart';
import 'clubs/clubAlertsScreen.dart';
import 'clubs/clubBannedScreen.dart';
import 'clubs/clubCenterScreen.dart';
import 'clubs/clubMemberScreen.dart';
import 'clubs/clubRequestsScreen.dart';
import 'clubs/clubScreen.dart';
import 'clubs/createClubScreen.dart';
import 'clubs/manageClubScreen.dart';
import 'clubs/publishClubPost.dart';
import 'flares/collectionFlareScreen.dart';
import 'flares/customizeFlareScreen.dart';
import 'flares/flareAlertsScreen.dart';
import 'flares/flareCommentAlerts.dart';
import 'flares/flareCommentLikesScreen.dart';
import 'flares/flareCommentRepliesScreen.dart';
import 'flares/flareHistoryScreen.dart';
import 'flares/flareLikeAlerts.dart';
import 'flares/flareProfileScreen.dart';
import 'flares/likedFlareScreen.dart';
import 'flares/newCollectionScreen.dart';
import 'flares/singleFlareScreen.dart';
import 'models/screenArguments.dart';
import 'screens/LinkedNotifScreen.dart';
import 'screens/LinksNotifScreen.dart';
import 'screens/MyprofileScreen.dart';
import 'screens/PostCommentsNotifScreen.dart';
import 'screens/aboutScreen.dart';
import 'screens/additionalDetails.dart';
import 'screens/blockedUserScreen.dart';
import 'screens/chatScreen.dart';
import 'screens/commentLikesScreen.dart';
import 'screens/commentRepliesNotifScreen.dart';
import 'screens/commentRepliesScreen.dart';
import 'screens/customIconScreen.dart';
import 'screens/customLocationScreen.dart';
import 'screens/editProfile.dart';
import 'screens/favoritePostsScreen.dart';
import 'screens/featureDocScreen.dart';
import 'screens/feedScreen.dart';
import 'screens/feedbackScreen.dart';
import 'screens/finishSetup.dart';
import 'screens/fullMapScreen.dart';
import 'screens/helpScreen.dart';
import 'screens/inAppBrowser.dart';
import 'screens/likedPostScreen.dart';
import 'screens/linkModeScreen.dart';
import 'screens/linkRequestsScreen.dart';
import 'screens/linkedToScreen.dart';
import 'screens/linksScreen.dart';
import 'screens/loginScreen.dart';
import 'screens/mediaScreen.dart';
import 'screens/mentionsScreen.dart';
import 'screens/myJoinedClubScreen.dart';
import 'screens/notificationScreen.dart';
import 'screens/notificationSettingsScreen.dart';
import 'screens/otherJoinedClubScreen.dart';
import 'screens/otherProfileScreen.dart';
import 'screens/pickAddressScreen.dart';
import 'screens/pickUsernameScreen.dart';
import 'screens/placePostsScreen.dart';
import 'screens/postLikesNotifScreen.dart';
import 'screens/postScreen.dart';
import 'screens/privacyPolicyScreen.dart';
import 'screens/replyLikesScreen.dart';
import 'screens/scanner.dart';
import 'screens/searchScreen.dart';
import 'screens/settingsScreen.dart';
import 'screens/splashScreen.dart';
import 'screens/termScreen.dart';
import 'screens/themeScreen.dart';
import 'screens/topicPostsScreen.dart';
import 'screens/noteScreen.dart';
import 'screens/commentHistoryScreen.dart';
import 'screens/postCommentHistoryScreen.dart';
import 'screens/flareCommentHistoryScreen.dart';
import 'screens/replyHistoryScreen.dart';
import 'screens/postCommentReplyHistoryScreen.dart';
import 'screens/flareReplyHistoryScreen.dart';

class RouteGenerator {
  static const loginScreen = '/login';
  static const feedScreen = '/feed';
  static const postScreen = '/post';
  static const searchScreen = '/search';
  static const topicPostsScreen = '/topicPosts';
  static const placePostsScreen = '/placePosts';
  static const notificationScreen = '/notification';
  static const myProfileScreen = '/myprofile';
  static const posterProfileScreen = '/posterProfile';
  static const settingsScreen = '/settings';
  static const errorScreen = '/error';
  static const linksScreen = '/links';
  static const linkedToScreen = '/linkedTo';
  static const favPostScreen = '/favPosts';
  static const editProfileScreen = '/editProfile';
  static const additionalInfoScreen = '/additionalInfo';
  static const notificationSettingScreen = '/notificationSettings';
  static const likedPostScreen = '/likedPosts';
  static const termScreen = '/terms';
  static const privacyPolicyScreen = 'privacyPolicy';
  static const linksNotifsScreen = '/linksNotifs';
  static const linkRequestScreen = '/linkRequests';
  static const linkedNotifScreen = '/linkedNotifs';
  static const postLikesNotifScreen = '/postLikes';
  static const mentionsScreen = '/mentions';
  static const postCommentsNotifScreen = '/postComments';
  static const commentRepliesNotifScreen = '/commentRepliesNotifs';
  static const commentLikesScreen = '/commentLikes';
  static const replyLikesScreen = '/replyLikes';
  static const commentRepliesScreen = '/commentReplies';
  static const blockedUserScreen = '/blockedUsers';
  static const aboutScreen = '/about';
  static const feedbackScreen = '/feedback';
  static const helpScreen = '/help';
  static const setupScreen = '/setup';
  static const chatScreen = '/chat';
  static const scannerScreen = '/scanner';
  static const splashScreen = '/splash';
  static const themeScreen = '/themes';
  static const clubCenterScreen = '/clubCenter';
  static const createClubScreen = '/createClub';
  static const clubScreen = '/clubScreen';
  static const addClubPostScreen = '/publishClubPost';
  static const clubAlertScreen = '/clubAlerts';
  static const clubRequestScreen = '/clubRequests';
  static const clubAdminScreen = '/clubAdmins';
  static const assignAdminScreen = '/assignAdmin';
  static const bannedMemberScreen = '/bannedMembers';
  static const banMemberScreen = '/banMember';
  static const clubMembersScreen = '/clubMembers';
  static const manageClubScreen = '/manageClub';
  static const pickUsernameScreen = '/pickUsername';
  static const fullMapScreen = '/fullMap';
  static const profilePickAddress = '/profilePickAddress';
  static const customLocationScreen = '/customLocation';
  static const browser = '/browser';
  static const linkMode = '/linkMode';
  static const customIcon = '/customIcon';
  static const myJoinedClubs = '/myJoinedClubs';
  static const otherJoinedClubs = '/otherJoinedClubs';
  static const mediaScreen = '/mediaScreen';
  static const featureDocs = '/featureDocs';
  static const flareProfileScreen = '/flareProfileScreen';
  static const collectionFlareScreen = '/collectionFlareScreen';
  static const newFlare = '/newFlareScreen';
  static const flareAlerts = '/flareAlerts';
  static const flareHistory = '/flareHistory';
  static const likedFlares = '/likedFlares';
  static const flareCommentReplies = 'flareCommentReplies';
  static const flareCommentLikes = 'flareCommentLikes';
  static const flareLikeAlers = 'flareLikeAlerts';
  static const flareCommentAlerts = 'flareCommentAlerts';
  static const singleFlareScreen = 'singleFlareScreen';
  static const customizeFlareScreen = 'customizeFlareScreen';
  static const mainAdminScreen = '/mainAdmin';
  static const mainArchiveScreen = '/mainArchive';
  static const mainProfanity = '/mainProfanity';
  static const mainControl = '/mainControl';
  static const generalItems = '/generalItems';
  static const generalFind = '/generalFind';
  static const profanityItems = '/profanityItems';
  static const archiveItems = '/archiveItems';
  static const archiveFind = '/archiveFind';
  static const allUserClubs = '/allUserClubs';
  static const allPosts = '/allPosts';
  static const generalControl = '/generalControlDetails';
  static const dailyControl = '/dailyControl';
  static const controlDay = '/controlDay';
  static const controlDailyDetails = '/controlDailyDetails';
  static const controlDailyLogins = '/controlDailyLogins';
  static const controlDailyLoginSearch = '/controlDailyLoginSearch';
  static const userDaily = '/userDaily';
  static const userDailyDetails = '/userDailyDetails';
  static const userDailyCollections = '/userDailyCollections';
  static const userDailyCollectionDocs = '/userDailyCollectionDocs';
  static const adminNewFlares = '/adminNewFlares';
  static const adminFeedbacks = '/adminFeedbacks';
  static const noteScreen = '/noteScreen';
  static const commentHistoryScreen = '/commentHistoryScreen';
  static const postCommentHistoryScreen = '/postCommentHistoryScreen';
  static const flareCommentHistoryScreen = '/flareCommentHistoryScreen';
  static const replyHistoryScreen = '/replyHistoryScreen';
  static const postCommentReplyHistoryScreen = '/postCommentReplyHistoryScreen';
  static const flareCommentReplyHistoryScreen =
      '/flareCommentReplyHistoryScreen';
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    const editProfileScreenIntance = const EditProfileScreen();
    const additionalInfoInstance = const AdditionalInfoScreen();
    const zero = Duration.zero;
    switch (settings.name) {
      case flareProfileScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final FlareProfileScreenArgs fProfileArgs =
            args as FlareProfileScreenArgs;
        return PageTransition(
            type: PageTransitionType.rightToLeft,
            child: FlareProfileScreen(fProfileArgs.userID));
      case newFlare:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const NewFlareCollectionScreen());
      case flareAlerts:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final FlareAlertScreenArgs faArgs = args as FlareAlertScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => FlareAlertScreen(
                username: faArgs.username,
                numOfLikes: faArgs.numOfLikes,
                numOfComments: faArgs.numOfComments,
                zeroNotifs: faArgs.zeroNotifs));
      case flareLikeAlers:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const FlareLikeAlerts());
      case flareCommentAlerts:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const FlareCommentAlerts());
      case collectionFlareScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CollectionFlareScreenArgs cfArgs =
            args as CollectionFlareScreenArgs;
        return PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.center,
            reverseDuration: Duration.zero,
            child: CollectionFlareScreen(
                cfArgs.collections, cfArgs.index, cfArgs.comeFromProfile));
      case singleFlareScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final SingleFlareScreenArgs sfArgs = args as SingleFlareScreenArgs;
        return PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.center,
            reverseDuration: Duration.zero,
            child: SingleFlareScreen(
                flarePoster: sfArgs.flarePoster,
                collectionID: sfArgs.collectionID,
                flareID: sfArgs.flareID,
                isComment: sfArgs.isComment,
                isLike: sfArgs.isLike,
                section: sfArgs.section,
                singleCommentID: sfArgs.singleCommentID));
      case customizeFlareScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CustomizeFlareScreenArgs customizeArgs =
            args as CustomizeFlareScreenArgs;
        return PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.center,
            reverseDuration: Duration.zero,
            child: CustomizeFlareScreen(
                asset: customizeArgs.asset,
                backgroundColor: customizeArgs.backgroundColor,
                gradientColor: customizeArgs.gradientColor,
                saveHandler: customizeArgs.saveHandler));
      case pickUsernameScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final PickNameArgs pickUsername = args as PickNameArgs;
        return PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 100),
            child: PickUsernameScreen(
                pickUsername.emailXid, pickUsername.isGmail));
      case chatScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ChatScreenArgs chatScreenArgs = args as ChatScreenArgs;
        return PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: ChatScreen(
                chatId: chatScreenArgs.chatID,
                comeFromProfile: chatScreenArgs.comeFromProfile));
      case loginScreen:
        return PageTransition(
            type: PageTransitionType.fade, child: const LoginScreen());
      case helpScreen:
        return PageTransition(
            type: PageTransitionType.leftToRight, child: const HelpScreen());
      case fullMapScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final MapScreenArgs mapScreenArgs = args as MapScreenArgs;
        return PageTransition(
            type: PageTransitionType.rightToLeft,
            child: FullScreenMap(
                address: mapScreenArgs.address,
                addressName: mapScreenArgs.addressName));
      case browser:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final BrowserScreenArgs mapScreenArgs = args as BrowserScreenArgs;
        return PageTransition(
            type: PageTransitionType.bottomToTop,
            child: InAppBrowser(mapScreenArgs.url));
      case profilePickAddress:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ProfilePickAddressScreenArgs pickScreenArgs =
            args as ProfilePickAddressScreenArgs;
        return PageTransition(
            type: PageTransitionType.rightToLeft,
            child: PickAddressScreen(
                isInPost: pickScreenArgs.isInPost,
                isInChat: pickScreenArgs.isInChat,
                somethingChanged: pickScreenArgs.somethingChanged,
                changeAddress: pickScreenArgs.changeAddress,
                changeAddressName: pickScreenArgs.changeAddressName,
                changeStateAddressName: pickScreenArgs.changeStateAddressName,
                changePoint: pickScreenArgs.changePoint,
                chatHandler: pickScreenArgs.chatHandler));
      case customLocationScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ProfilePickAddressScreenArgs pickScreenArgs =
            args as ProfilePickAddressScreenArgs;
        return PageTransition(
            type: PageTransitionType.rightToLeft,
            child: CustomLocationScreen(
                isInPost: pickScreenArgs.isInPost,
                isInChat: pickScreenArgs.isInChat,
                somethingChanged: pickScreenArgs.somethingChanged,
                changeAddress: pickScreenArgs.changeAddress,
                changeAddressName: pickScreenArgs.changeAddressName,
                changeStateAddressName: pickScreenArgs.changeStateAddressName,
                changePoint: pickScreenArgs.changePoint,
                chatHandler: pickScreenArgs.chatHandler));
      case scannerScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => Scanner(settings.arguments));
      case customIcon:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const CustomIconScreen());
      case linkMode:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const LinkModeScreen());

      case setupScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const SetupProfileScreen());
      case splashScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const SplashScreen());
      case feedScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const FeedScreen());
      case postScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final PostScreenArguments postArgs = args as PostScreenArguments;
        final Widget _screen = PostScreen(
            instance: postArgs.instance,
            viewMode: postArgs.viewMode,
            previewSetstate: postArgs.previewSetstate,
            isNotif: postArgs.isNotif,
            postID: postArgs.postID,
            clubName: postArgs.clubName,
            section: postArgs.section,
            singleCommentID: postArgs.singleCommentID);
        return PageRouteBuilder(
            transitionDuration: zero, pageBuilder: (_, __, ___) => _screen);
      case commentRepliesScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CommentRepliesScreenArguments commentRepliesScreenArguments =
            args as CommentRepliesScreenArguments;
        return PageTransition(
            reverseDuration: zero,
            type: PageTransitionType.rightToLeft,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 100),
            child: CommentRepliesScreen(
                postID: commentRepliesScreenArguments.postID,
                commentID: commentRepliesScreenArguments.commentID,
                instance: commentRepliesScreenArguments.instance,
                isNotif: commentRepliesScreenArguments.isNotif,
                commenterName: commentRepliesScreenArguments.commenterName,
                clubName: commentRepliesScreenArguments.clubName,
                isClubPost: commentRepliesScreenArguments.isClubPost,
                posterName: commentRepliesScreenArguments.posterName,
                section: commentRepliesScreenArguments.section,
                singleReplyID: commentRepliesScreenArguments.singleReplyID));

      case flareCommentReplies:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final FlareReplyScreenArgs flareCommentRepliesScreenArguments =
            args as FlareReplyScreenArgs;
        return PageTransition(
            reverseDuration: zero,
            type: PageTransitionType.rightToLeft,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 100),
            child: FlareCommentRepliesScreen(
                flarePoster: flareCommentRepliesScreenArguments.flarePoster,
                collectionID: flareCommentRepliesScreenArguments.collectionID,
                flareID: flareCommentRepliesScreenArguments.flareID,
                commentID: flareCommentRepliesScreenArguments.commentID,
                instance: flareCommentRepliesScreenArguments.instance,
                isNotif: flareCommentRepliesScreenArguments.isNotif,
                commenterName: flareCommentRepliesScreenArguments.commenterName,
                section: flareCommentRepliesScreenArguments.section,
                singleReplyID:
                    flareCommentRepliesScreenArguments.singleReplyID));
      case commentLikesScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CommentLikesScreenArgs commentRepliesScreenArguments =
            args as CommentLikesScreenArgs;
        return PageTransition(
            reverseDuration: zero,
            type: PageTransitionType.rightToLeft,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 100),
            child: CommentLikesScreen(
                postID: commentRepliesScreenArguments.postID,
                commentID: commentRepliesScreenArguments.commentID,
                instance: commentRepliesScreenArguments.instance,
                isClubPost: commentRepliesScreenArguments.isClubPost,
                clubName: commentRepliesScreenArguments.clubName));
      case replyLikesScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ReplyLikesScreenArgs commentRepliesScreenArguments =
            args as ReplyLikesScreenArgs;
        return PageTransition(
            reverseDuration: zero,
            type: PageTransitionType.rightToLeft,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 100),
            child: ReplyLikesScreen(
                postID: commentRepliesScreenArguments.postID,
                isInFlare: commentRepliesScreenArguments.isInFlare,
                collectionID: commentRepliesScreenArguments.collectionID,
                flareID: commentRepliesScreenArguments.flareID,
                flarePoster: commentRepliesScreenArguments.flarePoster,
                replyID: commentRepliesScreenArguments.replyID,
                commentID: commentRepliesScreenArguments.commentID,
                isClubPost: commentRepliesScreenArguments.isClubPost,
                clubName: commentRepliesScreenArguments.clubName));
      case flareCommentLikes:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final FlareCommentLikesArgs commentRepliesScreenArguments =
            args as FlareCommentLikesArgs;
        return PageTransition(
            reverseDuration: zero,
            type: PageTransitionType.rightToLeft,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 100),
            child: FlareCommentLikesScreen(
                flarePoster: commentRepliesScreenArguments.flarePoster,
                collectionID: commentRepliesScreenArguments.collectionID,
                flareID: commentRepliesScreenArguments.flareID,
                commentID: commentRepliesScreenArguments.commentID,
                instance: commentRepliesScreenArguments.instance));
      case myProfileScreen:
        return PageTransition(
            type: PageTransitionType.bottomToTop,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 125),
            child: const MyProfileScreen());
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
            transitionDuration: zero,
            pageBuilder: (_, __, ___) {
              final ScreenArguments args =
                  settings.arguments as ScreenArguments;
              final LinkScreenArguments linkScreenArgs =
                  args as LinkScreenArguments;
              return LinksScreen(
                  userID: linkScreenArgs.userID,
                  publicProfile: linkScreenArgs.publicProfile,
                  imLinkedToThem: linkScreenArgs.imLinkedToThem,
                  instance: linkScreenArgs.instance);
            });
      case linkedToScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) {
              final ScreenArguments args =
                  settings.arguments as ScreenArguments;
              final LinkedToScreenArguments linkedToScreenArgs =
                  args as LinkedToScreenArguments;
              return LinkedToScreen(
                  userID: linkedToScreenArgs.userID,
                  publicProfile: linkedToScreenArgs.publicProfile,
                  imLinkedToThem: linkedToScreenArgs.imLinkedToThem,
                  instance: linkedToScreenArgs.instance);
            });
      case noteScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) {
              final ScreenArguments args =
                  settings.arguments as ScreenArguments;
              final NoteScreenArgs noteScreenArgs = args as NoteScreenArgs;
              return NoteScreen(
                  handler: noteScreenArgs.handler,
                  preexistingText: noteScreenArgs.preexistingText,
                  editHandler: noteScreenArgs.editHandler,
                  isBranch: noteScreenArgs.isBranch);
            });
      case myJoinedClubs:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) {
              return const MyJoinedClubs();
            });
      case otherJoinedClubs:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) {
              final ScreenArguments args =
                  settings.arguments as ScreenArguments;
              final OtherJoinedClubsArgs otherClubArgs =
                  args as OtherJoinedClubsArgs;
              return OtherJoinedClubs(otherClubArgs.username);
            });
      case mediaScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final MediaScreenArgs mediaArgs = args as MediaScreenArgs;
        return PageTransition(
            type: PageTransitionType.fade,
            child: MediaScreen(
                mediaUrls: mediaArgs.mediaUrls,
                currentIndex: mediaArgs.currentIndex,
                isInComment: mediaArgs.isInComment));
      case searchScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const SearchTab());
      case topicPostsScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final TopicScreenArgs topicArgs = args as TopicScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => TopicPostsScreen(topicArgs.topicName));
      case placePostsScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final PlaceScreenArgs placeScreenArgs = args as PlaceScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => PlacePostsScreen(
                locationName: placeScreenArgs.locationName,
                location: placeScreenArgs.location,
                placeID: placeScreenArgs.placeID));
      case notificationScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const NotificationScreen());
      case linksNotifsScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const NewLinksScreen());
      case mentionsScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const MentionsScreen());
      case linkRequestScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const LinkRequestsScreen());
      case linkedNotifScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const NewLinkedScreen());
      case postLikesNotifScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const PostLikeNotifScreen());
      case postCommentsNotifScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const PostCommentsNotifScreen());
      case commentRepliesNotifScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const CommentRepliesNotifscreen());
      case settingsScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const Settings());
      case featureDocs:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const FeatureDocs());
      case themeScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const ThemeScreen());
      case favPostScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const FavPostScreen());
      case commentHistoryScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const CommentHistoryScreen());
      case postCommentHistoryScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const PostCommentHistoryScreen());
      case flareCommentHistoryScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const FlareCommentHistoryScreen());
      case replyHistoryScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const ReplyHistoryScreen());
      case postCommentReplyHistoryScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const PostCommentReplyHistoryScreen());
      case flareCommentReplyHistoryScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const FlareReplyHistoryScreen());
      case flareHistory:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const FlareHistoryScreen());
      case likedFlares:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const LikedFlareScreen());
      case editProfileScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => editProfileScreenIntance);
      case additionalInfoScreen:
        return PageTransition(
            type: PageTransitionType.rightToLeftJoined,
            curve: Curves.fastOutSlowIn,
            childCurrent: editProfileScreenIntance,
            child: additionalInfoInstance);
      case blockedUserScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const BlockedUserScreen());
      case clubCenterScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const ClubCenterScreen());
      case createClubScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final CreateClubArgs createClubArgs = args as CreateClubArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) =>
                CreateClubScreen(createClubArgs.addClub));
      case clubScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ClubScreenArgs clubArgs = args as ClubScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => ClubScreen(clubArgs.clubName));
      case addClubPostScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final PublishClubArgs clubArgs = args as PublishClubArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) =>
                PublishClubPost(clubArgs.clubInstance));
      case clubAlertScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ClubAlertArgs clubArgs = args as ClubAlertArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => ClubAlertsScreen(
                clubName: clubArgs.clubName,
                numOfNewMembers: clubArgs.numOfNewMembers,
                numOfRequests: clubArgs.numOfRequests,
                zeroNotifs: clubArgs.zeroNotifs,
                decreaseNotifs: clubArgs.decreaseNotifs,
                addMembers: clubArgs.addMembers));
      case clubRequestScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ClubRequestsArgs clubArgs = args as ClubRequestsArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => ClubRequestScreen(
                clubName: clubArgs.clubName,
                decreaseNotifs: clubArgs.decreaseNotifs,
                addMembers: clubArgs.addMembers));
      case clubAdminScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final AdminScreenArgs clubArgs = args as AdminScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => AdminsScreen(
                clubName: clubArgs.clubName, isFounder: clubArgs.isFounder));
      case assignAdminScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final AssignAdminScreenArgs clubArgs = args as AssignAdminScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => AssignAdminScreen(
                clubName: clubArgs.clubName,
                addAdmin: clubArgs.addAdmin,
                removeAdmin: clubArgs.removeAdmin));
      case bannedMemberScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final BannedMemberScreenArgs clubArgs = args as BannedMemberScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => BannedMemberScreen(clubArgs.clubName));
      case banMemberScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final BanMemberScreenArgs clubArgs = args as BanMemberScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => BanMemberScreen(
                clubName: clubArgs.clubName,
                addBanned: clubArgs.addBanned,
                removeBanned: clubArgs.removeBanned));
      case clubMembersScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ClubMemberScreenArgs clubArgs = args as ClubMemberScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => ClubMemberScreen(clubArgs.clubName));
      case manageClubScreen:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ManageClubScreenArgs clubArgs = args as ManageClubScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => ManageClubScreen(
                clubName: clubArgs.clubName,
                clubAbout: clubArgs.clubAbout,
                clubTopics: clubArgs.clubTopics,
                clubAvatarUrl: clubArgs.clubAvatarUrl,
                instance: clubArgs.instance,
                clubVisibility: clubArgs.clubVisibility,
                membersCanPost: clubArgs.membersCanPost,
                allowQuickJoin: clubArgs.allowQuickJoin,
                isDisabled: clubArgs.isDisabled,
                maxDailyPosts: clubArgs.maxDailyPosts));
      case notificationSettingScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const NotificationSettings());
      case likedPostScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const LikedPostScreen());
      case termScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const TermScreen());
      case privacyPolicyScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const PrivacyPolicyScreen());
      case aboutScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (_, __, ___) => const AboutScreen());
      case feedbackScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const FeedbackScreen());
      case generalFind:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final GeneralFindScreenArgs findArgs = args as GeneralFindScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => FindScreen(findArgs.searchMode));
      case archiveFind:
        final ScreenArguments args = settings.arguments as ScreenArguments;
        final ArchiveFindScreenArgs findArgs = args as ArchiveFindScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) =>
                ArchiveFindScreen(findArgs.searchMode));
      case mainAdminScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const MainAdminScreen());
      case mainArchiveScreen:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const MainArchiveScreen());
      case mainProfanity:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const MainProfanityScreen());
      case mainControl:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const MainControlScreen());
      case generalItems:
        var args = settings.arguments as ScreenArguments;
        final GeneralItemScreenArgs generalItemArgs =
            args as GeneralItemScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => GeneralItemsScreen(
                numOfTabs: generalItemArgs.numOfTabs,
                isProfiles: generalItemArgs.isProfiles,
                isClubs: generalItemArgs.isClubs,
                isPosts: generalItemArgs.isPosts,
                isPostComments: generalItemArgs.isPostComments,
                isPostCommentReplies: generalItemArgs.isPostCommentReplies,
                isFlares: generalItemArgs.isFlares,
                isFlareComments: generalItemArgs.isFlareComments,
                isFlareCommentReplies: generalItemArgs.isFlareCommentReplies,
                showReports: generalItemArgs.showReports,
                showWatchList: generalItemArgs.showWatchList,
                showBanned: generalItemArgs.showBanned,
                showProhibited: generalItemArgs.showProhibited,
                showReviewals: generalItemArgs.showReviewals,
                showFab: generalItemArgs.showFab,
                findMode: generalItemArgs.findMode));
      case profanityItems:
        var args = settings.arguments as ScreenArguments;
        final ProfanityItemScreenArgs profanityArgs =
            args as ProfanityItemScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => ProfanityItemsScreen(
                isProfileBio: profanityArgs.isProfileBio,
                isClubAbout: profanityArgs.isClubAbout,
                isFlareProfileBio: profanityArgs.isFlareProfileBio,
                isPostDescription: profanityArgs.isPostDescription,
                isPostComments: profanityArgs.isPostComments,
                isPostCommentReplies: profanityArgs.isPostCommentReplies,
                isFlareComments: profanityArgs.isFlareComments,
                isFlareCommentReplies: profanityArgs.isFlareCommentReplies));
      case archiveItems:
        var args = settings.arguments as ScreenArguments;
        final ArchiveItemScreenArgs archiveArgs = args as ArchiveItemScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => ArchiveItemsScreen(
                deletedPosts: archiveArgs.deletedPosts,
                deletedComments: archiveArgs.deletedComments,
                deletedReplies: archiveArgs.deletedReplies,
                deletedUsers: archiveArgs.deletedUsers,
                deletedFlareProfiles: archiveArgs.deletedFlareProfiles,
                deletedFlares: archiveArgs.deletedFlares,
                unbannedUsers: archiveArgs.unbannedUsers,
                unprohibitedClubs: archiveArgs.unprohibitedClubs,
                disabledClubs: archiveArgs.disabledClubs,
                showFinder: archiveArgs.showFinder,
                findMode: archiveArgs.findMode));
      case allUserClubs:
        var args = settings.arguments as ScreenArguments;
        final AdminUserClubScreenArgs userClubArgs =
            args as AdminUserClubScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) =>
                AllUserClubScreen(userClubArgs.isUser));
      case allPosts:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const AllPostsScreen());
      case generalControl:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const GeneralControlScreen());
      case dailyControl:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const ControlDailyScreen());
      case controlDay:
        var args = settings.arguments as ScreenArguments;
        final ControlDayScreenArgs controlDayArgs =
            args as ControlDayScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) =>
                ControlDayScreen(controlDayArgs.dayID));
      case controlDailyDetails:
        var args = settings.arguments as ScreenArguments;
        final ControlDailyDetailsScreenArgs dailyDetailsArgs =
            args as ControlDailyDetailsScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => ControlDailyDetailsScreen(
                dailyDetailsArgs.details, dailyDetailsArgs.dayID));
      case controlDailyLogins:
        var args = settings.arguments as ScreenArguments;
        final ControlDailyLoginsArgs dailyLoginArgs =
            args as ControlDailyLoginsArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => ControlDailyLogins(
                dailyLoginArgs.dayID,
                dailyLoginArgs.logins,
                dailyLoginArgs.allLogins));
      case controlDailyLoginSearch:
        var args = settings.arguments as ScreenArguments;
        final ControlDailyLoginSearchArgs dailyLoginSearchArgs =
            args as ControlDailyLoginSearchArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => ControlDailyLoginSearch(
                dailyLoginSearchArgs.dayID, dailyLoginSearchArgs.allLogins));
      case userDaily:
        var args = settings.arguments as ScreenArguments;
        final UserDailyScreenArgs userDailyArgs = args as UserDailyScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) =>
                UserDailyScreen(userDailyArgs.dayID, userDailyArgs.userID));
      case userDailyDetails:
        var args = settings.arguments as ScreenArguments;
        final UserDailyDetailsArgs userDailyDetailArgs =
            args as UserDailyDetailsArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => UserDailyDetailsScreen(
                userDailyDetailArgs.userID,
                userDailyDetailArgs.details,
                userDailyDetailArgs.dayID));
      case userDailyCollections:
        var args = settings.arguments as ScreenArguments;
        final UserDailyCollectionScreenArgs userDailyCollectionArgs =
            args as UserDailyCollectionScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => UserDailyCollectionScreen(
                userDailyCollectionArgs.dayID, userDailyCollectionArgs.userID));
      case userDailyCollectionDocs:
        var args = settings.arguments as ScreenArguments;
        final UserDailyCollectionDocScreenArgs userDailyCollectionDocArgs =
            args as UserDailyCollectionDocScreenArgs;
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => UserDailyCollectionDocsScreen(
                userDailyCollectionDocArgs.dayID,
                userDailyCollectionDocArgs.userID,
                userDailyCollectionDocArgs.collectionID,
                userDailyCollectionDocArgs.docs));
      case adminNewFlares:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const NewFlareScreen());
      case adminFeedbacks:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const AdminFeedbackScreen());
      default:
        return PageRouteBuilder(
            transitionDuration: zero,
            pageBuilder: (ctx, dbl, _) => const FeedScreen());
    }
  }
}
