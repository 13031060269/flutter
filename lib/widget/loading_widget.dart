import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.black12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                  height: 40,
                  width: 40,
                )
              ],
            ),
            height: 100,
            width: 100,
          ),
        ),
        onTap: () {},
        onDoubleTap: () {},
        onVerticalDragUpdate: (d) {},
        onHorizontalDragUpdate: (d) {},
        behavior: HitTestBehavior.opaque,
      ),
      height: double.infinity,
      width: double.infinity,
    );
  }
}
