import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'videoPlayer.dart';

class AdWidgetCarousel extends StatefulWidget {
  final List<dynamic> assets;
  const AdWidgetCarousel(this.assets);

  @override
  _AdWidgetCarouselState createState() => _AdWidgetCarouselState();
}

class _AdWidgetCarouselState extends State<AdWidgetCarousel> {
  Widget buildWidget(String url) {
    final type = lookupMimeType(url);
    if (type!.startsWith('image')) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return MyVideoPlayer(url, false,false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollPhysics _carouselPhysics = AlwaysScrollableScrollPhysics();
    if (widget.assets.length == 1) {
      _carouselPhysics = NeverScrollableScrollPhysics();
    }
    return Positioned.fill(
      child: CarouselSlider.builder(
          key: UniqueKey(),
          options: CarouselOptions(
              scrollPhysics: _carouselPhysics,
              pageSnapping: true,
              viewportFraction: 1.0,
              height: double.infinity,
              autoPlay: (widget.assets.length == 1) ? false : true,
              enableInfiniteScroll: false),
          itemCount: widget.assets.length,
          itemBuilder: (ctx, ind, index) {
            final currentUrl = widget.assets[ind];
            return buildWidget(currentUrl);
          }),
    );
  }
}
