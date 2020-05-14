import 'package:flutter/cupertino.dart';
import 'package:flutterapp/base/base_notifier.dart';
import 'package:flutterapp/base/base_page.dart';
import 'package:flutterapp/widget/tab_control_widget.dart';

class HomePage with BasePage {
  @override
  Widget build(BuildContext context, BaseNotifier value) {
    return TabControlWidget(
      [
        TabPage.string("title", Text("data")),
        TabPage.string("title2", Text("data2")),
        TabPage.string("title3", Text("data3")),
        TabPage.string("title4", Text("data4")),
      ],
      bottom: false,
      tabChange: (index) {
        print("index==$index");
      },
    );
  }
}
