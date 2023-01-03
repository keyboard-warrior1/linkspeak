import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

import '../general.dart';
import '../widgets/common/noglow.dart';
import '../widgets/misc/videoPlayer.dart';

class MediaScreen extends StatefulWidget {
  final dynamic mediaUrls;
  final dynamic currentIndex;
  final dynamic isInComment;
  const MediaScreen(
      {required this.mediaUrls,
      required this.currentIndex,
      required this.isInComment});
  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  int stateindex = 0;
  Widget buildWidget(String url) {
    if (widget.isInComment) {
      return Container(
        child: ExtendedImage.network(
          url,
          fit: BoxFit.contain,
          printError: false,
          enableLoadState: true,
          handleLoadingProgress: true,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (_) => GestureConfig(
            inPageView: true,
            initialScale: 1.0,
            cacheGesture: false,
          ),
        ),
      );
    } else {
      final reference = storage.refFromURL(url);
      final fullPath = reference.fullPath;
      final type = lookupMimeType(fullPath);
      if (type!.startsWith('image')) {
        return Container(
          child: ExtendedImage.network(
            url,
            fit: BoxFit.contain,
            printError: false,
            enableLoadState: true,
            handleLoadingProgress: true,
            mode: ExtendedImageMode.gesture,
            initGestureConfigHandler: (_) => GestureConfig(
              inPageView: true,
              initialScale: 1.0,
              cacheGesture: false,
            ),
          ),
        );
      } else {
        return Center(
          child: Container(
            color: Colors.black,
            child: MyVideoPlayer(url, true, false),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    stateindex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SizedBox(
            height: _deviceHeight,
            width: _deviceWidth,
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.black87,
                  child: Noglow(
                    child: ExtendedImageGesturePageView.builder(
                      physics: (widget.mediaUrls.length > 1)
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      controller: ExtendedPageController(
                          initialPage: widget.currentIndex),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.mediaUrls.length,
                      onPageChanged: (ind) {
                        setState(() {
                          stateindex = ind;
                        });
                      },
                      itemBuilder: (context, index) {
                        var item = widget.mediaUrls[index];
                        return buildWidget(item);
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    color: Colors.black54,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          '${stateindex + 1}/${widget.mediaUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
