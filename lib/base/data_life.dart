import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwp/base/safe_notifier_SafeNotifier.auto.g.dart';
import 'package:flutter_lwp/base/shade.dart';
import 'package:flutter_lwp/base/toast.dart';
import 'package:flutter_lwp/utils/utils.dart';
import 'package:provider/provider.dart';

import 'safe_notifier.dart';

const String PARENT = "parent";
const String ROUTE = "route";

_Config _shade<T>() => _Config<ShadeNotifier>(
    (context, value, child) => ShadeWidget.simple(value, () {
          (DataLife.of<T>(context) as DataLifeBar)?.reLoad();
          value.hideError();
        }));

_Config _toast() => _Config<ToastNotifier>((context, value, child) => toast(),
    ChangeNotifierProvider<ToastNotifier>.value(value: toastNotifier));

abstract class ViewRule<T extends DataLife> {
  PreferredSizeWidget appBar() => null;

  bool topSafe() => false;

  Color background() => Colors.transparent;

  Future<bool> onWillPop() async => true;

  SystemUiOverlayStyle style() => SystemUiOverlayStyle.dark;

  Widget _build(BuildContext context, T dataLife) {
    var widget = build(context, dataLife);
    if (isMatch<T, DataLifeBar>()) {
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

  final Map<String, dynamic> parameters = {};
  BuildContext context;

  @mustCallSuper
  void _onAttach(DataLifeWhole parent) {
    this._parent = parent;
  }

  void onContextChange(Map<String, dynamic> map) {}

  Future<dynamic> startRule<T extends DataLifeWhole>(ViewRule<T> help,
      [Map<String, dynamic> parameters]) async {
    return parent?.startRule<T>(help, parameters);
  }

  @mustCallSuper
  @override
  void dispose() {
    context = null;
    _parent = null;
    parameters.clear();
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
  final ViewRule _help;

  _Include(this._data, this._help);

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
    return _IncludeLess<T>(widget._data, widget._help);
  }

  @override
  bool get wantKeepAlive => true;
}

class _IncludeLess<T extends DataLife> extends StatelessWidget {
  final Map<String, dynamic> _data;
  final ViewRule _help;

  _IncludeLess(this._data, this._help);

  @override
  Widget build(BuildContext context) {
    _Config config = _Config<T>((context, value, child) {
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
        var provider = autoSafeNotifierCreate<T>()..parameters.addAll(_data);
        if (kReleaseMode) {
          after(() {
            provider._onAttach(_data.remove(PARENT));
            _data.clear();
          });
        }
        return provider;
      },
    ));
    if (isMatch<T, DataLifeBar>()) {
      List<InheritedProvider> providers = [config.provider()];
      List<Consumer> consumers = [config.child()];
      config = _shade<T>();
      providers.add(config.provider());
      consumers.add(config.child());
      if (isMatch<T, DataLifeWhole>()) {
        config = _toast();
        providers.add(config.provider());
        consumers.add(config.child());
        return Scaffold(
          body: MultiProvider(
              providers: providers,
              child: Stack(
                children: <Widget>[...consumers],
              )),
        );
      } else {
        return MultiProvider(
            providers: providers,
            child: Stack(
              children: <Widget>[...consumers],
            ));
      }
    } else {
      return MultiProvider(
          providers: [config.provider()], child: config.child());
    }
  }
}

class DataLifeBar extends DataLife {
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

class DataLifeWhole extends DataLifeBar with WidgetsBindingObserver {
  HashSet<DataLifeBar> _fragments = HashSet();
  WrapRoute _wrapRoute;

  DataLifeWhole() {
    tasks.add(this);
  }

  void addFragment(DataLifeBar fragment) {
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
  Future<dynamic> startRule<T extends DataLifeWhole>(ViewRule<T> help,
      [Map<String, dynamic> parameters]) async {
    return _launchRule<T>(this, help, parameters: parameters);
  }

  @override
  void _onAttach(DataLifeWhole parent) {
    super._onAttach(parent);
    _wrapRoute = parameters[ROUTE];
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

Widget rule<T extends DataLife>(ViewRule<T> rule,
    {DataLifeWhole parent,
    Map<String, dynamic> parameters = const {},
    bool less = false}) {
  if (less) {
    return _IncludeLess<T>({PARENT: parent, ...parameters}, rule);
  } else {
    return _Include<T>({PARENT: parent, ...parameters}, rule);
  }
}

Future<dynamic> _launchRule<T extends DataLifeWhole>(
    DataLifeWhole parent, ViewRule<T> mRule,
    {Map<String, dynamic> parameters = const {}}) async {
  printLog(T);
  parent.onStop();
  WrapRoute wrapRoute = WrapRoute();
  var route = CupertinoPageRoute(
      builder: (contextBuild) => rule<T>(mRule,
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

bool isMatch<T, D>() {
  return <T>[] is List<D>;
}

class WrapRoute {
  Route route;
}
