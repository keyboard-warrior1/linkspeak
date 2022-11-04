import 'package:flutter/material.dart';

import '../models/flare.dart';

class FlareCollectionHelper with ChangeNotifier {
  String _posterID = '';
  String _collectionID = '';
  String _collectionName = '';
  int _pickedFlare = 0;
  bool _isMyCollection = false;
  bool _isMuted = false;
  bool _isHidden = false;
  bool _isBanned = false;
  bool _isBlocked = false;
  bool _imBlocked = false;
  bool _isEmptyFlare = false;
  List<Flare> _flares = [];
  ScrollController? _currentController;
  String get posterID => _posterID;
  String get collectionID => _collectionID;
  String get collectionName => _collectionName;
  int get pickedFlare => _pickedFlare;
  bool get isMyCollection => _isMyCollection;
  bool get isMuted => _isMuted;
  bool get isHidden => _isHidden;
  bool get isBanned => _isBanned;
  bool get isBlocked => _isBlocked;
  bool get imBlocked => _imBlocked;
  bool get isEmptyFlare => _isEmptyFlare;
  List<Flare> get flares => _flares;
  ScrollController get currentController => _currentController!;
  void setPosterID(String p) => _posterID = p;
  void pickFlare(int ind) => _pickedFlare = ind;
  void setCollectionName(String c) => _collectionName = c;
  void setCollectionID(String id) => _collectionID = id;
  void setFlares(List<Flare> f) => _flares = f;
  void setIsMyCollection(bool myc) => _isMyCollection = myc;
  void setIsMuted(bool mute) => _isMuted = mute;
  void setIsHidden(bool hid) => _isHidden = hid;
  void setIsBanned(bool ban) => _isBanned = ban;
  void setIsBlocked(bool bloc) => _isBlocked = bloc;
  void setImBlocked(bool imb) => _imBlocked = imb;
  void setIsEmpty(bool e) => _isEmptyFlare = e;
  void setScrollController(ScrollController s) => _currentController = s;

  void initializeCollection(
      {required String paramposterID,
      required String paramCollectionID,
      required String paramcollectionName,
      required List<Flare> paramflares,
      required bool paramisMyCollection,
      required bool paramisMuted,
      required bool paramIsHidden,
      required bool paramisBanned,
      required bool paramisBlocked,
      required bool paramimBlocked,
      required bool paramEmpty,
      required ScrollController? paramController}) {
    setPosterID(paramposterID);
    setCollectionID(paramCollectionID);
    setCollectionName(paramcollectionName);
    setFlares(paramflares);
    setIsMyCollection(paramisMyCollection);
    setIsMuted(paramisMuted);
    setIsHidden(paramIsHidden);
    setIsBanned(paramisBanned);
    setIsBlocked(paramisBlocked);
    setImBlocked(paramimBlocked);
    setIsEmpty(paramEmpty);
    if (paramController != null) setScrollController(paramController);
  }
}
