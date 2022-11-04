class MyNotification {
  final String _title;
  final String _description;
  String get notificationTitle => _title;
  String get notificationDescription => _description;
  const MyNotification(this._title, this._description);
}
