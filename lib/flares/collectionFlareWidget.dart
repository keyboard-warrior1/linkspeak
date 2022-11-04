import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cube_transition_plus/cube_transition_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/flare.dart';
import '../models/screenArguments.dart';
import '../providers/flareCollectionHelper.dart';
import '../providers/fullFlareHelper.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/chatProfileImage.dart';
import 'collectionFlareTab.dart';
import 'flareMegaLike.dart';
import 'fullFlare.dart';

class CollectionFlareWidget extends StatefulWidget {
  const CollectionFlareWidget();

  @override
  State<CollectionFlareWidget> createState() => _CollectionFlareWidgetState();
}

class _CollectionFlareWidgetState extends State<CollectionFlareWidget> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isShown = true;
  bool triggerAnimation = false;
  bool likeLoading = false;
  late PageController pageController;
  void visitProfile(String myUsername, String username) {
    if (username != myUsername) {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(context, RouteGenerator.posterProfileScreen,
          arguments: args);
    } else {
      Navigator.pushNamed(context, RouteGenerator.myProfileScreen);
    }
  }

  void goToFlareProfile(String username) {
    final FlareProfileScreenArgs args = FlareProfileScreenArgs(username);
    Navigator.pushNamed(context, RouteGenerator.flareProfileScreen,
        arguments: args);
  }

  Widget giveStacked(String text, bool isSub) => Stack(children: <Widget>[
        Text(text,
            softWrap: isSub,
            style: TextStyle(
                fontSize: isSub ? 13.0 : 15.0,
                fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3.00
                  ..color = Colors.black)),
        Text(text,
            softWrap: isSub,
            style: TextStyle(
                fontSize: isSub ? 13.0 : 15.0,
                fontWeight: isSub ? FontWeight.normal : FontWeight.bold,
                color: Colors.white))
      ]);

  Widget buildAnimatedOpacity(Widget child) => AnimatedOpacity(
      duration: kThemeAnimationDuration,
      opacity: isShown ? 1 : 0,
      child: child);

  Widget buildListTile(
          String myUsername, String poster, String collectionTitle) =>
      Align(
          alignment: Alignment.topLeft,
          child: ListTile(
              horizontalTitleGap: 5.0,
              leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            decoration: BoxDecoration(boxShadow: const [
                              const BoxShadow(
                                  color: Colors.black38,
                                  offset: Offset(-5, 0),
                                  blurRadius: 20,
                                  spreadRadius: 0.5)
                            ]),
                            child: const Icon(Icons.arrow_back_ios,
                                color: Colors.white))),
                    GestureDetector(
                        onTap: () => visitProfile(myUsername, poster),
                        child: ChatProfileImage(
                            username: poster,
                            factor: 0.04,
                            inEdit: false,
                            asset: null))
                  ]),
              title: GestureDetector(
                  onTap: () => visitProfile(myUsername, poster),
                  child: giveStacked(poster, false)),
              subtitle: GestureDetector(
                  onTap: () => goToFlareProfile(poster),
                  child: giveStacked(collectionTitle, true))));
  Future<void> likeFlare(
      {required String myUsername,
      required String poster,
      required String collectionID,
      required String flareID,
      required void Function() statelike}) async {
    setState(() => triggerAnimation = true);
    Future.delayed(const Duration(milliseconds: 700),
        () => setState(() => triggerAnimation = false));
    if (!likeLoading) {
      setState(() => likeLoading = true);
      var batch = firestore.batch();
      var notifBatch = firestore.batch();
      final options = SetOptions(merge: true);
      final _rightNow = DateTime.now();
      final users = firestore.collection('Users');
      final flares = firestore.collection('Flares');
      final myUser = users.doc(myUsername);
      final myLiked = myUser.collection('Liked Flares').doc(flareID);
      // final myUnliked = myUser.collection('Unliked Flares').doc(flareID);
      final thisFlarer = flares.doc(poster);
      final thisPoster = await users.doc(poster).get();
      final token = thisPoster.get('fcm');
      final likeNotifs = thisFlarer.collection('LikeNotifs').doc();
      final thisColl = thisFlarer.collection('collections').doc(collectionID);
      final thisFlare = thisColl.collection('flares').doc(flareID);
      final thisFlareLikes = thisFlare.collection('likes').doc(myUsername);
      final getMyFlareLike = await thisFlareLikes.get();
      final isLiked = getMyFlareLike.exists;
      // final thisFlareUnlikes = thisFlare.collection('unlikes').doc(myUsername);
      final myLikeInfo = {
        'date': _rightNow,
        'flareID': flareID,
        'collectionID': collectionID,
        'poster': poster
      };
      // final myUnlikeInfo = {
      //   'likedFlares': FieldValue.increment(-1),
      //   'unlikedFlares': FieldValue.increment(1)
      // };
      final checkExists = await thisFlare.get();
      if (checkExists.exists) {
        if (!isLiked) {
          statelike();
          batch.set(myUser, {'likedFlares': FieldValue.increment(1)}, options);
          batch.set(myLiked, myLikeInfo, options);
          Map<String, dynamic> fields = {
            'flare likes': FieldValue.increment(1)
          };
          Map<String, dynamic> docFields = {
            'poster': poster,
            'collection': collectionID,
            'flare': flareID,
            'date': _rightNow
          };
          General.updateControl(
              fields: fields,
              myUsername: myUsername,
              collectionName: 'flare likes',
              docID: '$flareID',
              docFields: docFields);
          batch.set(thisColl, {'likes': FieldValue.increment(1)}, options);
          batch.set(thisFlareLikes, {'date': _rightNow}, options);
          batch.set(thisFlare, {'likes': FieldValue.increment(1)}, options);
          batch.set(
              thisFlarer, {'numOfLikes': FieldValue.increment(1)}, options);
          if (poster != myUsername) {
            final notifData = {
              'recipient': poster,
              'collectionID': '$collectionID',
              'flareID': '$flareID',
              'user': myUsername,
              'token': token,
              'date': _rightNow,
            };
            final status = thisPoster.get('Status');
            if (status != 'Banned') {
              if (thisPoster.data()!.containsKey('AllowFlareLikes')) {
                final allowLikes = thisPoster.get('AllowFlareLikes');
                if (allowLikes) {
                  notifBatch.set(likeNotifs, notifData, options);
                  notifBatch.set(thisFlarer,
                      {'likeNotifs': FieldValue.increment(1)}, options);
                }
              } else {
                notifBatch.set(thisFlarer,
                    {'likeNotifs': FieldValue.increment(1)}, options);
                notifBatch.set(likeNotifs, notifData, options);
              }
            }
          }
        }
        // else {
        //   statelike();
        //   batch.set(myUser, myUnlikeInfo, options);
        //   batch.delete(myLiked);
        //   batch.set(myUnliked, myLikeInfo, options);
        //   batch.update(control, {
        //     'flare likes': FieldValue.increment(-1),
        //     'flare unlikes': FieldValue.increment(1)
        //   });
        //   batch.delete(thisFlareLikes);
        //   batch.set(thisColl, {'likes': FieldValue.increment(-1)}, options);
        //   batch.set(thisColl, {'unlikes': FieldValue.increment(1)}, options);
        //   batch.set(thisFlareUnlikes, {'date': _rightNow}, options);
        //   batch.set(
        //       thisFlare,
        //       {
        //         'likes': FieldValue.increment(-1),
        //         'unlikes': FieldValue.increment(1)
        //       },
        //       options);
        //   batch.set(
        //       thisFlarer, {'numOfLikes': FieldValue.increment(-1)}, options);
        //   batch.set(
        //       thisFlarer, {'numOfUnlikes': FieldValue.increment(1)}, options);
        // }
        return batch.commit().then((value) {
          notifBatch.commit();
          setState(() => likeLoading = false);
        }).catchError((_) {
          statelike();
          setState(() => likeLoading = false);
        });
      } else {
        setState(() => likeLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final pickedInd =
        Provider.of<FlareCollectionHelper>(context, listen: false).pickedFlare;
    pageController = PageController(initialPage: 0);
    Future.delayed(const Duration(milliseconds: 1), () {
      if (pickedInd != 0) pageController.jumpToPage(pickedInd);
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _deviceHeight = _size.height;
    final _deviceWidth = General.widthQuery(context);
    final collectionHelper =
        Provider.of<FlareCollectionHelper>(context, listen: false);
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final List<Flare> flares = collectionHelper.flares;
    final poster = collectionHelper.posterID;
    final title = collectionHelper.collectionName;
    final collectionID = collectionHelper.collectionID;
    return SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(children: <Widget>[
          Positioned.fill(
              child: CubePageView(controller: pageController, children: [
            ...flares.map((flare) {
              final currentInstance = flare.instance;
              return ChangeNotifierProvider<FlareHelper>.value(
                  value: currentInstance,
                  child: Builder(builder: (context) {
                    final helper =
                        Provider.of<FlareHelper>(context, listen: false);
                    final flareID = helper.flareID;
                    final mediaURL = helper.mediaURL;
                    final isImage = helper.isImage;
                    final statelike = helper.like;
                    final viewFlare = helper.viewFlare;
                    final backgroundColor = helper.backgorundColor;
                    final gradientColor = helper.gradientColor;
                    return GestureDetector(
                        onDoubleTap: () => likeFlare(
                            myUsername: myUsername,
                            poster: poster,
                            collectionID: collectionID,
                            flareID: flareID,
                            statelike: statelike),
                        onLongPress: () => setState(() => isShown = false),
                        onLongPressEnd: (_) => setState(() => isShown = true),
                        child: FullFlare(
                            poster: poster,
                            collectionID: collectionID,
                            flareID: flareID,
                            isShown: isShown,
                            mediaURL: mediaURL,
                            isImage: isImage,
                            viewIt: viewFlare,
                            backgroundColor: backgroundColor,
                            gradientColor: gradientColor));
                  }));
            }).toList(),
          ])),
          buildAnimatedOpacity(buildListTile(myUsername, poster, title)),
          buildAnimatedOpacity(CollectionFlareTab(pageController)),
          MegaLike(triggerAnimation)
        ]));
  }
}
