import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/chatprofileImage.dart';

class BanItem extends StatefulWidget {
  final String adminName;
  final String clubName;
  final void Function(String) addAdmin;
  final void Function(String) removeAdmin;
  final Key key;
  const BanItem(
      {required this.adminName,
      required this.clubName,
      required this.addAdmin,
      required this.removeAdmin,
      required this.key});

  @override
  _BanItemState createState() => _BanItemState();
}

class _BanItemState extends State<BanItem> {
  bool isLoading = false;
  bool isAdmin = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getAdminStatus;
  Future<void> getAdminStatus() async {
    final thisClubMod = firestore
        .collection('Clubs')
        .doc(widget.clubName)
        .collection('Banned')
        .doc(widget.adminName);
    final getIt = await thisClubMod.get();
    final actualIsAdmin = getIt.exists;
    isAdmin = actualIsAdmin;
    if (mounted) setState(() {});
  }

  Future<void> assignAdmin(String myUsername) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var batch = firestore.batch();
      final _now = DateTime.now();
      final thisClub = firestore.collection('Clubs').doc(widget.clubName);
      final thisUser = firestore.collection('Users').doc(widget.adminName);
      final thisBannedFrom =
          thisUser.collection('Banned from').doc(widget.clubName);
      final thisBanned = thisClub.collection('Banned').doc(widget.adminName);
      final data = {'date': _now, 'by': myUsername};
      Map<String, dynamic> fields = {
        'club members banned': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'date': _now,
        'times': FieldValue.increment(1),
        'club': widget.clubName
      };
      final options = SetOptions(merge: true);
      batch.set(thisBanned, data, options);
      batch.set(thisBannedFrom, data, options);
      batch.set(
          thisClub, {'numOfBannedMembers': FieldValue.increment(1)}, options);
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'club members banned',
          docID: '${widget.adminName}',
          docFields: docFields);
      return batch.commit().then((value) {
        widget.addAdmin(widget.adminName);
        setState(() {
          isLoading = false;
          isAdmin = true;
        });
      });
    }
  }

  Future<void> removeAdmin(String myUsername) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var batch = firestore.batch();
      final _now = DateTime.now();
      final thisClub = firestore.collection('Clubs').doc(widget.clubName);
      final thisUser = firestore.collection('Users').doc(widget.adminName);
      final thisUserUnbanned =
          thisUser.collection('Unbanned from').doc(widget.clubName);
      final thisBannedFrom =
          thisUser.collection('Banned from').doc(widget.clubName);
      final thisBanned = thisClub.collection('Banned').doc(widget.adminName);
      final thisUnbanned =
          thisClub.collection('Unbanned').doc(widget.adminName);
      final getThisBanned = await thisBanned.get();
      final banDate = getThisBanned.get('date');
      final by = getThisBanned.get('by');
      final data = {
        'date': _now,
        'banned by': by,
        'unbanned by': myUsername,
        'date banned': banDate,
        'times': FieldValue.increment(1)
      };
      Map<String, dynamic> fields = {
        'club members unbanned': FieldValue.increment(1)
      };
      Map<String, dynamic> docFields = {
        'date': _now,
        'times': FieldValue.increment(1),
        'club': widget.clubName
      };
      final options = SetOptions(merge: true);
      batch.delete(thisBanned);
      batch.set(thisUnbanned, data, options);
      batch.set(thisUserUnbanned, data, options);
      batch.delete(thisBannedFrom);
      batch.set(
          thisClub,
          {
            'numOfBannedMembers': FieldValue.increment(-1),
            'numUnbanned': FieldValue.increment(1)
          },
          options);
      General.updateControl(
          fields: fields,
          myUsername: myUsername,
          collectionName: 'club members unbanned',
          docID: '${widget.adminName}',
          docFields: docFields);
      return batch.commit().then((value) {
        widget.removeAdmin(widget.adminName);
        setState(() {
          isLoading = false;
          isAdmin = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getAdminStatus = getAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    final String myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    void _visitProfile({required final String username}) {
      final OtherProfileScreenArguments args =
          OtherProfileScreenArguments(otherProfileId: username);
      Navigator.pushNamed(
          context,
          (username != myUsername)
              ? RouteGenerator.posterProfileScreen
              : RouteGenerator.myProfileScreen,
          arguments: args);
    }

    void _showDialog() => _visitProfile(username: widget.adminName);
    final Size _size = MediaQuery.of(context).size;
    final double _deviceHeight = _size.height;
    final double _deviceWidth = General.widthQuery(context);
    return FutureBuilder(
        future: _getAdminStatus,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError)
            return TextButton(
                onPressed: _showDialog,
                child: Container(
                    width: double.infinity,
                    height: _deviceHeight * 0.07,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 3.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              ChatProfileImage(
                                  username: widget.adminName,
                                  factor: 0.05,
                                  inEdit: false,
                                  asset: null),
                              const SizedBox(width: 7.0),
                              OptimisedText(
                                  minWidth: _deviceWidth * 0.1,
                                  maxWidth: _deviceWidth * 0.85,
                                  minHeight: _deviceHeight * 0.05,
                                  maxHeight: _deviceHeight * 0.1,
                                  fit: BoxFit.scaleDown,
                                  child: Text(widget.adminName,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.0))),
                              const Spacer()
                            ]))));

          return TextButton(
              onPressed: _showDialog,
              child: Container(
                  width: double.infinity,
                  height: _deviceHeight * 0.07,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3.0, horizontal: 3.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            ChatProfileImage(
                                username: widget.adminName,
                                factor: 0.05,
                                inEdit: false,
                                asset: null),
                            const SizedBox(width: 7.0),
                            OptimisedText(
                                minWidth: _deviceWidth * 0.1,
                                maxWidth: _deviceWidth * 0.85,
                                minHeight: _deviceHeight * 0.05,
                                maxHeight: _deviceHeight * 0.1,
                                fit: BoxFit.scaleDown,
                                child: Text(widget.adminName,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.0))),
                            const Spacer(),
                            if (widget.adminName != myUsername)
                              TextButton(
                                  onPressed: () {
                                    if (isLoading) {
                                    } else {
                                      if (isAdmin) {
                                        removeAdmin(myUsername);
                                      } else {
                                        assignAdmin(myUsername);
                                      }
                                    }
                                  },
                                  child: Text(isAdmin ? 'Unban' : 'Ban',
                                      style: TextStyle(
                                          color: isAdmin
                                              ? Colors.red
                                              : Colors.white)),
                                  style: isAdmin
                                      ? ButtonStyle(
                                          splashFactory: NoSplash.splashFactory,
                                          shape:
                                              MaterialStateProperty.all<OutlinedBorder?>(
                                                  RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: Colors.red),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0))),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color?>(
                                                  Colors.transparent))
                                      : ButtonStyle(
                                          splashFactory: NoSplash.splashFactory,
                                          shape: MaterialStateProperty.all<
                                              OutlinedBorder?>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                15.0,
                                              ),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color?>(
                                                  Colors.red)))
                          ]))));
        });
  }
}
