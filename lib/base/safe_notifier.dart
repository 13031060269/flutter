import 'package:flutter/cupertino.dart';
import 'package:auto_construction/auto_construction.dart';

@AutoConstruction()
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
