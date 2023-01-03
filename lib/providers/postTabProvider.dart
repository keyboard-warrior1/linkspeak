import 'package:flutter/foundation.dart';

import '../models/post.dart';

class PostTabProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get getPosts => _posts;
  void setLinks(List<Post> posts) => _posts = posts;
  void morePosts(List<Post> extra) {
    _posts.addAll(extra);
    notifyListeners();
  }
}
