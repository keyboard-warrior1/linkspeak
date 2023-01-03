import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../misc/videoPlayer.dart';

class ChatMediaWidget extends StatefulWidget {
  final dynamic mediaUrls;
  final Widget dateWidget;
  final bool isMySide;
  const ChatMediaWidget(
      {required this.mediaUrls,
      required this.dateWidget,
      required this.isMySide});

  @override
  State<ChatMediaWidget> createState() => _ChatMediaWidgetState();
}

class _ChatMediaWidgetState extends State<ChatMediaWidget> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  int currentIndex = 0;
  List<dynamic> convertedURLs = [];
  @override
  void initState() {
    super.initState();
    convertedURLs = widget.mediaUrls.map((e) => e as String).toList();
  }

  Widget buildWidget(String url) {
    final reference = storage.refFromURL(url);
    final fullPath = reference.fullPath;
    final type = lookupMimeType(fullPath);
    if (type!.startsWith('image')) {
      return GestureDetector(
        onTap: () {
          final MediaScreenArgs args = MediaScreenArgs(
              mediaUrls: convertedURLs,
              currentIndex: currentIndex,
              isInComment: false);
          Navigator.pushNamed(context, RouteGenerator.mediaScreen,
              arguments: args);
        },
        child: Container(
          color: Colors.grey.shade100,
          height: double.infinity,
          width: double.infinity,
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
        ),
      );
    } else {
      return Container(
          child: MyVideoPlayer(
              url,
              true,
              true,
              Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      icon: const Icon(Icons.fullscreen,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        final MediaScreenArgs args = MediaScreenArgs(
                            mediaUrls: convertedURLs,
                            currentIndex: currentIndex,
                            isInComment: false);
                        Navigator.pushNamed(context, RouteGenerator.mediaScreen,
                            arguments: args);
                      }))),
          color: Colors.grey.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final _deviceHeight = mediaQuery.height;
    final _deviceWidth = mediaQuery.width;
    return Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: widget.isMySide
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: _deviceHeight * 0.35,
                      maxHeight: _deviceHeight * 0.35,
                      minWidth: _deviceWidth * 0.65,
                      maxWidth: _deviceWidth * 0.65),
                  child: Stack(children: <Widget>[
                    CarouselSlider(
                        key: PageStorageKey<String>('previewcarstore IT'),
                        options: CarouselOptions(
                            scrollPhysics: convertedURLs.length > 1
                                ? const AlwaysScrollableScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            pageSnapping: true,
                            viewportFraction: 1.0,
                            height: _deviceHeight * 0.52,
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            }),
                        items: [
                          ...convertedURLs.map((url) {
                            final ind = convertedURLs.indexOf(url);
                            final currentUrl = convertedURLs[ind];
                            return Builder(builder: (BuildContext context) {
                              final Widget _container = buildWidget(currentUrl);
                              return _container;
                            });
                          })
                        ]),
                    if (convertedURLs.length > 1)
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: const Radius.circular(15.0))),
                              child: Center(
                                  child: Text(
                                      '${currentIndex + 1}/${convertedURLs.length}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold)))))
                  ]))),
          const SizedBox(height: 10.0),
          widget.dateWidget
        ]));
  }
}
