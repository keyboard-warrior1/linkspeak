import 'package:flutter/material.dart';

import '../../models/screenArguments.dart';
import '../../general.dart';
import '../../routes.dart';
import '../../widgets/common/settingsBar.dart';

class ControlDailyLogins extends StatelessWidget {
  final dynamic dayID;
  final dynamic logins;
  final dynamic allLogins;
  const ControlDailyLogins(this.dayID, this.logins, this.allLogins);
  Widget buildTextButton(String id, BuildContext context) => TextButton(
      key: ValueKey<String>(id),
      onPressed: () {
        var args = UserDailyScreenArgs(dayID, id);
        Navigator.pushNamed(context, RouteGenerator.userDaily, arguments: args);
      },
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Text(id)]));
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
            key: UniqueKey(),
            highlightElevation: 0.0,
            elevation: 0.0,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                child: Icon(Icons.search,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 35.0)),
            onPressed: () {
              var args = ControlDailyLoginSearchArgs(dayID, allLogins);
              Navigator.pushNamed(
                  context, RouteGenerator.controlDailyLoginSearch,
                  arguments: args);
            },
            backgroundColor: Theme.of(context).colorScheme.primary),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                          '${General.language(context).admin_controlDailyLogins} $dayID'),
                      Expanded(
                          child: ListView(children: <Widget>[
                        ...logins
                            .map((e) => buildTextButton(e.id, context))
                            .toList()
                      ]))
                    ]))));
  }
}
