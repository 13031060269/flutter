import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lwp/base/data_life.dart';
import 'package:flutter_lwp/utils/utils.dart';
import 'package:flutter_lwp/widget/refresh_grid_view.dart';

class HomeRule extends ViewRule<HomeDataLife> {
  @override
  bool topSafe() {
    return true;
  }

  @override
  Widget build(BuildContext context, DataLifeWhole dataLifeWhole) {
    return RefreshGridView(
      itemBuilder: (item, index) {
        return Text("$index");
      },
      rowCount: 2,
      itemCount: 100,
      onLoadMore: () async {
        printLog("onLoadMore");
        await Future.delayed(Duration(seconds: 2));
      },
      onRefresh: () async {
        printLog("onRefresh");
        await Future.delayed(Duration(seconds: 2));
      },
      isLastPage: false,
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
