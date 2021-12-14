import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../providers/myProfileProvider.dart';

class ProfileImage extends StatefulWidget {
  final String username;
  final String url;
  final double factor;
  final bool inEdit;
  final AssetEntity? asset;
  const ProfileImage({
    required this.username,
    required this.url,
    required this.factor,
    required this.inEdit,
    required this.asset,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  final firestore = FirebaseFirestore.instance;
  late Future<void> _getBlocked;
  bool imBlocked = false;
  Future<void> getBlocked(String myUsername) async {
    final _theUser = firestore.collection('Users').doc(widget.username);
    final userBlocks =
        await _theUser.collection('Blocked').doc(myUsername).get();
    if (userBlocks.exists && !myUsername.startsWith('Linkspeak')) {
      setState(() {
        imBlocked = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    _getBlocked = getBlocked(myUsername);
  }

  @override
  Widget build(BuildContext context) {
    final Color _primaryColor = Theme.of(context).primaryColor;
    final Color _accentColor = Theme.of(context).accentColor;
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return FutureBuilder(
      future:
          (widget.inEdit || widget.username == myUsername) ? null : _getBlocked,
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
            : widget.url == 'none'
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
                          widget.url,
                        ),
                      );
      },
    );
  }
}
