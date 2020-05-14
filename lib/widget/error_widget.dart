import 'package:flutter/material.dart';

class CusErrorWidget extends StatelessWidget {
  final Color bgColor;

  CusErrorWidget([this.bgColor = Colors.white]);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: bgColor,
      alignment: Alignment.center,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "images/icon_none.png",
              height: 107,
              width: 137,
            ),
            Padding(
              padding: EdgeInsets.only(top: 36),
              child: Text(
                "网络错误",
                style: TextStyle(fontSize: 16, color: Color(0xffb7b7b7)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
