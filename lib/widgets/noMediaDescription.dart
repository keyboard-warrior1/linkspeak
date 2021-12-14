import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class NoMediaPostDescriptionPreview extends StatelessWidget {
  final String description;
  final ScrollController controller;
  const NoMediaPostDescriptionPreview(this.description, this.controller);
  @override
  Widget build(BuildContext context) {
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = _sizeQuery.width;
    final String preview;
    if (description.length > 1000) {
      preview = description.substring(0, 1000);
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.15,
          maxHeight: _deviceHeight * 0.55,
          minWidth: _deviceWidth,
          maxWidth: _deviceWidth,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: NotificationListener<OverscrollNotification>(
            onNotification: (OverscrollNotification value) {
              if (value.overscroll < 0 &&
                  controller.offset + value.overscroll <= 0) {
                if (controller.offset != 0) controller.jumpTo(0);
                return true;
              }
              if (controller.offset + value.overscroll >=
                  controller.position.maxScrollExtent) {
                if (controller.offset != controller.position.maxScrollExtent)
                  controller.jumpTo(controller.position.maxScrollExtent);
                return true;
              }
              controller.jumpTo(controller.offset + value.overscroll);
              return true;
            },
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: AutoSizeText(
                preview + '...',
                style: const TextStyle(fontFamily: 'Roboto'),
                softWrap: true,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                minFontSize: 17.0,
                maxFontSize: 20.0,
                maxLines: 1500,
              ),
            ),
          ),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.15,
          maxHeight: _deviceHeight * 0.55,
          minWidth: _deviceWidth,
          maxWidth: _deviceWidth,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: NotificationListener<OverscrollNotification>(
            onNotification: (OverscrollNotification value) {
              if (value.overscroll < 0 &&
                  controller.offset + value.overscroll <= 0) {
                if (controller.offset != 0) controller.jumpTo(0);
                return true;
              }
              if (controller.offset + value.overscroll >=
                  controller.position.maxScrollExtent) {
                if (controller.offset != controller.position.maxScrollExtent)
                  controller.jumpTo(controller.position.maxScrollExtent);
                return true;
              }
              controller.jumpTo(controller.offset + value.overscroll);
              return true;
            },
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: AutoSizeText(
                '$description',
                style: const TextStyle(fontFamily: 'Roboto'),
                softWrap: true,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.start,
                minFontSize: 17.0,
                maxFontSize: 20.0,
                maxLines: 1500,
              ),
            ),
          ),
        ),
      );
    }
  }
}
