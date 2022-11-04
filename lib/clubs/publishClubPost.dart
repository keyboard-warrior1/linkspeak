import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/addPostScreenState.dart';
import '../providers/clubProvider.dart';
import 'newClubPost.dart';

class PublishClubPost extends StatefulWidget {
  final dynamic clubInstance;
  const PublishClubPost(this.clubInstance);

  @override
  State<PublishClubPost> createState() => _PublishClubPostState();
}

class _PublishClubPostState extends State<PublishClubPost> {
  final newpostHelper = NewPostHelper();
  @override
  Widget build(BuildContext context) => MultiProvider(providers: [
        ChangeNotifierProvider<ClubProvider>.value(value: widget.clubInstance),
        ChangeNotifierProvider.value(value: newpostHelper),
      ], child: const NewClubPost());
}
