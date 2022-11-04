import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/fullPostHelper.dart';

class MiniDescriptionPreview extends StatelessWidget {
  const MiniDescriptionPreview();
  @override
  Widget build(BuildContext context) {
    final helper = Provider.of<FullHelper>(context, listen: false);
    final Size _sizeQuery = MediaQuery.of(context).size;
    final double _deviceHeight = _sizeQuery.height;
    final double _deviceWidth = General.widthQuery(context);
    final String description = helper.decription;
    final String preview;
    if (description.length > 200) {
      preview = description.substring(0, 150);
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.10,
          maxHeight: _deviceHeight * 0.20,
          minWidth: _deviceWidth * 0.70,
          maxWidth: _deviceWidth * 0.70,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: AutoSizeText(
              preview + '...',
              style: const TextStyle(fontFamily: 'Roboto'),
              softWrap: true,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              minFontSize: 5.0,
              maxFontSize: 55.0,
              maxLines: 5,
            ),
          ),
        ),
      );
    } else {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _deviceHeight * 0.10,
          maxHeight: _deviceHeight * 0.20,
          minWidth: _deviceWidth * 0.70,
          maxWidth: _deviceWidth * 0.70,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: AutoSizeText(
              '$description',
              style: const TextStyle(fontFamily: 'Roboto'),
              softWrap: true,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              minFontSize: 5.0,
              maxFontSize: 55.0,
              maxLines: 5,
            ),
          ),
        ),
      );
    }
  }
}
