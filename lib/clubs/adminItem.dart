import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general.dart';
import '../models/screenArguments.dart';
import '../providers/myProfileProvider.dart';
import '../routes.dart';
import '../widgets/common/adaptiveText.dart';
import '../widgets/common/chatProfileImage.dart';

class AdminItem extends StatefulWidget {
  final Key key;
  final bool isFounder;
  final String adminName;
  final String clubName;
  final void Function(String) addAdmin;
  final void Function(String) removeAdmin;
  const AdminItem(
      {required this.isFounder,
      required this.adminName,
      required this.clubName,
      required this.addAdmin,
      required this.removeAdmin,
      required this.key});

  @override
  _AdminItemState createState() => _AdminItemState();
}

class _AdminItemState extends State<AdminItem> {
  bool isLoading = false;
  bool isAdmin = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<void> _getAdminStatus;
  Future<void> getAdminStatus() async {
    final thisClubMod = firestore
        .collection('Clubs')
        .doc(widget.clubName)
        .collection('Moderators')
        .doc(widget.adminName);
    final getIt = await thisClubMod.get();
    final actualIsAdmin = getIt.exists;
    isAdmin = actualIsAdmin;
    setState(() {});
  }

  Future<void> assignAdmin(String myUsername) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var batch = firestore.batch();
      final _rightNow = DateTime.now();
      final thisClub = firestore.collection('Clubs').doc(widget.clubName);
      final thisMod = thisClub.collection('Moderators').doc(widget.adminName);
      final thisMyClub = firestore
          .collection('Users')
          .doc(widget.adminName)
          .collection('My Clubs')
          .doc(widget.clubName);
      final data = {
        'date': _rightNow,
        'isMod': true,
        'isFounder': false,
        'assigned by': myUsername
      };
      batch.set(thisMod, data);
      batch.set(thisMyClub, data);
      batch.set(thisClub, {'numOfAdmins': FieldValue.increment(1)},
          SetOptions(merge: true));
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
      final _rightNow = DateTime.now();
      final thisClub = firestore.collection('Clubs').doc(widget.clubName);
      final thisUser = firestore.collection('Users').doc(widget.adminName);
      final thisRevoked =
          thisUser.collection('Revoked Clubs').doc(widget.clubName);
      final thisMod = thisClub.collection('Moderators').doc(widget.adminName);
      final thisRemovedMod =
          thisClub.collection('Removed Mods').doc(widget.adminName);
      final thisJoinedClub =
          thisUser.collection('My Clubs').doc(widget.clubName);
      final getThisMod = await thisMod.get();
      final assignedDate = getThisMod.get('date');
      final assignedBy = getThisMod.get('assigned by');
      final data = {
        'date': _rightNow,
        'date assigned': assignedDate,
        'assigned by': assignedBy,
        'removed by': myUsername,
        'times': FieldValue.increment(1)
      };
      final options = SetOptions(merge: true);
      batch.delete(thisMod);
      batch.delete(thisJoinedClub);
      batch.set(thisRevoked, data, options);
      batch.set(thisRemovedMod, data, options);
      batch.set(
          thisClub,
          {
            'numOfAdmins': FieldValue.increment(-1),
            'removedAdmins': FieldValue.increment(1)
          },
          options);
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
    final Color _primaryColor = Theme.of(context).colorScheme.primary;
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
                            if (widget.isFounder &&
                                widget.adminName != myUsername)
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
                                  child: Text(isAdmin ? 'Remove' : 'Assign',
                                      style: TextStyle(
                                          color: isAdmin
                                              ? Colors.red
                                              : Colors.white)),
                                  style: isAdmin
                                      ? ButtonStyle(
                                          splashFactory: NoSplash.splashFactory,
                                          shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(
                                              side:
                                                  BorderSide(color: Colors.red),
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color?>(
                                                  Colors.transparent))
                                      : ButtonStyle(
                                          splashFactory: NoSplash.splashFactory,
                                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15.0))),
                                          backgroundColor: MaterialStateProperty.all<Color?>(_primaryColor)))
                          ]))));
        });
  }
}
