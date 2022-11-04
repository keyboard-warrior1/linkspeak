import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/otherProfileProvider.dart';

class PostWidgetButton extends StatelessWidget {
  final void Function() toggleCard;
  final bool isInOtherProfile;
  const PostWidgetButton(this.toggleCard, this.isInOtherProfile);
  @override
  Widget build(BuildContext context) {
    final FullHelper helper = Provider.of<FullHelper>(context);
    final List<String> topics = helper.postTopics;
    final List<String> postImgUrls = helper.postImgUrls;
    final dynamic postLocation = helper.getLocation;
    final bool withMedia = postImgUrls.isNotEmpty;
    final bool noMedia = postImgUrls.isEmpty;
    final DateTime postedDate = helper.postedDate;
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    if (isInOtherProfile) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: (withMedia)
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (noMedia)
            Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0))),
                child: Text(General.timeStamp(postedDate),
                    softWrap: false,
                    textAlign: TextAlign.end,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 15.0))),
          if (topics.isNotEmpty || postLocation != '')
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: (withMedia)
                            ? _primaryColor.withOpacity(0.5)
                            : _primaryColor,
                        shape: BoxShape.circle),
                    child: IconButton(
                        onPressed: () => toggleCard(),
                        icon: Icon(Icons.info_outline,
                            color: (withMedia) ? _accentColor : Colors.white))))
        ]);
  }
}
