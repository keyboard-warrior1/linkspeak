import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/fullPostHelper.dart';
import 'videoPlayer.dart';

class PostWidgetCarousel extends StatefulWidget {
  const PostWidgetCarousel();

  @override
  _PostWidgetCarouselState createState() => _PostWidgetCarouselState();
}

class _PostWidgetCarouselState extends State<PostWidgetCarousel> {
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
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        child: MyVideoPlayer(url, true,isSensitive),
        color: Colors.grey.shade100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final bool isSensitive = helper.sensitiveContent;
    final List<String> postImgUrls = helper.postImgUrls;
    ScrollPhysics _carouselPhysics = AlwaysScrollableScrollPhysics();
    if (postImgUrls.length == 1) {
      _carouselPhysics = NeverScrollableScrollPhysics();
    }
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    return Positioned.fill(
      child: CarouselSlider.builder(
          key: PageStorageKey<String>('previewcarstore IT'),
          options: CarouselOptions(
              scrollPhysics: _carouselPhysics,
              pageSnapping: true,
              viewportFraction: 1.0,
              height: _deviceHeight * 0.52,
              autoPlay: false,
              enableInfiniteScroll: false),
          itemCount: postImgUrls.length,
          itemBuilder: (ctx, ind, index) {
            final currentUrl = postImgUrls[ind];
            return Builder(
              builder: (BuildContext context) {
                final Widget _container =
                    buildWidget(currentUrl, _deviceHeight * 0.52,isSensitive);
                return _container;
              },
            );
          }),
    );
  }
}
