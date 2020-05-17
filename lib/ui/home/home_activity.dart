import 'package:flutter/cupertino.dart';
import 'package:flutter_lwp/base/activity.dart';
import 'package:flutter_lwp/ui/home/first_fragment.dart';
import 'package:flutter_lwp/ui/home/second_fragment.dart';
import 'package:flutter_lwp/ui/home/third_fragment.dart';
import 'package:flutter_lwp/widget/tab_control_widget.dart';

class HomeActivity extends Activity {
  @override
  bool topSafe() {
    return false;
  }
  @override
  Widget buildBody(BuildContext context) {
    return TabControlWidget([
      TabPage.string("Tab1", fragment<FirstFragment>(this)),
      TabPage.string("Tab2", fragment<SecondFragment>(this)),
      TabPage.string("Tab2", fragment<ThirdFragment>(this)),
    ],bottom: true,);
  }
}
