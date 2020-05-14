import 'package:flutter/material.dart';
import 'package:flutter_lwp/utils/utils.dart';

class ToastWidget extends StatelessWidget {
  final String msg;

  ToastWidget(this.msg);

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