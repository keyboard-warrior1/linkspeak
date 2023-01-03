import 'package:flutter/material.dart';

class PrivateClub extends StatelessWidget {
  final IconData icon;
  final String message;
  const PrivateClub({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.white,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon,
                color: Colors.black,
                size: MediaQuery.of(context).size.height * 0.15),
            const SizedBox(height: 10.0),
            Text(message,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))
          ]));
}
