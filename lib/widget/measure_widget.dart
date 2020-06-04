import 'package:flutter/cupertino.dart';
import 'package:flutter_lwp/utils/utils.dart';

class MeasureWidget extends StatelessWidget {
  final Widget child;
  final ValueChanged<Size> size;

  MeasureWidget({this.child, this.size});

  @override
  Widget build(BuildContext context) {
    if (size != null) {
      after(() {
        size(context.size);
      });
    }
    return child ?? Container();
  }
}
