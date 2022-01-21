import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import '../screens/feedScreen.dart';
import 'profileBox.dart';

class Preview extends StatelessWidget {
  final PersistentBottomSheetController controller;
  final String title;
  final bool imLinkedToThem;
  final handler;
  final visibility;
  final String userImageUrl;
  final String bio;
  final int numOfLinks;
  final int numOfLinkedTos;
  const Preview({
    required this.controller,
    required this.title,
    required this.imLinkedToThem,
    required this.handler,
    required this.visibility,
    required this.userImageUrl,
    required this.bio,
    required this.numOfLinks,
    required this.numOfLinkedTos,
  });
  @override
  Widget build(BuildContext context) {
    final bool _isMyProfile = title == context.read<MyProfile>().getUsername;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final TextButton _visit = TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.all(2.0)),
      ),
      onPressed: null,
      child: Text(
        'visit >',
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 19.0,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
    final Widget _profile = ProfileBox(
      additionalWebsite: '',
      additionalEmail: '',
      additionalNumber: '',
      additionalAddress: '',
      additionalAddressName: '',
      isInPreview: true,
      showBio: false,
      isMyProfile: _isMyProfile,
      publicProfile: null,
      imLinkedToThem: (_isMyProfile) ? null : imLinkedToThem,
      heightRatio: 0.31,
      boxColor: Colors.white,
      rightButton: _visit,
      handler: handler,
      myVisibility: visibility,
      url: userImageUrl,
      userName: title,
      bio: bio,
      numOfLinks: numOfLinks,
      numOfLinkedTos: numOfLinkedTos,
      controller: null,
      instance: null,
      imBlocked: false,
    );
    final Widget _preview = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: _deviceHeight * 0.2,
        maxHeight: _deviceHeight * 0.4,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 9.0,
          right: 9.0,
          left: 9.0,
        ),
        child: GestureDetector(
          onTap: (_isMyProfile) ? () {} : handler,
          child: _profile,
        ),
      ),
    );
    controller.closed.then((value) {
      FeedScreen.sheetOpen = false;
    });
    return _preview;
  }
}
