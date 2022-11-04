import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MyVideoPlayer extends StatefulWidget {
  final String url;
  final bool canPause;
  final bool isSensitive;
  final Widget? bottomRight;
  const MyVideoPlayer(this.url, this.canPause, this.isSensitive,
      [this.bottomRight]);

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  bool isPaused = false;
  late final VideoPlayerController controller;
  late final Future<void> initVideo;
  void playVid() {
    controller.play();
    setState(() {
      isPaused = false;
    });
  }

  void pauseVid() {
    if (widget.canPause) {
      controller.pause();
      setState(() {
        isPaused = true;
      });
    }
  }

  Widget buildPauseButton(Color _primaryColor, Color _accentColor) => Center(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              height: 75.0,
              width: 75.0,
              decoration: BoxDecoration(
                  color: _primaryColor
                  // .withOpacity(0.75)
                  ,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _accentColor
                      // .withOpacity(0.75)
                      ,
                      width: 2)),
              child: Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    const Spacer(),
                    IconButton(
                        onPressed: playVid,
                        icon: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 27.0)),
                    const Spacer()
                  ])))));

  @override
  void initState() {
    super.initState();
    if (widget.isSensitive) isPaused = true;
    controller = VideoPlayerController.network(widget.url);
    controller.setLooping(true);
    initVideo = controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _themeColors = Theme.of(context).colorScheme;
    final _primaryColor = _themeColors.primary;
    final _accentColor = _themeColors.secondary;
    super.build(context);
    return FutureBuilder(
        future: initVideo,
        builder: (ctx, snapshot) {
          return AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(children: <Widget>[
                Positioned.fill(
                    child: GestureDetector(
                        onTap: (isPaused) ? playVid : pauseVid,
                        child: VisibilityDetector(
                            key: UniqueKey(),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction < 0.75)
                                controller.pause();
                              else if (info.visibleFraction >
                                  0.75) if (!isPaused) controller.play();
                            },
                            child: VideoPlayer(controller)))),
                if (isPaused) buildPauseButton(_primaryColor, _accentColor),
                if (widget.bottomRight != null) widget.bottomRight!
              ]));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
