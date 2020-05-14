import 'package:flutter/cupertino.dart';
import 'package:auto_construction/auto_construction.dart';

@AutoConstruction()
class BaseNotifier with ChangeNotifier {
  void onCreate() {}

  void reLoad() {}
}
