import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../general.dart';
import '../../providers/myProfileProvider.dart';
import '../../providers/themeModel.dart';
import 'chatProfileImage.dart';

class SortationWidget extends StatefulWidget {
  final Sortation currentSortation;
  final void Function(Sortation) setSortation;
  final bool isComments;
  final bool isReplies;
  final bool isPosts;
  const SortationWidget(
      {required this.currentSortation,
      required this.setSortation,
      required this.isComments,
      required this.isReplies,
      required this.isPosts});

  @override
  State<SortationWidget> createState() => _SortationWidgetState();
}

class _SortationWidgetState extends State<SortationWidget> {
  String giveText(Sortation value) {
    final lang = General.language(context);
    switch (value) {
      case Sortation.newest:
        return lang.widgets_common25;
      case Sortation.top:
        return lang.widgets_common26;
      case Sortation.mine:
        if (widget.isComments)
          return lang.widgets_common27;
        else if (widget.isReplies)
          return lang.widgets_common28;
        else
          return lang.widgets_common29;
      default:
        return '';
    }
  }

  Widget buildIcon(IconData icon) =>
      Icon(icon, color: Colors.black54, size: 25.0);
  Widget buildTopWidget() {
    final theme = Provider.of<ThemeModel>(context, listen: false);
    final String selectedLikeTheme = theme.selectedIconName;
    final IconData selectedLikeIcon = theme.themeIcon;
    final File? activeIconPath = theme.activeLikeFile;
    if (selectedLikeTheme == 'Custom')
      return General.constrain(IconButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {},
          icon: Image.file(activeIconPath!)));
    else
      return buildIcon(selectedLikeIcon);
  }

  Widget givePrefix(Sortation value) {
    final myProfile = Provider.of<MyProfile>(context, listen: false);
    final String myUsername = myProfile.getUsername;
    switch (value) {
      case Sortation.newest:
        return buildIcon(Icons.timelapse_rounded);
      case Sortation.top:
        return buildTopWidget();
      case Sortation.mine:
        return General.constrain(ChatProfileImage(
            username: myUsername, factor: 1, inEdit: false, asset: null));
      default:
        return Container();
    }
  }

  DropdownMenuItem<Sortation> buildSortItem(Sortation value) =>
      DropdownMenuItem<Sortation>(
          value: value,
          onTap: () => widget.setSortation(value),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                givePrefix(value),
                const SizedBox(width: 10),
                Text(giveText(value), style: TextStyle(color: Colors.black54))
              ]));

  @override
  Widget build(BuildContext context) => Container(
      width: General.widthQuery(context),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1))),
      child: DropdownButton(
          key: UniqueKey(),
          borderRadius: BorderRadius.circular(15.0),
          onChanged: (Sortation? s) => widget.setSortation(s!),
          underline: Container(color: Colors.transparent),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          value: widget.currentSortation,
          items: [
            buildSortItem(Sortation.newest),
            buildSortItem(Sortation.top),
            buildSortItem(Sortation.mine)
          ]));
}
