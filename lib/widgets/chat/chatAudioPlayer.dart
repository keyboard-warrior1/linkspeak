import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import 'pageManager.dart';

class ChatAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMySide;
  final bool isSeen;
  final Widget dateWidget;
  const ChatAudioPlayer(
      this.audioUrl, this.isMySide, this.isSeen, this.dateWidget);

  @override
  State<ChatAudioPlayer> createState() => _ChatAudioPlayerState();
}

class _ChatAudioPlayerState extends State<ChatAudioPlayer> {
  late final PageManager _pageManager;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager(widget.audioUrl);
  }

  @override
  void dispose() {
    super.dispose();
    _pageManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.isMySide
                    ? widget.isSeen
                        ? Colors.green
                        : _primaryColor
                    : Colors.grey[300]),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: widget.isMySide
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    ValueListenableBuilder<ButtonState>(
                        valueListenable: _pageManager.buttonNotifier,
                        builder: (_, value, __) {
                          switch (value) {
                            case ButtonState.loading:
                              return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 20.0,
                                  height: 20.0,
                                  child: IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: Icon(Icons.stop,
                                          color: (widget.isMySide &&
                                                  !widget.isSeen)
                                              ? _accentColor
                                              : Colors.black),
                                      iconSize: 22.0,
                                      onPressed: () {}));
                            case ButtonState.paused:
                              return Container(
                                  height: 20,
                                  width: 20,
                                  margin: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: Icon(Icons.play_arrow,
                                          color: (widget.isMySide &&
                                                  !widget.isSeen)
                                              ? _accentColor
                                              : Colors.black),
                                      iconSize: 22.0,
                                      onPressed: _pageManager.play));
                            case ButtonState.playing:
                              return Container(
                                  height: 20.0,
                                  width: 20.0,
                                  margin: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: Icon(Icons.pause,
                                          color: (widget.isMySide &&
                                                  !widget.isSeen)
                                              ? _accentColor
                                              : Colors.black),
                                      iconSize: 22.0,
                                      onPressed: _pageManager.pause));
                          }
                        }),
                    Expanded(
                        child: ValueListenableBuilder<ProgressBarState>(
                            valueListenable: _pageManager.progressNotifier,
                            builder: (_, value, __) {
                              return ProgressBar(
                                  progress: value.current,
                                  buffered: value.buffered,
                                  total: value.total,
                                  onSeek: _pageManager.seek,
                                  timeLabelLocation: TimeLabelLocation.sides,
                                  timeLabelType: TimeLabelType.totalTime,
                                  timeLabelTextStyle: TextStyle(
                                      color: (widget.isMySide && !widget.isSeen)
                                          ? _accentColor
                                          : Colors.black),
                                  thumbGlowRadius: 0.0,
                                  thumbGlowColor: Colors.transparent,
                                  thumbRadius: 5.0,
                                  thumbCanPaintOutsideBar: false,
                                  progressBarColor:
                                      (widget.isMySide && !widget.isSeen)
                                          ? _accentColor
                                          : Colors.black,
                                  thumbColor:
                                      (widget.isMySide && !widget.isSeen)
                                          ? _accentColor
                                          : Colors.black,
                                  bufferedBarColor: Colors.white24,
                                  baseBarColor: Colors.white54);
                            }))
                  ]),
                  widget.dateWidget
                ])));
  }
}
