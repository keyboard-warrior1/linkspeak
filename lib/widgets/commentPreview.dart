import 'package:flutter/material.dart';

class CommentPreview extends StatefulWidget {
  final String comment;
  const CommentPreview(this.comment);

  @override
  _CommentPreviewState createState() => _CommentPreviewState();
}

class _CommentPreviewState extends State<CommentPreview> {
  bool flag = true;
  late String firstHalf;
  late String secondHalf;
  @override
  void initState() {
    super.initState();
    if (widget.comment.length >= 400) {
      firstHalf = widget.comment.substring(0, 200);
      secondHalf = widget.comment.substring(200, widget.comment.length);
    } else {
      firstHalf = widget.comment;
      secondHalf = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (secondHalf.isEmpty)
          ? Text(
              firstHalf,
              textAlign: TextAlign.start,
              style:const TextStyle(
                color: Colors.black,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flag ? (firstHalf + '...') : (firstHalf + secondHalf),
                  textAlign: TextAlign.start,
                  style:const TextStyle(
                    color: Colors.black,
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      flag = !flag;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        flag ? 'show more' : 'show less',
                        style: const TextStyle(
                          color: Colors.lightBlue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
