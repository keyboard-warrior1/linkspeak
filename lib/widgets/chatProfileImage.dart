import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../providers/myProfileProvider.dart';

class ChatProfileImage extends StatefulWidget {
  final String username;
  final double factor;
  final bool inEdit;
  final AssetEntity? asset;
  const ChatProfileImage({
    required this.username,
    required this.factor,
    required this.inEdit,
    required this.asset,
  });

  @override
  _ChatProfileImageState createState() => _ChatProfileImageState();
}

class _ChatProfileImageState extends State<ChatProfileImage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future getImageFuture;
  String _avatar = "";
  bool imBlocked = false;
  Future getImage(String myUsername) async {
    final userDocument = await firestore.doc('Users/${widget.username}').get();
    final _theUser = firestore.collection('Users').doc(widget.username);
    final userBlocks =
        await _theUser.collection('Blocked').doc(myUsername).get();
    setState(() {
      _avatar = userDocument.get('Avatar');
      if (userBlocks.exists && !myUsername.startsWith('Linkspeak')) {
        imBlocked = true;
      }
    });
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
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return FutureBuilder(
      future: (widget.inEdit || widget.username == myUsername) ? null : getImageFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: _deviceHeight * widget.factor / 2,
            child: Container(),
          );
        }
        if (snapshot.hasError) {
          return CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: _deviceHeight * widget.factor / 2,
            child: Container(),
          );
        }
        return imBlocked
            ? CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                radius: _deviceHeight * widget.factor / 2,
                child: Container(),
              )
            : _avatar == 'none'
                ? Container(
                    height: _deviceHeight * widget.factor,
                    width: _deviceHeight * widget.factor,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.username[0]}',
                        style: TextStyle(
                          fontSize: _deviceHeight * widget.factor / 1.75,
                          color: _accentColor,
                        ),
                      ),
                    ),
                  )
                : (widget.inEdit && widget.asset != null)
                    ? CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        radius: _deviceHeight * widget.factor / 2,
                        backgroundImage: AssetEntityImageProvider(
                          widget.asset!,
                          isOriginal: true,
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        radius: _deviceHeight * widget.factor / 2,
                        backgroundImage: NetworkImage(
                          _avatar,
                        ),
                      );
      },
    );
  }
}
