import 'package:flutter/cupertino.dart';
import 'package:flutter_lwp/base/base_notifier.dart';
import 'package:flutter_lwp/base/base_config.dart';
import 'package:flutter_lwp/ui/home/second_page.dart';
import 'package:flutter_lwp/widget/tab_control_widget.dart';

class HomePage with PageConfig {
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
        value.startPage<SecondPage>(context);
      },
    );
  }

  @override
  bool topSafe() {
    return false;
  }
}
