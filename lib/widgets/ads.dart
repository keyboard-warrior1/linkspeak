import 'dart:math';
import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

class NativeAds extends StatefulWidget {
  const NativeAds();

  @override
  _NativeAdsState createState() => _NativeAdsState();
}

class _NativeAdsState extends State<NativeAds>
    with AutomaticKeepAliveClientMixin {
  Widget? child;

  final controller = NativeAdController();

  @override
  void initState() {
    super.initState();
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    super.build(context);
    if (child != null) return child!;
    final ad1 = NativeAd(
      controller: controller,
      key: UniqueKey(),
      height: 320,
      builder: (context, child) {
        return Material(
          elevation: 8,
          child: child,
        );
      },
      buildLayout: mediumAdTemplateLayoutBuilder,
      loading: SizedBox(
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 25.0,
              width: 25.0,
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
      error: SizedBox(
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text('An error has occured'),
                const SizedBox(
                  width: 5.0,
                ),
                IconButton(
                  onPressed: () async {
                    setState(() => child = SizedBox());
                    // await controller.load(force: true);
                    await Future.delayed(Duration(milliseconds: 20));
                    setState(() => child = null);
                  },
                  icon: Icon(Icons.refresh),
                ),
              ],
            )
          ],
        ),
      ),
      icon: AdImageView(size: 40),
      headline: AdTextView(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        maxLines: 1,
      ),
      body: AdTextView(style: TextStyle(color: Colors.black), maxLines: 1),
      media: AdMediaView(
        height: 170,
        width: MATCH_PARENT,
      ),
      attribution: AdTextView(
        width: WRAP_CONTENT,
        text: 'Ad',
        decoration: AdDecoration(
          border: BorderSide(color: Colors.green, width: 2),
          borderRadius: AdBorderRadius.all(16.0),
        ),
        style: TextStyle(color: Colors.green),
        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
      ),
      button: AdButtonView(
        elevation: 18,
        decoration: AdDecoration(backgroundColor: Colors.blue),
        height: MATCH_PARENT,
        textStyle: TextStyle(color: Colors.white),
      ),
      ratingBar: AdRatingBarView(starsColor: Colors.white),
    );
    final ad2 = NativeAd(
      controller: controller,
      key: UniqueKey(),
      height: 300,
      builder: (context, child) {
        return Material(
          elevation: 8,
          child: child,
        );
      },
      buildLayout: fullBuilder,
      loading: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 25.0,
              width: 25.0,
              child: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
      error: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text('An error has occured'),
                const SizedBox(
                  width: 5.0,
                ),
                IconButton(
                  onPressed: () async {
                    setState(() => child = SizedBox());
                    // await controller.load(force: true);
                    await Future.delayed(Duration(milliseconds: 20));
                    setState(() => child = null);
                  },
                  icon: Icon(Icons.refresh),
                ),
              ],
            )
          ],
        ),
      ),
      icon: AdImageView(size: 40),
      headline: AdTextView(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        maxLines: 1,
      ),
      media: AdMediaView(
        height: 180,
        width: MATCH_PARENT,
        elevation: 0,
        elevationColor: Colors.deepPurpleAccent,
      ),
      attribution: AdTextView(
        width: WRAP_CONTENT,
        height: WRAP_CONTENT,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        margin: EdgeInsets.only(right: 4),
        maxLines: 1,
        text: 'Ad',
        decoration: AdDecoration(
          borderRadius: AdBorderRadius.all(10),
          border: BorderSide(color: Colors.green, width: 1),
        ),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      button: AdButtonView(
        elevation: 18,
        elevationColor: Colors.amber,
        height: MATCH_PARENT,
      ),
      ratingBar: AdRatingBarView(starsColor: Colors.white),
    );
    final ads = [ad1, ad2];

    return ads[random.nextInt(2)];
  }

  @override
  bool get wantKeepAlive => true;
}

AdLayoutBuilder get fullBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribuition, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        decoration: AdDecoration(
            gradient: AdLinearGradient(
          colors: [Colors.indigo[300]!, Colors.indigo[700]!],
          orientation: AdGradientOrientation.tl_br,
        )),
        children: [
          media,
          AdLinearLayout(
            children: [
              icon,
              AdLinearLayout(children: [
                headline,
                AdLinearLayout(
                  children: [attribuition, advertiser, ratingBar],
                  orientation: HORIZONTAL,
                  width: MATCH_PARENT,
                ),
              ], margin: EdgeInsets.only(left: 4)),
            ],
            gravity: LayoutGravity.center_horizontal,
            width: WRAP_CONTENT,
            orientation: HORIZONTAL,
            margin: EdgeInsets.only(top: 6),
          ),
          AdLinearLayout(
            children: [button],
            orientation: HORIZONTAL,
          ),
        ],
      );
    };

AdLayoutBuilder get secondBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribution, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        orientation: HORIZONTAL,
        decoration: AdDecoration(
          gradient: AdRadialGradient(
            colors: [Colors.blue[300]!, Colors.blue[900]!],
            center: Alignment(0.5, 0.5),
            radius: 1000,
          ),
        ),
        children: [
          icon,
          AdLinearLayout(
            children: [
              headline,
              AdLinearLayout(
                children: [attribution, advertiser, ratingBar],
                orientation: HORIZONTAL,
                width: WRAP_CONTENT,
                height: 20,
              ),
              button,
            ],
            margin: EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      );
    };
