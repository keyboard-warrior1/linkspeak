import 'package:flutter/material.dart';

class TopicChip extends StatelessWidget {
  final String topicName;
  final Icon? icon;
  final void Function()? handler;
  final Color fontColor;
  final FontWeight fontWeight;
  final Color? otherPrimaryColor;
  const TopicChip(
      this.topicName, this.icon, this.handler, this.fontColor, this.fontWeight,
      [this.otherPrimaryColor]);
  @override
  Widget build(BuildContext context) {
    Color _primarySwatch = Theme.of(context).colorScheme.primary;
    if (otherPrimaryColor != null) _primarySwatch = otherPrimaryColor!;
    return Container(
        margin: const EdgeInsets.all(2.0),
        child: Chip(
            key: UniqueKey(),
            onDeleted: handler,
            deleteIcon: icon,
            padding: const EdgeInsets.all(3.50),
            backgroundColor: _primarySwatch,
            label: Text(topicName,
                textAlign: TextAlign.center,
                style: TextStyle(color: fontColor, fontWeight: fontWeight))));
  }
}
