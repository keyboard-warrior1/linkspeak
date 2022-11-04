import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/flareCollectionHelper.dart';
import '../providers/myProfileProvider.dart';
import '../providers/themeModel.dart';

class FlareBanner extends StatefulWidget {
  final void Function(bool) hasBanner;
  const FlareBanner(this.hasBanner);

  @override
  State<FlareBanner> createState() => _FlareBannerState();
}

class _FlareBannerState extends State<FlareBanner> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _banner = "";
  bool nsfw = false;
  late Future getImageFuture;
  Future getImage(String username) async {
    final userDocument = await firestore.doc('Users/$username').get();
    if (userDocument.data()!.containsKey('Banner')) {
      final actualBanner = userDocument.get('Banner');
      if (userDocument.data()!.containsKey('bannerNSFW')) {
        final actualNSFW = userDocument.get('bannerNSFW');
        nsfw = actualNSFW;
      }
      _banner = actualBanner;
      if (actualBanner == 'None') {
        widget.hasBanner(false);
      } else {
        widget.hasBanner(true);
      }
    } else {
      widget.hasBanner(false);
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final String username =
        Provider.of<FlareCollectionHelper>(context, listen: false).posterID;
    getImageFuture = getImage(username);
  }

  @override
  Widget build(BuildContext context) {
    final censorNSFW = Provider.of<ThemeModel>(context).censorMode;
    final String poster =
        Provider.of<FlareCollectionHelper>(context, listen: false).posterID;
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final isMyBanner = poster == myUsername;
    return FutureBuilder(
      future: getImageFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.5),
            color: Colors.transparent,
          );
        }
        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.5),
            color: Colors.transparent,
          );
        }
        return _banner == '' || _banner == 'None'
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.5),
                color: Colors.transparent,
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      if (!nsfw || isMyBanner || !censorNSFW)
                        Image.network(_banner, fit: BoxFit.cover),
                      if (nsfw && !isMyBanner && censorNSFW)
                        Blur(
                            blur: 25,
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              child: Image.network(_banner, fit: BoxFit.cover),
                            ))
                    ],
                  ),
                ),
              );
      },
    );
  }
}
