import 'package:flutter/cupertino.dart';

class SafeNotifier with ChangeNotifier {
  @override
  void notifyListeners() {
    try {
      super.notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
