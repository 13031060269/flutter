import 'package:flutter/cupertino.dart';
import 'package:flutter_lwp/base/data_life.dart';

class HomeRule extends ViewRule<HomeDataLife> {
  @override
  bool topSafe() {
    return true;
  }

  @override
  Widget build(BuildContext context, DataLifeWhole dataLifeWhole) {
    return GestureDetector(
      onTap: () {
        dataLifeWhole.shadeNotifier()?.showError();
      },
      child: Text("$this"),
    );
  }
}

class HomeDataLife extends DataLifeWhole {
  @override
  void reLoad() {
    shadeNotifier()?.showLoading();
    Future.delayed(Duration(seconds: 2), () {
      shadeNotifier()?.dismissLoading();
    });
  }
}
