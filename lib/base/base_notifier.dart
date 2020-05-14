import 'package:flutter/cupertino.dart';
import 'package:auto_construction/auto_construction.dart';
import 'package:flutter_lwp/base/toast_notifier.dart';
import 'package:flutter_lwp/utils/utils.dart';

import 'base_config.dart';

@AutoConstruction()
class BaseNotifier with ChangeNotifier, WidgetsBindingObserver {
  bool _isStop = false;

  void onCreate(BuildContext context) {
    printLog("onCreate");
    WidgetsBinding.instance.addObserver(this);
    showToast("onCreate");
  }

  void onStop(BuildContext context) {
    didChangeAppLifecycleState(AppLifecycleState.paused);
    _isStop = true;
  }

  void onRestart(BuildContext context) {
    _isStop = false;
    didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  void reLoad() {}

  startPage<T extends PageConfig>(BuildContext context) async {
    startActivity<T>(context, this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isStop) return;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    printLog("dispose");
    super.dispose();
  }
}
