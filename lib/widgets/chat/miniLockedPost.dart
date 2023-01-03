import 'package:flutter/material.dart';

class MiniLockedPost extends StatefulWidget {
  final IconData icon;
  final String message;
  const MiniLockedPost({required this.icon, required this.message});

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
        Icon(
          widget.icon,
          color: Colors.black,
          size: 65.0,
        ),
        const SizedBox(height: 5.0),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.message,
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
