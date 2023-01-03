import 'package:flutter/material.dart';

import '../../models/miniProfile.dart';
import '../../models/screenArguments.dart';
import '../../routes.dart';
import '../../general.dart';
import '../../widgets/common/noglow.dart';
import '../../widgets/common/settingsBar.dart';

class ControlDailyLoginSearch extends StatefulWidget {
  final dynamic dayID;
  final dynamic allLogins;
  const ControlDailyLoginSearch(this.dayID, this.allLogins);

  @override
  State<ControlDailyLoginSearch> createState() =>
      _ControlDailyLoginSearchState();
}

class _ControlDailyLoginSearchState extends State<ControlDailyLoginSearch> {
  final TextEditingController _textController = TextEditingController();
  List<MiniProfile> userSearchResults = [];
  bool userSearchLoading = false;
  bool _clearable = false;
  void getUserResults(String name) {
    final lowerCaseName = name.toLowerCase();
    widget.allLogins.forEach((doc) {
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

  Widget buildTextButton(String id) => TextButton(
      key: ValueKey<String>(id),
      onPressed: () {
        var args = UserDailyScreenArgs(widget.dayID, id);
        Navigator.pushNamed(context, RouteGenerator.userDaily, arguments: args);
      },
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Text(id)]));

  @override
  void initState() {
    super.initState();
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
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    final lang = General.language(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SizedBox(
                height: height,
                width: width,
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SettingsBar(
                          '${lang.admin_controlDailyLoginSearch1} ${widget.dayID}'),
                      Expanded(
                        child: Column(children: <Widget>[
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
                                              splashColor: Colors.transparent,
                                              tooltip: lang
                                                  .admin_controlDailyLoginSearch2,
                                              onPressed: () {
                                                setState(() {
                                                  _textController.clear();
                                                  userSearchResults.clear();
                                                  _clearable = false;
                                                });
                                              },
                                              icon: const Icon(Icons.clear,
                                                  color: Colors.grey))
                                          : null,
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      hintText:
                                          lang.admin_controlDailyLoginSearch1,
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: BorderSide.none)))),
                          if (_textController.value.text.isNotEmpty &&
                              userSearchResults.isEmpty &&
                              !userSearchLoading)
                            Container(
                                child: Center(
                                    child: Text(
                                        lang.admin_controlDailyLoginSearch3,
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 49, 49, 49))))),
                          if (userSearchResults.isNotEmpty &&
                              !userSearchLoading)
                            Expanded(
                                child: Noglow(
                                    child: ListView(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        children: <Widget>[
                                  ...userSearchResults.take(20).map((result) =>
                                      buildTextButton(result.username))
                                ])))
                        ]),
                      )
                    ]))));
  }
}
