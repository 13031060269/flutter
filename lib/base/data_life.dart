import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
const String ROUTE = "route";

_Config _shade<T>() =>
    _Config<ShadeNotifier>((context, value, child) => value.error
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: CusErrorWidget(),
            onTap: () {
              (DataLife.of<T>(context) as DataLifePart)?.reLoad();
              value.hideError();
            },
          )
        : LoadingWidget(value.loading));

_Config _toast() => _Config<ToastNotifier>(
    (context, value, child) => ToastWidget(value.toast),
    ChangeNotifierProvider<ToastNotifier>.value(value: toastNotifier));

abstract class ViewRule<T extends DataLife> {
  PreferredSizeWidget appBar() => null;

  bool topSafe() => false;

  Color background() => Colors.transparent;

  Future<bool> onWillPop() async => true;

  SystemUiOverlayStyle style() => SystemUiOverlayStyle.dark;

  Widget _build(BuildContext context, T dataLife) {
    var widget = build(context, dataLife);
    if (<T>[] is List<DataLifePart>) {
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
                    child: widget,
                  ),
                )),
            onWillPop: onWillPop,
          ),
        ),
      );
    }
    return widget;
  }

  Widget build(BuildContext context, T view);
}

class DataLife extends SafeNotifier {
  DataLifeWhole _parent;

  DataLifeWhole get parent {
    DataLifeWhole p = _parent;
    if (_parent == null && this is DataLifeWhole) {
      p = this;
    }
    while (p._parent != null) {
      p = p._parent;
    }
    _parent = p;
    return _parent;
  }

  final Map<String, dynamic> data = {};
  BuildContext context;

  @mustCallSuper
  void _onAttach(DataLifeWhole parent) {
    this._parent = parent;
  }

  void onContextChange(Map<String, dynamic> map) {}

  Future<dynamic> startActivity<T extends DataLifeWhole>(ViewRule<T> help,
      [Map<String, dynamic> parameters]) async {
    return parent?.startActivity<T>(help, parameters);
  }

  @mustCallSuper
  @override
  void dispose() {
    context = null;
    _parent = null;
    data.clear();
    printLog(this);
    super.dispose();
  }

  ShadeNotifier shadeNotifier() => ShadeNotifier.get(context);

  static T of<T>(BuildContext context) =>
      Provider.of<T>(context, listen: false);
}

typedef AddConfig = Function(List<_Config> configs);

class _Include<T extends DataLife> extends StatefulWidget {
  final Map<String, dynamic> _data;
  final AddConfig _config;
  final ViewRule _help;

  _Include(this._data, this._help, [this._config]);

  @override
  _IncludeState createState() {
    return _IncludeState<T>();
  }
}

class _IncludeState<T extends DataLife> extends State<_Include>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _IncludeLess<T>(widget._data, widget._help, widget._config);
  }

  @override
  bool get wantKeepAlive => true;
}

class _IncludeLess<T extends DataLife> extends StatelessWidget {
  final Map<String, dynamic> _data;
  final AddConfig _config;
  final ViewRule _help;

  _IncludeLess(this._data, this._help, [this._config]);

  @override
  Widget build(BuildContext context) {
    List<_Config> configs = [];
    List<InheritedProvider> providers = [];
    List<Consumer> consumers = [];
    configs.add(_Config<T>((context, value, child) {
      value.context = context;
      after(() {
        if (!kReleaseMode) {
          value._onAttach(_data.remove(PARENT));
        }
        value.onContextChange(_data);
        _data.clear();
      });
      return _help._build(context, value);
    }, ChangeNotifierProvider<T>(
      create: (context) {
        var provider = autoSafeNotifierCreate<T>()..data.addAll(_data);
        if (kReleaseMode) {
          after(() {
            provider._onAttach(_data.remove(PARENT));
            _data.clear();
          });
        }
        return provider;
      },
    )));
    if (_config != null) {
      _config(configs);
    }
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
}

class DataLifePart extends DataLife {
  bool _isStop = false;

  bool get isStop => _isStop;

  void reLoad() {}

  @override
  void _onAttach(DataLifeWhole parent) {
    super._onAttach(parent);
    this.parent?.addFragment(this);
  }

  @mustCallSuper
  void onRestart() {
    _isStop = false;
  }

  @mustCallSuper
  void onStop() {
    _isStop = true;
  }
}

class DataLifeWhole extends DataLifePart with WidgetsBindingObserver {
  HashSet<DataLifePart> _fragments = HashSet();
  WrapRoute _wrapRoute;

  DataLifeWhole() {
    tasks.add(this);
  }

  void addFragment(DataLifePart fragment) {
    if (fragment != this) {
      _fragments.add(fragment);
    }
  }

  void setResult([dynamic result]) {
    if (_wrapRoute != null) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, result);
      } else {
        SystemNavigator.pop();
      }
    }
  }

  @override
  Future<dynamic> startActivity<T extends DataLifeWhole>(ViewRule<T> help,
      [Map<String, dynamic> parameters]) async {
    return _launchActivity<T>(this, help, parameters: parameters);
  }

  @override
  void _onAttach(DataLifeWhole parent) {
    super._onAttach(parent);
    _wrapRoute = data[ROUTE];
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
    _wrapRoute?.route = null;
    _wrapRoute = null;
    tasks.remove(this);
    super.dispose();
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

Widget view<T extends DataLife>(ViewRule<T> rule,
    {DataLifeWhole parent,
    Map<String, dynamic> parameters = const {},
    bool less = false}) {
  List<_Config> configs = [];
  if (<T>[] is List<DataLifePart>) {
    configs.add(_shade<T>());
  }
  if (<T>[] is List<DataLifeWhole>) {
    configs.add(_toast());
  }
  if (less) {
    return _IncludeLess<T>({PARENT: parent, ...parameters}, rule, (list) {
      list.addAll(configs);
    });
  } else {
    return _Include<T>({PARENT: parent, ...parameters}, rule, (list) {
      list.addAll(configs);
    });
  }
}

Future<dynamic> _launchActivity<T extends DataLifeWhole>(
    DataLifeWhole parent, ViewRule<T> rule,
    {Map<String, dynamic> parameters = const {}}) async {
  printLog(T);
  parent.onStop();
  WrapRoute wrapRoute = WrapRoute();
  var route = CupertinoPageRoute(
      builder: (contextBuild) => view<T>(rule,
          parent: parent,
          parameters: {ROUTE: wrapRoute, ...parameters ?? {}},
          less: true));
  wrapRoute..route = route;
  var result = await Navigator.push(
    parent.context,
    route,
  );
  parent.onRestart();
  return result;
}

HashSet<DataLifeWhole> tasks = HashSet();

class WrapRoute {
  Route route;
}
