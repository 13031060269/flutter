import 'package:flutter/material.dart';
import 'package:flutter_lwp/base/activity.dart';

class ThirdFragment extends Fragment{
  @override
  Color background() {
    return Colors.red;
  }
  @override
  Widget buildBody(BuildContext context) {
    return Text("$this");
  }
}