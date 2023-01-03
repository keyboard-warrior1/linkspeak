// import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Locales/appLanguage.dart';
import 'admin/generalAdmin.dart';
import 'models/chromeSafariModel.dart';
import 'models/profile.dart';
import 'providers/clubProvider.dart';
import 'providers/fullPostHelper.dart';
import 'providers/myProfileProvider.dart';
import 'providers/themeModel.dart';

enum Sortation { top, newest, mine }

enum Section { single, multiple }

class General {
  static final browser = MyChromeSafariBrowser();
  static String currentSessionID = '';
  static void generateSessionID() =>
      currentSessionID = DateTime.now().toString();
  static void changeSortation(Sortation oldSort, Sortation newSort) =>
      oldSort = newSort;
  static void changeSection(Section oldSection, Section newSection) =>
      oldSection = newSection;
  static Widget constrain(Widget child) => ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 25, maxHeight: 25, minWidth: 25, maxWidth: 25),
      child: Center(
          child:
              FittedBox(fit: BoxFit.scaleDown, child: Center(child: child))));
  static PostType generatePostType(String type) {
    if (type == 'legacy') {
      return PostType.legacy;
    } else if (type == 'board') {
      return PostType.board;
    } else if (type == 'branch') {
      return PostType.branch;
    }
    return PostType.legacy;
  }

  static String generateIDprefix(
      {required bool isPost,
      required bool isClubPost,
      required bool isCollection,
      required bool isFlare,
      required bool isComment,
      required bool isReply,
      required bool isFlareComment,
      required bool isFlareReply}) {
    if (isPost) return '(post)';
    if (isClubPost) return '(club post)';
    if (isCollection) return '(collection)';
    if (isFlare) return '(flare)';
    if (isComment) return '(comment)';
    if (isReply) return '(reply)';
    if (isFlareComment) return '(Fcomment)';
    if (isFlareReply) return '(Freply)';
    return '';
  }

  static String generateContentID(
      {required String username,
      required String clubName,
      required bool isPost,
      required bool isClubPost,
      required bool isCollection,
      required bool isFlare,
      required bool isComment,
      required bool isReply,
      required bool isFlareComment,
      required bool isFlareReply}) {
    final String prefix = generateIDprefix(
        isPost: isPost,
        isClubPost: isClubPost,
        isCollection: isCollection,
        isFlare: isFlare,
        isComment: isComment,
        isReply: isReply,
        isFlareComment: isFlareComment,
        isFlareReply: isFlareReply);
    final DateTime _rightNowUTC = DateTime.now().toUtc();
    final String _postDate = '${DateFormat('dMyHmsS').format(_rightNowUTC)}';
    final String _theID = isClubPost
        ? '$prefix$clubName-$username-$_postDate'
        : '$prefix$username-$_postDate';
    return _theID;
  }

  static String todaysDate() => DateFormat('d-M-y').format(DateTime.now());
  static String generateProfileVis(TheVisibility vis) {
    if (vis == TheVisibility.public) {
      return 'Public';
    } else if (vis == TheVisibility.private) {
      return 'Private';
    }
    return '';
  }

  static TheVisibility convertProfileVis(String vis) {
    if (vis == 'Public') {
      return TheVisibility.public;
    } else if (vis == 'Private') {
      return TheVisibility.private;
    }
    return TheVisibility.private;
  }

  static ClubVisibility convertClubVis(String vis) {
    if (vis == 'Public') {
      return ClubVisibility.public;
    } else if (vis == 'Private') {
      return ClubVisibility.private;
    } else if (vis == 'Hidden') {
      return ClubVisibility.hidden;
    }
    return ClubVisibility.private;
  }

  static String generateClubVis(ClubVisibility vis) {
    if (vis == ClubVisibility.public) {
      return 'Public';
    } else if (vis == ClubVisibility.private) {
      return 'Private';
    } else if (vis == ClubVisibility.hidden) {
      return 'Hidden';
    }
    return '';
  }

  static String topicNumber(num value) {
    if (value >= 99)
      return '99+';
    else
      return value.toString();
  }

  static String optimisedNumbers(num value) {
    if (value < 1000) {
      return '${value.toString()}';
    } else if (value >= 1000 && value < 1000000) {
      num dividedVal = value / 1000;
      return '${dividedVal.toStringAsFixed(0)}K';
    } else if (value >= 1000000 && value < 1000000000) {
      num dividedVal = value / 1000000;
      return '${dividedVal.toStringAsFixed(0)}M';
    } else if (value >= 1000000000) {
      num dividedVal = value / 1000000000;
      return '${dividedVal.toStringAsFixed(0)}B';
    }
    return 'null';
  }

  static String timeStamp(
      DateTime postedDate, String locale, BuildContext context) {
    final lang = General.language(context);
    final String _datewithYear =
        DateFormat('MMMM d yyyy', locale).format(postedDate);
    final String _dateNoYear = DateFormat('MMMM d', locale).format(postedDate);
    final Duration _difference = DateTime.now().difference(postedDate);
    final bool _withinMinute =
        _difference <= const Duration(seconds: 59, milliseconds: 999);
    final bool _withinHour = _difference <=
        const Duration(minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinDay = _difference <=
        const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999);
    final bool _withinYear = _difference <=
        const Duration(days: 364, minutes: 59, seconds: 59, milliseconds: 999);

    if (_withinMinute) {
      return lang.general_stamp1;
    } else if (_withinHour && _difference.inMinutes > 1) {
      return '~ ${_difference.inMinutes} ${lang.general_stamp2}';
    } else if (_withinHour && _difference.inMinutes == 1) {
      return '~ ${_difference.inMinutes} ${lang.general_stamp3}';
    } else if (_withinDay && _difference.inHours > 1) {
      return '~ ${_difference.inHours} ${lang.general_stamp4}';
    } else if (_withinDay && _difference.inHours == 1) {
      return '~ ${_difference.inHours} ${lang.general_stamp5}';
    } else if (!_withinMinute && !_withinHour && !_withinDay && _withinYear) {
      return '$_dateNoYear';
    } else {
      return '$_datewithYear';
    }
  }

  static String interpretField(dynamic field) {
    late String returner;
    var fieldType = field.runtimeType.toString();
    if (fieldType == 'Timestamp') {
      var fieldDate = field.toDate();
      var fieldString = fieldDate.toString();
      returner = fieldString;
    } else if (fieldType == 'GeoPoint') {
      var fieldLat = field.latitude;
      var fieldLng = field.longitude;
      returner = 'LAT:$fieldLat LNG:$fieldLng';
    } else {
      returner = field.toString();
    }
    return returner;
  }

  static String getDocData(DocumentSnapshot<Map<String, dynamic>> doc) {
    String dataString = '''''';
    final Map<String, dynamic> idKey = {'identifier': doc.id};
    Map<String, dynamic>? data = doc.data();
    data!.addAll(idKey);
    data.forEach((key, value) {
      var valueString = interpretField(value);
      var currentString = '''
>$key: $valueString
''';
      var newString = dataString + currentString;
      dataString = newString;
    });
    return dataString;
  }

  static String giveShareMessage(bool isFlare, String langCode) {
    if (langCode == 'en') {
      if (isFlare) {
        return 'shared a flare';
      } else {
        return 'shared a post';
      }
    } else if (langCode == 'ar') {
      if (isFlare) {
        return 'مشاركة فلير';
      } else {
        return 'مشاركة منشور';
      }
    } else {
      return '';
    }
  }

  static String returnLocalMessage(
      {required String langCode,
      required String englishPhrase,
      required String arabicPhrase,
      required String turkishPhrase}) {
    if (langCode == 'en') {
      return englishPhrase;
    } else if (langCode == 'ar') {
      return arabicPhrase;
    } else if (langCode == 'tr') {
      return turkishPhrase;
    } else {
      return '';
    }
  }

  static String giveDeletedDisplayMessage(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'This message has been deleted',
        arabicPhrase: ' تم محو هذه الرسالة',
        turkishPhrase: 'Bu mesaj silindi');
  }

  static String giveMentionBio(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'mentioned you in their bio',
        arabicPhrase: 'ذكرك في ملخّص',
        turkishPhrase: 'Açıklamasında senden bahsetti');
  }

  static String giveMentionReply(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'mentioned you in their reply',
        arabicPhrase: 'ذكرك في رد',
        turkishPhrase: 'yanıtında senden bahsetti');
  }

  static String giveMentionComment(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'mentioned you in their comment',
        arabicPhrase: 'ذكرك في تعليق',
        turkishPhrase: 'yorumunda senden bahsetti');
  }

  static String giveMentionPost(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'mentioned you in their post',
        arabicPhrase: 'ذكرك في منشور',
        turkishPhrase: 'paylaşımında senden bahsetti');
  }

  static String giveAudioMessage(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'sent an audio',
        arabicPhrase: 'مشاركة مقطع صوت',
        turkishPhrase: 'bir ses paylaşıldı');
  }

  static String giveMediaMessage(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'shared media',
        arabicPhrase: 'مشاركة مقطع',
        turkishPhrase: 'medya paylaşıldı');
  }

  static String giveLocationMessage(String langCode) {
    return General.returnLocalMessage(
        langCode: langCode,
        englishPhrase: 'shared a location',
        arabicPhrase: 'مشاركة موقع',
        turkishPhrase: 'konum paylaşıldı');
  }

  static double widthQuery(BuildContext context) {
    bool condition =
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width >
            800;
    if (kIsWeb && condition) {
      return 475.0;
    } else if (condition) {
      return 475.0;
    } else {
      return MediaQuery.of(context).size.width;
    }
  }

  static AppLanguage language(BuildContext context) =>
      Provider.of<ThemeModel>(context, listen: false).appLanguage;
  static void initializeLogin(
      {required DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      required Color themePrimaryColor,
      required Color themeAccentColor,
      required Color themeLikeColor,
      required dynamic setPrimary,
      required dynamic setAccent,
      required dynamic setLikeColor,
      required BuildContext context,
      required bool spotlightExists}) {
    dynamic getter(String field) => documentSnapshot.get(field);
    final MyProfile profile = Provider.of<MyProfile>(context, listen: false);
    final visbility = getter('Visibility');
    String bannerUrl = 'None';
    bool bannerNSFW = false;
    if (documentSnapshot.data()!.containsKey('Banner')) {
      final currentBanner = getter('Banner');
      final currentNSFW = getter('bannerNSFW');
      bannerUrl = currentBanner;
      bannerNSFW = currentNSFW;
    }
    String additionalWebsite = '';
    String additionalEmail = '';
    String additionalNumber = '';
    dynamic additionalAddress = '';
    String additionalAddressName = '';
    Color myPrimaryColor = themePrimaryColor;
    Color myAccentColor = themeAccentColor;
    Color myLikeColor = themeLikeColor;
    if (documentSnapshot.data()!.containsKey('PrimaryColor')) {
      final actualPrimary = getter('PrimaryColor');
      myPrimaryColor = Color(actualPrimary);
      if (themePrimaryColor != myPrimaryColor) setPrimary(myPrimaryColor);
    }
    if (documentSnapshot.data()!.containsKey('AccentColor')) {
      final actualAccent = getter('AccentColor');
      myAccentColor = Color(actualAccent);
      if (themeAccentColor != myAccentColor) setAccent(myAccentColor);
    }
    if (documentSnapshot.data()!.containsKey('LikeColor')) {
      final actualLikeColor = getter('LikeColor');
      myLikeColor = Color(actualLikeColor);
      if (themeLikeColor != myLikeColor) setLikeColor(myLikeColor);
    }
    if (documentSnapshot.data()!.containsKey('additionalWebsite')) {
      final actualWebsite = getter('additionalWebsite');
      additionalWebsite = actualWebsite;
    }
    if (documentSnapshot.data()!.containsKey('additionalEmail')) {
      final actualEmail = getter('additionalEmail');
      additionalEmail = actualEmail;
    }
    if (documentSnapshot.data()!.containsKey('additionalNumber')) {
      final actualNumber = getter('additionalNumber');
      additionalNumber = actualNumber;
    }
    if (documentSnapshot.data()!.containsKey('additionalAddress')) {
      final actualAddress = getter('additionalAddress');
      additionalAddress = actualAddress;
    }
    if (documentSnapshot.data()!.containsKey('additionalAddressName')) {
      final actualAddressName = getter('additionalAddressName');
      additionalAddressName = actualAddressName;
    }
    final username = getter('Username');
    final email = getter('Email');
    final imgUrl = getter('Avatar');
    final bio = getter('Bio');
    final serverTopics = getter('Topics') as List;
    final int numOfLinks = getter('numOfLinks');
    final int numOfLinked = getter('numOfLinked');
    final int numOfPosts = getter('numOfPosts');
    final int numOfNewLinksNotifs = getter('numOfNewLinksNotifs');
    final int numOfNewLinkedNotifs = getter('numOfNewLinkedNotifs');
    final int numOfLinkRequestsNotifs = getter('numOfLinkRequestsNotifs');
    final int numOfPostLikesNotifs = getter('numOfPostLikesNotifs');
    final int numOfPostCommentsNotifs = getter('numOfPostCommentsNotifs');
    final int numOfCommentRepliesNotifs = getter('numOfCommentRepliesNotifs');
    final int numOfPostsRemoved = getter('PostsRemoved');
    final int numOfCommentsRemoved = getter('CommentsRemoved');
    final int numOfRepliesRemoved = getter('repliesRemoved');
    final int numOfBlocked = getter('numOfBlocked');
    final int joinedClubs = getter('joinedClubs');
    final int numOfMentions = getter('numOfMentions');
    final List<String> myTopics =
        serverTopics.map((topic) => topic as String).toList();
    profile.initializeMyProfile(
        joinedClubs: joinedClubs,
        visbility: visbility,
        additionalWebsite: additionalWebsite,
        additionalEmail: additionalEmail,
        additionalNumber: additionalNumber,
        additionalAddress: additionalAddress,
        additionalAddressName: additionalAddressName,
        hasSpotlight: spotlightExists,
        imgUrl: imgUrl,
        bannerUrl: bannerUrl,
        bannerNSFW: bannerNSFW,
        email: email,
        username: username,
        bio: bio,
        myTopics: myTopics,
        numOfLinks: numOfLinks,
        numOfLinked: numOfLinked,
        numOfPosts: numOfPosts,
        numOfMentions: numOfMentions,
        numOfNewLinksNotifs: numOfNewLinksNotifs,
        numOfNewLinkedNotifs: numOfNewLinkedNotifs,
        numOfLinkRequestsNotifs: numOfLinkRequestsNotifs,
        numOfPostLikesNotifs: numOfPostLikesNotifs,
        numOfPostCommentsNotifs: numOfPostCommentsNotifs,
        numOfCommentRepliesNotifs: numOfCommentRepliesNotifs,
        numOfPostsRemoved: numOfPostsRemoved,
        numOfCommentsRemoved: numOfCommentsRemoved,
        numOfRepliesRemoved: numOfRepliesRemoved,
        numOfBlocked: numOfBlocked);
  }

  static Future<void> addUsers() async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final date = todaysDate();
    final options = SetOptions(merge: true);
    final generalControl = firestore.doc('Control/Details');
    final todaysDetails = firestore.doc('Control/Days/$date/Details');
    final addUsers = {'users': FieldValue.increment(1)};
    batch.set(generalControl, addUsers, options);
    batch.set(todaysDetails, addUsers, options);
    return batch.commit();
  }

  static Future<void> addDailyDeleted() async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final date = todaysDate();
    final options = SetOptions(merge: true);
    final todaysDetails = firestore.doc('Control/Days/$date/Details');
    batch.set(todaysDetails, {'deleted': FieldValue.increment(1)}, options);
    return batch.commit();
  }

  static Future<void> addDailyOnline() async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final date = todaysDate();
    final options = SetOptions(merge: true);
    final todaysDetails = firestore.doc('Control/Days/$date/Details');
    batch.set(todaysDetails, {'online': FieldValue.increment(1)}, options);
    return batch.commit();
  }

  static Future<void> subtractDailyOnline() async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final date = todaysDate();
    final options = SetOptions(merge: true);
    final todaysDetails = firestore.doc('Control/Days/$date/Details');
    batch.set(todaysDetails, {'online': FieldValue.increment(-1)}, options);
    return batch.commit();
  }

  static Future<void> login(String myUsername) async {
    generateSessionID();
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final today = DateTime.now();
    final date = todaysDate();
    final options = SetOptions(merge: true);
    String _ipAddress = await Ipify.ipv4();
    final todaysProfileLoginDoc =
        firestore.doc('Users/$myUsername/Logins/$date');
    final generalControl = firestore.doc('Control/Details');
    final todaysDetails = firestore.doc('Control/Days/$date/Details');
    final todaysProfileSessions = firestore
        .doc('Users/$myUsername/Logins/$date/Sessions/$currentSessionID');
    final getProfileLogin = await todaysProfileLoginDoc.get();
    final profileExists = getProfileLogin.exists;
    final todaysControlLogin =
        firestore.doc('Control/Days/$date/Details/Logins/$myUsername');
    final getLogin = await todaysControlLogin.get();
    final loginExists = getLogin.exists;
    final todaysControlLoginSesh = firestore.doc(
        'Control/Days/$date/Details/Logins/$myUsername/Sessions/$currentSessionID');
    final incrementLogins = {'x': FieldValue.increment(1)};
    final addTotalLogins = {'total logins': FieldValue.increment(1)};
    final startingData = {'begin': today, 'firstIP': _ipAddress};
    final data = {'start': today, 'startIP': _ipAddress};
    if (!loginExists)
      batch.set(todaysControlLogin, startingData, options);
    else
      batch.set(todaysControlLogin, incrementLogins, options);
    if (!profileExists)
      batch.set(todaysProfileLoginDoc, startingData, options);
    else
      batch.set(todaysProfileLoginDoc, incrementLogins, options);
    batch.set(todaysControlLoginSesh, data, options);
    batch.set(todaysProfileSessions, data, options);
    batch.set(generalControl, addTotalLogins, options);
    batch.set(todaysDetails, addTotalLogins, options);
    return batch.commit();
  }

  static Future<void> logout(String myUsername) async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final today = DateTime.now();
    final date = todaysDate();
    final options = SetOptions(merge: true);
    String _ipAddress = await Ipify.ipv4();
    final todaysProfileLoginDoc =
        firestore.doc('Users/$myUsername/Logins/$date');
    final todaysProfileSessions = firestore
        .doc('Users/$myUsername/Logins/$date/Sessions/$currentSessionID');
    final todaysControlLogin =
        firestore.doc('Control/Days/$date/Details/Logins/$myUsername');
    final todaysControlLoginSesh = firestore.doc(
        'Control/Days/$date/Details/Logins/$myUsername/Sessions/$currentSessionID');
    final endingData = {'end': today, 'lastIP': _ipAddress};
    final data = {'end': today, 'logoutIP': _ipAddress};
    batch.set(todaysControlLogin, endingData, options);
    batch.set(todaysProfileLoginDoc, endingData, options);
    batch.set(todaysControlLoginSesh, data, options);
    batch.set(todaysProfileSessions, data, options);
    return batch.commit();
  }

  static Future<void>? openBrowser(
      String url, Color primaryColor, Color accentColor) {
    if (kIsWeb) {
      // html.window.open(url, "_blank");
    } else {
      return browser.open(
          url: Uri.parse(url),
          options: ChromeSafariBrowserClassOptions(
              android: AndroidChromeCustomTabsOptions(
                  toolbarBackgroundColor: primaryColor,
                  shareState: CustomTabsShareState.SHARE_STATE_OFF),
              ios: IOSSafariOptions(
                  barCollapsingEnabled: true,
                  preferredBarTintColor: primaryColor,
                  preferredControlTintColor: accentColor)));
    }
    return null;
  }

  static Future<void> copyDetails(String details) async {
    final data = ClipboardData(text: details);
    await Clipboard.setData(data);
    EasyLoading.show(
        status: 'Copied',
        dismissOnTap: true,
        indicator: const Icon(Icons.copy, color: Colors.white));
  }

  static Future<void> getAndCopyDetails(
      String docPath, bool toCopy, BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final item = await firestore.doc(docPath).get();
    final dataString = getDocData(item);
    if (toCopy)
      return General.copyDetails(dataString);
    else
      return GeneralAdmin.displayDocDetails(
          context: context,
          doc: item,
          actionLabel: '',
          actionHandler: () {},
          docAddress: docPath,
          resolvedCollection: '',
          resolveDocID: item.id,
          showActionButton: false,
          showCopyButton: true,
          showDeleteButton: false);
  }

  static Future<void> showItem(
      {required String documentAddress,
      required String itemShownDocAddress,
      required String profileShownDocAddress,
      required String profileAddress,
      required Map<String, dynamic> profileShownData,
      required Map<String, dynamic> profileDocData}) async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final today = DateTime.now();
    final options = SetOptions(merge: true);
    final item = firestore.doc(documentAddress);
    final profileDoc = firestore.doc(profileAddress);
    final itemShownUsers = firestore.doc(itemShownDocAddress);
    final myShownItems = firestore.doc(profileShownDocAddress);
    final getItem = await item.get();
    final exists = getItem.exists;
    final data = {'times': FieldValue.increment(1), 'date': today};
    if (exists) {
      batch.set(item, {'times shown': FieldValue.increment(1)}, options);
      batch.set(itemShownUsers, data, options);
      batch.set(myShownItems, profileShownData, options);
      batch.set(profileDoc, profileDocData, options);
      return batch.commit();
    }
  }

  static Future<void> updateDaily(
      {required String myUsername,
      required Map<String, dynamic> fields,
      required String? collectionName,
      required String? docID,
      required Map<String, dynamic> docFields}) async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final date = todaysDate();
    final todaysDetails = firestore.doc('Control/Days/$date/Details');
    final mySesh =
        firestore.doc('Control/Days/$date/Details/Logins/$myUsername');
    final options = SetOptions(merge: true);
    batch.set(todaysDetails, fields, options);
    batch.set(mySesh, fields, options);
    if (collectionName != null) {
      final seshCollectionDoc = docID != null
          ? mySesh.collection(collectionName).doc(docID)
          : mySesh.collection(collectionName).doc();
      batch.set(seshCollectionDoc, docFields, options);
    }
    return batch.commit();
  }

  static Future<void> updateControl(
      {required Map<String, dynamic> fields,
      required String myUsername,
      required String? collectionName,
      required String? docID,
      required Map<String, dynamic> docFields}) async {
    var firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    final options = SetOptions(merge: true);
    final controlDoc = firestore.doc('Control/Details');
    batch.set(controlDoc, fields, options);
    General.updateDaily(
        myUsername: myUsername,
        fields: fields,
        collectionName: collectionName,
        docID: docID,
        docFields: docFields);
    return batch.commit();
  }

  static Future<bool> checkExists(String docAddress) async {
    final firestore = FirebaseFirestore.instance;
    final getDoc = await firestore.doc(docAddress).get();
    return getDoc.exists;
  }
}
