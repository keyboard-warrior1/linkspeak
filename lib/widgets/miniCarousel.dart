import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fullPostHelper.dart';
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'videoPlayer.dart';

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
          child: Image.network(
            url,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
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
    ScrollPhysics _carouselPhysics = AlwaysScrollableScrollPhysics();
    final helper = Provider.of<FullHelper>(context, listen: false);
    final bool isSensitive = helper.sensitiveContent;
    final List<String> postImgUrls = helper.postImgUrls;
    if (postImgUrls.length == 1) {
      _carouselPhysics = NeverScrollableScrollPhysics();
    }
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    return Positioned.fill(
      child: CarouselSlider.builder(
          key: PageStorageKey<String>('minissstore IT'),
          options: CarouselOptions(
            scrollPhysics: _carouselPhysics,
            pageSnapping: true,
            viewportFraction: 1.0,
            height: double.infinity,
            autoPlay: false,
            enableInfiniteScroll: false,
          ),
          itemCount: postImgUrls.length,
          itemBuilder: (ctx, ind, index) {
            final currentUrl = postImgUrls[ind];
            return Builder(
              builder: (BuildContext context) {
                final Widget _container =
                    buildWidget(currentUrl, _deviceHeight * 0.35, isSensitive);
                return _container;
              },
            );
          }),
    );
  }
}
