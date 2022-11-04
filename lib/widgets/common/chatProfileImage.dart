import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../providers/myProfileProvider.dart';
import '../../providers/otherProfileProvider.dart';

class ChatProfileImage extends StatefulWidget {
  final String username;
  final double factor;
  final String? editUrl;
  final bool inEdit;
  final bool? inOtherProfile;
  final AssetEntity? asset;
  const ChatProfileImage(
      {required this.username,
      required this.factor,
      required this.inEdit,
      required this.asset,
      this.inOtherProfile,
      this.editUrl});

  @override
  _ChatProfileImageState createState() => _ChatProfileImageState();
}

class _ChatProfileImageState extends State<ChatProfileImage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future getImageFuture;
  String _avatar = "";
  bool imBlocked = false;
  bool isBanned = false;
  Future getImage(String myUsername) async {
    final userDocument = await firestore.doc('Users/${widget.username}').get();
    final _theUser = firestore.collection('Users').doc(widget.username);
    final userBlocks =
        await _theUser.collection('Blocked').doc(myUsername).get();
    _avatar = userDocument.get('Avatar');
    final status = userDocument.get('Status');
    if (status == 'Allowed') {
      isBanned = false;
    } else {
      isBanned = true;
    }
    if (userBlocks.exists && !myUsername.startsWith('Linkspeak')) {
      imBlocked = true;
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    getImageFuture = getImage(myUsername);
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).colorScheme.primary;
    Color _accentColor = Theme.of(context).colorScheme.secondary;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    if (widget.username == myUsername) {
      _avatar = Provider.of<MyProfile>(context).getProfileImage;
    }
    if (widget.inOtherProfile != null && widget.inOtherProfile!) {
      _primaryColor =
          Provider.of<OtherProfile>(context, listen: false).getPrimaryColor;
      _accentColor =
          Provider.of<OtherProfile>(context, listen: false).getAccentColor;
    }
    return FutureBuilder(
      future: (widget.inEdit || widget.username == myUsername)
          ? null
          : getImageFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: _deviceHeight * widget.factor / 2,
              child: Container());

        if (snapshot.hasError)
          return CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: _deviceHeight * widget.factor / 2,
              child: Container());

        return (imBlocked || isBanned)
            ? CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: _deviceHeight * widget.factor / 2,
                child: Container())
            : (widget.inEdit)
                ? (widget.asset != null)
                    ? CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: _deviceHeight * widget.factor / 2,
                        foregroundImage: AssetEntityImageProvider(widget.asset!,
                            isOriginal: true))
                    : widget.editUrl == 'none'
                        ? Container(
                            height: _deviceHeight * widget.factor,
                            width: _deviceHeight * widget.factor,
                            decoration: BoxDecoration(
                                color: _primaryColor, shape: BoxShape.circle),
                            child: Center(
                                child: Text('${widget.username[0]}',
                                    style: TextStyle(
                                        fontSize: _deviceHeight *
                                            widget.factor /
                                            1.75,
                                        color: _accentColor))))
                        : CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            radius: _deviceHeight * widget.factor / 2,
                            foregroundImage: NetworkImage(widget.editUrl!))
                : _avatar == 'none'
                    ? Container(
                        height: _deviceHeight * widget.factor,
                        width: _deviceHeight * widget.factor,
                        decoration: BoxDecoration(
                            color: _primaryColor, shape: BoxShape.circle),
                        child: Center(
                            child: Text('${widget.username[0]}',
                                style: TextStyle(
                                    fontSize:
                                        _deviceHeight * widget.factor / 1.75,
                                    color: _accentColor))))
                    : CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: _deviceHeight * widget.factor / 2,
                        foregroundImage: NetworkImage(_avatar));
      },
    );
  }
}
