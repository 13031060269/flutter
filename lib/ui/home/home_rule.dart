import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lwp/base/data_life.dart';
import 'package:flutter_lwp/widget/refresh_grid_view.dart';
import 'package:flutter_lwp/widget/tab_control_widget.dart';

class HomeRule extends ViewRule<HomeDataLife> {
  @override
  bool topSafe() {
    return true;
  }

  @override
  Widget build(BuildContext context, HomeDataLife dataLifeWhole) {
    return TabControlWidget([
      TabPage.string(
          "第一个",
          RefreshGridView(
            itemBuilder: _itemBuilder,
            rowCount: HomeDataLife.rowCount,
            itemCount: dataLifeWhole.data.length,
            onLoadMore: dataLifeWhole.onLoadMore,
            onRefresh: dataLifeWhole.onRefresh,
            isLastPage: dataLifeWhole.isLastPage(),
          )),
      TabPage.string("第二个", Text("data"))
    ]);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Text("$index");
  }
}

class HomeDataLife extends DataLifeWhole {
  List<int> data = [];
  static final int rowCount = 2;

  HomeDataLife() : super() {
    addOnePage();
  }

  addOnePage() async {
    int start = data.length;
    for (int i = 0; i < 100; i++) {
      data.add(start + i);
    }
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void reLoad() {
    shadeNotifier()?.showLoading();
    Future.delayed(Duration(seconds: 2), () {
      shadeNotifier()?.dismissLoading();
    });
  }

  Future<void> onLoadMore() async {
    await addOnePage();
    notifyListeners();
  }

  Future<void> onRefresh() async {
    data.clear();
    await addOnePage();
    notifyListeners();
  }

  bool isLastPage() {
    return data.length > 400;
  }
}
