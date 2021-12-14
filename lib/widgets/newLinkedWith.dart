import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/chatProfileImage.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../models/screenArguments.dart';
import '../routes.dart';

class NewLinkedWith extends StatefulWidget {
  final String userName;
  const NewLinkedWith({required this.userName});

  @override
  _NewLinkedWithState createState() => _NewLinkedWithState();
}

class _NewLinkedWithState extends State<NewLinkedWith> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUsername = context.read<MyProfile>().getUsername;
    void _visitProfile({required final String username}) {
      if ((username == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: username);
        Navigator.pushNamed(
          context,
          (username == myUsername)
              ? RouteGenerator.myProfileScreen
              : RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    _recognizer.onTap = () => _visitProfile(username: widget.userName);
    return ListTile(
      key: UniqueKey(),
      onTap: () => _visitProfile(username: widget.userName),
      leading: GestureDetector(
        onTap: () => _visitProfile(username: widget.userName),
        child: ChatProfileImage(
          username: '${widget.userName}',
          factor: 0.05,
          inEdit: false,
          asset: null,
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'You are now linked with',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            TextSpan(
              recognizer: _recognizer,
              text: ' ${widget.userName}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
