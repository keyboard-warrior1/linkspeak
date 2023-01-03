import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';

String get testNativeAd {
  return Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';
}

String get nativeAdUnitId {
  if (kDebugMode) {
    return testNativeAd;
  } else {
    if (Platform.isAndroid)
      return 'ca-app-pub-9528572745786880/1906037759';
    else
      return 'ca-app-pub-9528572745786880/6307954179';
  }
}

class NativeAds extends StatefulWidget {
  const NativeAds();

  @override
  _NativeAdsState createState() => _NativeAdsState();
}

class _NativeAdsState extends State<NativeAds>
    with AutomaticKeepAliveClientMixin {
  bool failedLoad = false;
  bool isAdLoaded = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final NativeAdListener? listener;
  NativeAd? ad;
  Future<void> adLoaded(String myUsername) async {
    var batch = firestore.batch();
    final users = firestore.collection('Users');
    final myUser = users.doc(myUsername);
    batch.set(myUser, {'Ads shown': FieldValue.increment(1)},
        SetOptions(merge: true));
    Map<String, dynamic> fields = {'Ads shown': FieldValue.increment(1)};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: null,
        docID: null,
        docFields: {});
    return batch.commit();
  }

  Future<void> adClicked(String myUsername) async {
    var batch = firestore.batch();
    final users = firestore.collection('Users');
    final myUser = users.doc(myUsername);
    batch.set(myUser, {'Ads clicked': FieldValue.increment(1)},
        SetOptions(merge: true));
    Map<String, dynamic> fields = {'Ads clicked': FieldValue.increment(1)};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: null,
        docID: null,
        docFields: {});
    return batch.commit();
  }

  Future<void> adFailed(String myUsername) async {
    var batch = firestore.batch();
    final users = firestore.collection('Users');
    final myUser = users.doc(myUsername);
    batch.set(myUser, {'Ads failed': FieldValue.increment(1)},
        SetOptions(merge: true));
    Map<String, dynamic> fields = {'Ads failed': FieldValue.increment(1)};
    General.updateControl(
        fields: fields,
        myUsername: myUsername,
        collectionName: null,
        docID: null,
        docFields: {});
    return batch.commit();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && !Platform.isIOS) {
      final String myUsername =
          Provider.of<MyProfile>(context, listen: false).getUsername;
      listener = NativeAdListener(onAdLoaded: (_) {
        adLoaded(myUsername);
        if (!isAdLoaded)
          setState(() {
            isAdLoaded = true;
          });
      }, onAdClicked: (_) {
        adClicked(myUsername);
      }, onAdFailedToLoad: (_, __) {
        adFailed(myUsername);
        if (!failedLoad)
          setState(() {
            failedLoad = true;
          });
      });
      ad = NativeAd(
          adUnitId: nativeAdUnitId,
          factoryId: "adFactoryExample",
          listener: listener!,
          request: const AdRequest());
      ad!.load();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!kIsWeb && !Platform.isIOS) ad!.dispose();
  }

  Widget buildErrorWidget() {
    final lang = General.language(context);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(lang.widgets_misc1,
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
                IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        ad!.dispose();
                        ad = NativeAd(
                            adUnitId: nativeAdUnitId,
                            factoryId: "adFactoryExample",
                            listener: listener!,
                            request: const AdRequest());
                        failedLoad = false;
                        isAdLoaded = false;
                        ad!.load();
                      });
                    })
              ])
        ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return kIsWeb
        ? Container()
        : Platform.isIOS
            ? Container()
            : Container(
                key: UniqueKey(),
                alignment: Alignment.center,
                width: 500,
                height: 350,
                margin: const EdgeInsets.symmetric(vertical: 7),
                child: failedLoad
                    ? buildErrorWidget()
                    : isAdLoaded
                        ? AdWidget(ad: ad!)
                        : Container());
  }

  @override
  bool get wantKeepAlive => true;
}
