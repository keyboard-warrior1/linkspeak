import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../providers/myProfileProvider.dart';

class ClubAvatar extends StatefulWidget {
  final double radius;
  final String clubName;
  final String? editUrl;
  final bool inEdit;
  final double fontSize;
  final AssetEntity? asset;

  const ClubAvatar(
      {required this.clubName,
      required this.radius,
      required this.inEdit,
      required this.asset,
      required this.fontSize,
      this.editUrl});

  @override
  State<ClubAvatar> createState() => _ClubAvatarState();
}

class _ClubAvatarState extends State<ClubAvatar> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future getImageFuture;
  String avatar = "";
  bool isBanned = false;
  bool isProhibited = false;
  bool isDisabled = false;
  Future getImage(String myUsername) async {
    final clubDocument = await firestore.doc('Clubs/${widget.clubName}').get();
    final _theClub = firestore.collection('Clubs').doc(widget.clubName);
    final userBlocks =
        await _theClub.collection('Banned').doc(myUsername).get();
    avatar = clubDocument.get('Avatar');
    isProhibited = clubDocument.get('isProhibited');
    isDisabled = clubDocument.get('isDisabled');
    if (userBlocks.exists && !myUsername.startsWith('Linkspeak')) {
      isBanned = true;
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
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return FutureBuilder(
      future: getImageFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: widget.radius,
              child: Container());

        if (snapshot.hasError)
          return CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: widget.radius,
              child: Container());

        return (isBanned || isProhibited || isDisabled)
            ? CircleAvatar(
                backgroundColor: Colors.grey.shade300, radius: widget.radius)
            : (widget.inEdit)
                ? (widget.asset != null)
                    ? CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        radius: widget.radius,
                        backgroundImage: AssetEntityImageProvider(widget.asset!,
                            isOriginal: true))
                    : widget.editUrl == 'none'
                        ? Container(
                            height: widget.radius * 2,
                            width: widget.radius * 2,
                            decoration: BoxDecoration(
                                color: _primaryColor, shape: BoxShape.circle),
                            child: Center(
                                child: Text('${widget.clubName[0]}',
                                    style: TextStyle(
                                        fontSize: widget.fontSize,
                                        color: _accentColor))))
                        : CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            radius: widget.radius,
                            backgroundImage: NetworkImage(widget.editUrl!))
                : (avatar != 'none')
                    ? CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        radius: widget.radius,
                        backgroundImage: NetworkImage(avatar))
                    : Container(
                        height: widget.radius * 2,
                        width: widget.radius * 2,
                        decoration: BoxDecoration(
                            color: _primaryColor, shape: BoxShape.circle),
                        child: Center(
                            child: Text('${widget.clubName[0]}',
                                style: TextStyle(
                                    fontSize: widget.fontSize,
                                    color: _accentColor))));
      },
    );
  }
}
