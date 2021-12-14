import 'package:flutter/material.dart';
import '../routes.dart';
import 'appBarIcon.dart';

class SearchButton extends StatelessWidget {
  const SearchButton();

  @override
  Widget build(BuildContext context) {
    return AppBarIcon(
      splashColor: Colors.transparent,
      icon: Icons.search_rounded,
      onPressed: () => Navigator.pushNamed(
        context,
        RouteGenerator.searchScreen,
      ),
      hint: 'Search',
    );
  }
}
