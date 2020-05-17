import 'package:flutter/material.dart';
import 'package:flutter_lwp/base/activity.dart';

class FirstFragment extends Fragment{
  @override
  bool topSafe() {
    return true;
  }
  @override
  Widget buildBody(BuildContext context) {
    return Text("$this");
  }
}