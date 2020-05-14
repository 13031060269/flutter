import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lwp/utils/utils.dart';
ToastNotifier toastNotifier = ToastNotifier();

class ToastNotifier with ChangeNotifier {
  String toast;
  Timer timer;

  _showToast(String msg) async {
    if (Utils.isEmpty(msg)) return;
    toast = msg;
    notifyListeners();
    timer?.cancel();
    timer = Timer(Duration(seconds: 2), () {
      toast = null;
      notifyListeners();
    });
  }
}

void showToast(String msg) {
  toastNotifier._showToast(msg);
}
