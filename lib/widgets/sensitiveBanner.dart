import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../providers/fullPostHelper.dart';

class SensitiveBanner extends StatelessWidget {
  const SensitiveBanner();

  @override
  Widget build(BuildContext context) {
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
                  const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 55.0,
                  ),
                  const SizedBox(height: 5.0),
                  const Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: const Text(
                        'This post may contain sensitive or distressing content',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Divider(
                    color: Colors.white,
                    indent: 0.0,
                    endIndent: 0.0,
                  ),
                  TextButton(
                    child: const Text(
                      'View post',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    onPressed: showPost,
                  )
                ],
              ),
            )
          : Container(height: 0, width: 0),
    );
  }
}
