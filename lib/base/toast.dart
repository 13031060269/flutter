import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lwp/base/safe_notifier.dart';
import 'package:flutter_lwp/utils/utils.dart';

ToastNotifier toastNotifier = ToastNotifier();

class ToastNotifier extends SafeNotifier {
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

class _ToastWidget extends StatelessWidget {
  final String msg;

  _ToastWidget(this.msg);

  @override
  Widget build(BuildContext context) {
    if (Utils.isEmpty(msg)) {
      return Container();
    }
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 100),
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Color(0x88000000),
              borderRadius: BorderRadius.circular(6.0)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              msg,
              style: TextStyle(fontSize: 14, color: Colors.white),
              softWrap: true,
            ),
          ),
        ));
  }
}

Widget toast() => _ToastWidget(toastNotifier.toast);
