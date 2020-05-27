import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwp/base/safe_notifier_SafeNotifier.auto.g.dart';
import 'package:flutter_lwp/base/shade_notifier.dart';
import 'package:flutter_lwp/base/toast_notifier.dart';
import 'package:flutter_lwp/utils/utils.dart';
import 'package:flutter_lwp/widget/error_widget.dart';
import 'package:flutter_lwp/widget/loading_widget.dart';
import 'package:flutter_lwp/widget/toast_widget.dart';
import 'package:provider/provider.dart';

import 'safe_notifier.dart';

const String PARENT = "parent";

abstract class View extends SafeNotifier {
  Activity parent;
  final Map<String, dynamic> data = {};
  BuildContext context;

  @mustCallSuper
  void _onAttach(Activity parent, BuildContext context) {
    this.parent = parent;
    this.context = context;
  }

  void onContextChange(BuildContext context, Map<String, dynamic> map) {
    this.context = context;
  }

  Widget _build(BuildContext context) {
    return build(context);
  }

  Future<dynamic> startActivity<T extends Activity>(
      [Map<String, dynamic> parameters]) async {
    return parent?.startOther<T>(parameters);
  }

  Widget build(BuildContext context);

  @mustCallSuper
  @override
  void dispose() {
    context = null;
    parent = null;
    data.clear();
    super.dispose();
  }

  ShadeNotifier shadeNotifier() => ShadeNotifier.get(context);

  static T of<T>(BuildContext context) =>
      Provider.of<T>(context, listen: false);
}

class _Include<T extends View> extends StatelessWidget {
  final Map<String, dynamic> _data = {};

  @override
  Widget build(BuildContext context) {
    List<_Config> configs = [];
    List<InheritedProvider> providers = [];
    List<Consumer> consumers = [];
    configs.add(_Config<T>((context, value, child) {
      after(() {
        value.onContextChange(context, _data);
        _data.clear();
      });
      return value._build(context);
    }, ChangeNotifierProvider<T>(
      create: (context) {
        var provider = autoSafeNotifierCreate<T>()..data.addAll(_data);
        after(() {
          provider._onAttach(_data.remove(PARENT), context);
          _data.clear();
        });
        return provider;
      },
    )));
    _addConfig(configs);
    configs.forEach((element) {
      providers.add(element.provider());
      consumers.add(element.child());
    });
    return MultiProvider(
        providers: providers,
        child: Stack(
          children: <Widget>[...consumers],
        ));
  }

  _addConfig(List<_Config> configs) {}
}

abstract class Fragment extends View {
  bool _isStop = false;

  bool get isStop => _isStop;

  bool topSafe() => false;

  Color background() => Colors.transparent;

  Future<bool> onWillPop() async => true;

  SystemUiOverlayStyle style() => SystemUiOverlayStyle.dark;

  void reLoad() {}

  @override
  void _onAttach(Activity parent, BuildContext context) {
    super._onAttach(parent, context);
    parent?.addFragment(this);
  }

  @override
  Widget _build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style(),
      child: Scaffold(
        appBar: appBar(),
        body: WillPopScope(
          child: Container(
              color: background(),
              child: SafeArea(
                top: topSafe(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: build(context),
                ),
              )),
          onWillPop: onWillPop,
        ),
      ),
    );
  }

  @mustCallSuper
  void onRestart() {
    _isStop = false;
  }

  @mustCallSuper
  void onStop() {
    _isStop = true;
  }

  appBar() {}
}

class _IncludeFragment<T extends Fragment> extends _Include<T> {
  @override
  _addConfig(List<_Config> configs) {
    super._addConfig(configs);
    configs.add(_Config<ShadeNotifier>((context, value, child) => value.error
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: CusErrorWidget(),
            onTap: () {
              View.of<T>(context)?.reLoad();
              value.hideError();
            },
          )
        : LoadingWidget(value.loading)));
  }
}

abstract class Activity extends Fragment with WidgetsBindingObserver {
  HashSet<Fragment> _fragments = HashSet();

  @override
  bool topSafe() => true;

  void addFragment(Fragment fragment) {
    if (fragment != this) {
      _fragments.add(fragment);
    }
  }

  @override
  void _onAttach(Activity parent, BuildContext context) {
    super._onAttach(parent, context);
    WidgetsBinding.instance.addObserver(this);
  }

  void onRestart() {
    super.onRestart();
    _fragments.forEach((element) {
      element.onRestart();
    });
  }

  @override
  void onStop() {
    super.onStop();
    _fragments.forEach((element) {
      element.onStop();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isStop) return;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        onRestart();
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
    _fragments.clear();
    super.dispose();
  }

  Future<dynamic> startOther<T extends Activity>(
      [Map<String, dynamic> parameters]) async {
    Activity activity = this;
    while (activity.parent != null) {
      activity = activity.parent;
    }
    return startActivity<T>(activity, parameters);
  }
}

class _IncludeActivity<T extends Activity> extends _IncludeFragment<T> {
  @override
  _addConfig(List<_Config> configs) {
    super._addConfig(configs);
    configs.add(_Config<ToastNotifier>(
        (context, value, child) => ToastWidget(value.toast),
        ChangeNotifierProvider<ToastNotifier>.value(value: toastNotifier)));
  }
}

class _Config<T extends SafeNotifier> {
  final Widget Function(BuildContext context, T value, Widget child) builder;
  ChangeNotifierProvider _provider;

  _Config(this.builder, [this._provider]);

  ChangeNotifierProvider<T> provider() =>
      _provider ??
      ChangeNotifierProvider(create: (context) => autoSafeNotifierCreate<T>());

  Consumer<T> child() => Consumer<T>(
        builder: builder,
      );
}

Widget view<T extends View>([
  Activity parent,
  Map<String, dynamic> parameters,
]) =>
    _Include<T>().._data.addAll({PARENT: activity, ...parameters ?? {}});

Widget fragment<T extends Fragment>(
  Activity activity, [
  Map<String, dynamic> parameters,
]) =>
    _IncludeFragment<T>()
      .._data.addAll({PARENT: activity, ...parameters ?? {}});

Widget activity<T extends Activity>([Map<String, dynamic> parameters]) =>
    _IncludeActivity<T>().._data.addAll(parameters ?? {});

Future<dynamic> startActivity<T extends Activity>(Activity parent,
    [Map<String, dynamic> parameters]) async {
  parent.onStop();
  var result = await Navigator.push(
    parent.context,
    CupertinoPageRoute(
        builder: (contextBuild) =>
            activity<T>({PARENT: parent, ...parameters ?? {}})),
  );
  parent.onRestart();
  return result;
}
