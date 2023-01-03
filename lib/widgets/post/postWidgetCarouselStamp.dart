import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/otherProfileProvider.dart';
import '../../providers/themeModel.dart';

class PostCarouselStamp extends StatelessWidget {
  final bool isInOtherProfile;
  const PostCarouselStamp(this.isInOtherProfile);

  @override
  Widget build(BuildContext context) {
    final locale =
        Provider.of<ThemeModel>(context, listen: false).serverLangCode;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    final FullHelper helper = Provider.of<FullHelper>(context, listen: false);
    final DateTime postedDate = helper.postedDate;
    if (isInOtherProfile) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          child: Stack(
            children: <Widget>[
              Text(
                General.timeStamp(postedDate, locale, context),
                softWrap: false,
                textAlign: TextAlign.end,
                style: TextStyle(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.25
                    ..color = Colors.black,
                  fontSize: 15.0,
                ),
              ),
              Text(
                General.timeStamp(postedDate, locale, context),
                softWrap: false,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
