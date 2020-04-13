class SingletonModel {
  static final SingletonModel _singleton = SingletonModel._internal();

  factory SingletonModel() {
    return _singleton;
  }

  SingletonModel._internal();

  static SingletonModel get shared {
    return _singleton;
  }

  String login;
  String fcm;
  String filter;
  String users;
}
