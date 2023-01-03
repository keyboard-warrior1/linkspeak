import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../general.dart';
import '../models/miniProfile.dart';
import '../widgets/common/noglow.dart';
import '../widgets/common/settingsBar.dart';
import 'banItem.dart';

class BanMemberScreen extends StatefulWidget {
  final dynamic clubName;
  final dynamic addBanned;
  final dynamic removeBanned;
  const BanMemberScreen(
      {required this.clubName,
      required this.addBanned,
      required this.removeBanned});

  @override
  _BanMemberScreenState createState() => _BanMemberScreenState();
}

class _BanMemberScreenState extends State<BanMemberScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  bool userSearchLoading = false;
  bool _clearable = false;
  List<MiniProfile> userSearchResults = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> fullMembers = [];
  late Future<void> _getClubMembers;
  Future<void> getClubMembers() async {
    final thisClub = firestore.collection('Clubs').doc(widget.clubName);
    final theseMembers = await thisClub.collection('Members').get();
    final docs = theseMembers.docs;
    fullMembers = docs;
    if (mounted) setState(() {});
  }

  void getUserResults(String name) {
    final lowerCaseName = name.toLowerCase();
    fullMembers.forEach((doc) {
      if (userSearchResults.length < 20) {
        final String id = doc.id.toString().toLowerCase();
        final String username = doc.id;
        if (id.startsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.contains(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
        if (id.endsWith(lowerCaseName) &&
            !userSearchResults.any((result) => result.username == username)) {
          final MiniProfile mini = MiniProfile(username: username);
          userSearchResults.add(mini);
          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getClubMembers = getClubMembers();
    _textController.addListener(() {
      if (_textController.value.text.isNotEmpty) {
        if (!_clearable)
          setState(() {
            _clearable = true;
          });
      } else {}

      if (_textController.value.text.isEmpty) {
        if (_clearable)
          setState(() {
            _clearable = false;
          });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textController.removeListener(() {});
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceHeight = MediaQuery.of(context).size.height;
    final double _deviceWidth = General.widthQuery(context);
    final Color _primarySwatch = Theme.of(context).colorScheme.primary;
    final Color _accentColor = Theme.of(context).colorScheme.secondary;
    final lang = General.language(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
                child: SizedBox(
                    height: _deviceHeight,
                    width: _deviceWidth,
                    child: FutureBuilder(
                        future: _getClubMembers,
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SettingsBar(lang.clubs_banMember1),
                                  const Spacer(),
                                  const Center(
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 1.50)),
                                  const Spacer()
                                ]);
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                  SettingsBar(lang.clubs_banMember1),
                                  const Spacer(),
                                  Center(
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                        Text(lang.clubs_banMember2,
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(width: 15.0),
                                        TextButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<Color?>(
                                                        _primarySwatch),
                                                padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                                                    const EdgeInsets.all(0.0)),
                                                shape: MaterialStateProperty.all<OutlinedBorder?>(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.0)))),
                                            onPressed: () => setState(() {
                                                  _getClubMembers =
                                                      getClubMembers();
                                                }),
                                            child: Center(
                                                child: Text(lang.clubs_banMember3,
                                                    style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold))))
                                      ])),
                                  const Spacer()
                                ]));
                          }
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SettingsBar(lang.clubs_banMember1),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    child: TextField(
                                        onChanged: (text) async {
                                          if (text.isEmpty) {
                                            if (userSearchResults.isNotEmpty)
                                              userSearchResults.clear();
                                          } else {
                                            if (!userSearchLoading) {
                                              if (userSearchResults.isNotEmpty)
                                                userSearchResults.clear();
                                            }
                                            if (!userSearchLoading) {
                                              setState(() {
                                                userSearchLoading = true;
                                              });
                                            }
                                            getUserResults(text);
                                            setState(() {
                                              userSearchLoading = false;
                                            });
                                          }
                                        },
                                        controller: _textController,
                                        decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons.search,
                                                color: Colors.grey),
                                            suffixIcon: (_clearable)
                                                ? IconButton(
                                                    splashColor:
                                                        Colors.transparent,
                                                    tooltip:
                                                        lang.clubs_banMember4,
                                                    onPressed: () {
                                                      setState(() {
                                                        _textController.clear();
                                                        userSearchResults
                                                            .clear();
                                                        _clearable = false;
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.clear,
                                                        color: Colors.grey))
                                                : null,
                                            filled: true,
                                            fillColor: Colors.grey.shade200,
                                            hintText: lang.clubs_banMember5,
                                            hintStyle: const TextStyle(
                                                color: Colors.grey),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: BorderSide.none)))),
                                if (_textController.value.text.isEmpty)
                                  Text(lang.clubs_banMember6,
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                if (_textController.value.text.isNotEmpty &&
                                    userSearchResults.isEmpty &&
                                    !userSearchLoading)
                                  Container(
                                      child: Center(
                                          child: Text(lang.clubs_banMember7,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 49, 49, 49))))),
                                if (userSearchResults.isNotEmpty &&
                                    !userSearchLoading)
                                  Expanded(
                                      child: Noglow(
                                          child: ListView.builder(
                                              keyboardDismissBehavior:
                                                  ScrollViewKeyboardDismissBehavior
                                                      .onDrag,
                                              itemCount:
                                                  userSearchResults.length,
                                              itemBuilder: (ctx, index) {
                                                final current =
                                                    userSearchResults[index];
                                                final username =
                                                    current.username;
                                                return BanItem(
                                                    key: UniqueKey(),
                                                    adminName: username,
                                                    clubName: widget.clubName,
                                                    addAdmin: widget.addBanned,
                                                    removeAdmin:
                                                        widget.removeBanned);
                                              })))
                              ]);
                        })))));
  }
}
