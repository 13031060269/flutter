import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_lwp/base/data_life.dart';
import 'package:flutter_lwp/base/toast_notifier.dart';

class HomeRule extends ViewRule<DataLifeWhole> {
  @override
  bool topSafe() {
    return true;
  }
  @override
  Widget build(BuildContext context, DataLifeWhole view) {
    return GestureDetector(
      onTap: () {
        showToast("msg");
      },
      child: Text("$this"),
    );
  }
}
