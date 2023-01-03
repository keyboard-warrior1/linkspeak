import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../../providers/fullPostHelper.dart';
import '../../providers/postCarouselHelper.dart';
import '../misc/videoPlayer.dart';

class MiniCarousel extends StatefulWidget {
  const MiniCarousel();
  @override
  _MiniCarouselState createState() => _MiniCarouselState();
}

class _MiniCarouselState extends State<MiniCarousel> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Widget buildWidget(String url, double height, bool isSensitive) {
    final reference = storage.refFromURL(url);
    final fullPath = reference.fullPath;
    final type = lookupMimeType(fullPath);
    if (type!.startsWith('image')) {
      return Container(
        color: Colors.grey.shade100,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ExtendedImage.network(
            url,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
            printError: false,
            enableLoadState: false,
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.grey.shade100,
        child: MyVideoPlayer(url, true, isSensitive),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollPhysics _carouselPhysics = const AlwaysScrollableScrollPhysics();
    final helper = Provider.of<FullHelper>(context, listen: false);
    final CarouselPhysHelp _carouselInstance = helper.getCarouselInstance;
    final bool isSensitive = helper.sensitiveContent;
    final List<String> postImgUrls = helper.postImgUrls;
    if (postImgUrls.length == 1) {
      _carouselPhysics = const NeverScrollableScrollPhysics();
    }
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    return Positioned.fill(
      child: ChangeNotifierProvider.value(
        value: _carouselInstance,
        child: Builder(
          builder: (context) {
            final int currentIndex =
                Provider.of<CarouselPhysHelp>(context).current;
            return CarouselSlider(
              key: PageStorageKey<String>('minissstore IT'),
              options: CarouselOptions(
                initialPage: currentIndex,
                scrollPhysics: _carouselPhysics,
                pageSnapping: true,
                viewportFraction: 1.0,
                height: double.infinity,
                autoPlay: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  Provider.of<CarouselPhysHelp>(context, listen: false)
                      .changeInd(index);
                },
              ),
              items: [
                ...postImgUrls.map((url) {
                  final ind = postImgUrls.indexOf(url);
                  final currentUrl = postImgUrls[ind];
                  return Builder(
                    builder: (BuildContext context) {
                      final Widget _container = buildWidget(
                          currentUrl, _deviceHeight * 0.35, isSensitive);
                      return _container;
                    },
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
