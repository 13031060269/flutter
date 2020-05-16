import 'package:flutter/cupertino.dart';
import 'package:auto_construction/auto_construction.dart';
import 'package:flutter_lwp/base/shade_notifier.dart';
import 'package:flutter_lwp/utils/utils.dart';

import 'safe_notifier.dart';

@AutoConstruction()
class BaseNotifier extends SafeNotifier with WidgetsBindingObserver {
  bool _isStop = false;
  final Map<String, dynamic> parameters = {};
  ShadeNotifier _shadeNotifier;
  BuildContext _context;

  void setContext(BuildContext context) {
    this._context = context;
  }

  void setShadeNotifier(ShadeNotifier shadeNotifier) {
    this._shadeNotifier = shadeNotifier;
  }

  void onCreate() async {
    WidgetsBinding.instance.addObserver(this);
    _shadeNotifier?.showLoading();
    Future.delayed(Duration(seconds: 2), () {
      _shadeNotifier?.dismissLoading();
    });
  }

  void onStop() {
    didChangeAppLifecycleState(AppLifecycleState.paused);
    _isStop = true;
  }

  void onRestart() {
    _isStop = false;
    didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  void reLoad() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isStop) return;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        onResume();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  void onResume() {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
