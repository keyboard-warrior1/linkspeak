import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/myProfileProvider.dart';
import 'reportDialog.dart';
import 'load.dart';

class ChatMenu extends StatelessWidget {
  final String chatId;
  const ChatMenu(this.chatId);

  @override
  Widget build(BuildContext context) {
    void _showIt() {
      showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (_) {
            return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: const Load());
          });
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final _myUsername =
        Provider.of<MyProfile>(context, listen: false).getUsername;
    return Expanded(
      flex: 1,
      child: PopupMenuButton<ListTile>(
        icon: const Icon(
          Icons.more_vert,
          color: Colors.grey,
        ),
        itemBuilder: (_) {
          return [
            PopupMenuItem(
              child: ListTile(
                title: const Text('Clear chat'),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 150.0,
                            maxWidth: 150.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  'Clear chat',
                                  softWrap: false,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Roboto',
                                    fontSize: 19.0,
                                    color: Colors.black,
                                  ),
                                ),
                                const Divider(
                                  thickness: 1.0,
                                  indent: 0.0,
                                  endIndent: 0.0,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        _showIt();
                                        final myMsgsCollec = await firestore
                                            .collection(
                                                'Users/$_myUsername/chats/$chatId/messages')
                                            .get();
                                        final docs = myMsgsCollec.docs;
                                        if (docs.isEmpty) {
                                          Navigator.pop(context);
                                        } else {
                                          var batch = firestore.batch();
                                          batch.update(
                                              firestore
                                                  .collection(
                                                      'Users/$_myUsername/chats')
                                                  .doc('$chatId'),
                                              {
                                                '0': 1,
                                                'displayMessage': '',
                                                'isRead': true,
                                                'lastMessageTime':
                                                    DateTime.now()
                                              });
                                          final getDeleted = await firestore
                                              .collection('Deleted Chats')
                                              .doc('$_myUsername - $chatId')
                                              .get();
                                          firestore
                                              .collection('Deleted Chats')
                                              .doc('$_myUsername - $chatId')
                                              .set(
                                                  {
                                                'date deleted': DateTime.now()
                                              },
                                                  SetOptions(
                                                      merge: (getDeleted.exists)
                                                          ? true
                                                          : false)).then(
                                                  (value) {
                                            for (var theid in docs) {
                                              final docID = theid.id;
                                              final date =
                                                  theid.get('date').toDate();
                                              final description =
                                                  theid.get('description');
                                              final isRead =
                                                  theid.get('isRead');
                                              final isDeleted =
                                                  theid.get('isDeleted');
                                              final isPost =
                                                  theid.get('isPost');
                                              final isMedia =
                                                  theid.get('isMedia');
                                              final sender = theid.get('user');
                                              final token = theid.get('token');
                                              firestore
                                                  .collection('Deleted Chats')
                                                  .doc('$_myUsername - $chatId')
                                                  .collection('messages')
                                                  .add({
                                                'date': date,
                                                'description': description,
                                                'isRead': isRead,
                                                'isDeleted': isDeleted,
                                                'isPost': isPost,
                                                'isMedia': isMedia,
                                                'user': sender,
                                                'token': token,
                                              });
                                              batch.delete(firestore
                                                  .collection(
                                                      'Users/$_myUsername/chats/$chatId/messages')
                                                  .doc(docID));
                                            }
                                            batch.commit().then((value) =>
                                                Navigator.pop(context));
                                          });
                                        }
                                      },
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                          splashFactory:
                                              NoSplash.splashFactory),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'No',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            PopupMenuItem(
              child: ListTile(
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ReportDialog(
                        id: chatId,
                        postID: '',
                        isInProfile: true,
                        isInPost: false,
                        isInComment: false,
                        isInReply: false,
                        commentID: '',
                      );
                    },
                  );
                },
              ),
            ),
          ];
        },
      ),
    );
  }
}
