import 'package:flutter/material.dart';

class SensitiveComment extends StatefulWidget {
  final bool isMyComment;
  const SensitiveComment(this.isMyComment);

  @override
  State<SensitiveComment> createState() => _SensitiveCommentState();
}

class _SensitiveCommentState extends State<SensitiveComment> {
  bool _showPost = false;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: (!_showPost && !widget.isMyComment)
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
                        'This comment may contain sensitive or distressing content',
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
                      'View comment',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    onPressed: () => setState(() {
                      _showPost = true;
                    }),
                  )
                ],
              ),
            )
          : Container(height: 0, width: 0),
    );
  }
}
