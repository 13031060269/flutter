import 'package:flutter/material.dart';
import 'package:flutter_lwp/base/activity.dart';
import 'package:flutter_lwp/base/toast_notifier.dart';
import 'package:flutter_lwp/ui/home/second_activity.dart';

class SecondFragment extends Fragment{
  @override
  bool topSafe() {
    return true;
  }
  @override
  Future<bool> onWillPop() async{
    showToast("点了一下");
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: ()=>this.startActivity<SecondActivity>(),
      child: Text("$this"),);
  }
}