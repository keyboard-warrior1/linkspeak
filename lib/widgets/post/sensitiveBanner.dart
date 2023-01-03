import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/fullPostHelper.dart';
import '../../providers/myProfileProvider.dart';

class SensitiveBanner extends StatelessWidget {
  final void Function() previewSetState;
  const SensitiveBanner(this.previewSetState);
  @override
  Widget build(BuildContext context) {
    final lang = General.language(context);
    final FullHelper helper = Provider.of<FullHelper>(context);
    final String poster = helper.posterId;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    final bool sensitiveContent = helper.sensitiveContent;
    final bool _showPost = helper.showPost;
    final bool isMyPost = poster == myUsername;
    final void Function() showPost =
        Provider.of<FullHelper>(context, listen: false).show;
    return Positioned.fill(
      child: (sensitiveContent && !_showPost && !isMyPost)
          ? AnimatedContainer(
              duration: const Duration(seconds: 0),
              color: Colors.black,
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Spacer(),
                    const Icon(Icons.warning, color: Colors.white, size: 55.0),
                    const SizedBox(height: 5.0),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(lang.widgets_post3,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15.0)))),
                    const Spacer(),
                    const Divider(
                        color: Colors.white, indent: 0.0, endIndent: 0.0),
                    TextButton(
                        child: Text(lang.widgets_post4,
                            style: const TextStyle(fontSize: 25.0)),
                        onPressed: () {
                          showPost();
                          previewSetState();
                        })
                  ]))
          : Container(height: 0, width: 0),
    );
  }
}
