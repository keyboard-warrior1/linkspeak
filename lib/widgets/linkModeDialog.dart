import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';

class LinkModeDialog extends StatefulWidget {
  final String username;
  const LinkModeDialog(this.username);

  @override
  State<LinkModeDialog> createState() => _LinkModeDialogState();
}

class _LinkModeDialogState extends State<LinkModeDialog> {
  final TapGestureRecognizer _recognizer = TapGestureRecognizer();

  @override
  void dispose() {
    super.dispose();
    _recognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _visitProfile() {
      if ((widget.username == myUsername)) {
      } else {
        final OtherProfileScreenArguments args =
            OtherProfileScreenArguments(otherProfileId: widget.username);
        Navigator.pushNamed(
          context,
          RouteGenerator.posterProfileScreen,
          arguments: args,
        );
      }
    }

    _recognizer..onTap = _visitProfile;
    final Color _primaryColor = Theme.of(context).primaryColor;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: _deviceHeight * 0.4,
          width: _deviceWidth * 0.65,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 35.0,
                  right: 35.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Success',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: _deviceHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Icon(
                    Icons.verified,
                    color: Colors.lightGreenAccent.shade400,
                    size: 55.0,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35.0,
                  vertical: 15.0,
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'You are now linked with ',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        recognizer: _recognizer,
                        text: widget.username,
                        style: TextStyle(
                          color: _primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Divider(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double?>(0.0),
                  splashFactory: NoSplash.splashFactory,
                  backgroundColor:
                      MaterialStateProperty.all<Color?>(Colors.transparent),
                ),
                child: Text(
                  'GOT IT',
                  style: TextStyle(color: _primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
