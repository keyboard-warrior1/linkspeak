import 'package:flutter/material.dart';

class MiniLockedPost extends StatefulWidget {
  const MiniLockedPost();

  @override
  _MiniLockedPostState createState() => _MiniLockedPostState();
}

class _MiniLockedPostState extends State<MiniLockedPost> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Spacer(),
        const Icon(
          Icons.lock,
          color: Colors.black,
          size: 65.0,
        ),
        const SizedBox(height: 5.0),
        const Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'This post has been published by a private profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
