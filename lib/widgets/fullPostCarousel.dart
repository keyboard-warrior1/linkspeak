import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import '../providers/fullPostHelper.dart';
import '../providers/postCarouselHelper.dart';
import 'videoPlayer.dart';

class FullPostCarousel extends StatefulWidget {
  const FullPostCarousel();

  @override
  _FullPostCarouselState createState() => _FullPostCarouselState();
}

class _FullPostCarouselState extends State<FullPostCarousel> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Widget buildWidget(
      String url, double height, double width, bool isSensitive) {
    final reference = storage.refFromURL(url);
    final fullPath = reference.fullPath;
    final type = lookupMimeType(fullPath);
    if (type!.startsWith('image')) {
      return Container(
        color: Colors.grey.shade100,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: PinchZoom(
            zoomedBackgroundColor: Colors.black87,
            resetDuration: const Duration(milliseconds: 10),
            image: Image.network(
              url,
              height: height,
              width: width,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return MyVideoPlayer(url, true, isSensitive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final bool isSensitive = helper.sensitiveContent;
    final List<String> postImgUrls = helper.postImgUrls;
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    ScrollPhysics _carouselPhysics =
        Provider.of<CarouselPhysHelp>(context, listen: false).getPhysics;
    if (postImgUrls.length == 1) {
      _carouselPhysics = NeverScrollableScrollPhysics();
    }

    return CarouselSlider.builder(
      options: CarouselOptions(
        scrollPhysics: _carouselPhysics,
        pageSnapping: true,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          Provider.of<CarouselPhysHelp>(context, listen: false)
              .changeInd(index);
        },
        height: _deviceHeight * 0.57,
        autoPlay: Provider.of<CarouselPhysHelp>(context).carouselPlay,
        autoPlayInterval: const Duration(
          milliseconds: 1825,
        ),
        enableInfiniteScroll: false,
        pauseAutoPlayInFiniteScroll: true,
      ),
      itemCount: postImgUrls.length,
      itemBuilder: (ctx, ind, index) {
        final currentUrl = postImgUrls[ind];
        return Builder(
          builder: (BuildContext context) {
            final Widget _container =
                buildWidget(currentUrl, _deviceHeight * 0.57, _deviceWidth,isSensitive);
            return _container;
          },
        );
      },
    );
  }
}
