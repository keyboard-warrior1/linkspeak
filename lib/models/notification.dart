class MyNotification {
  final String _title;
  String get notificationTitle => _title;

  final String _description;
  String get notificationDescription => _description;

  // final DateTime _date;
  // DateTime get notificationDate => _date;
  
 MyNotification(this._title, this._description);
}
