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

const String ACTIVITY = "activity";

abstract class View extends SafeNotifier {
  final Map<String, dynamic> data = {};
  BuildContext context;

  void onContextChange(BuildContext context, Map<String, dynamic> map) {
    this.context = context;
  }

  Widget build(BuildContext context);

  @mustCallSuper
  @override
  void dispose() {
    context = null;
    data.clear();
    super.dispose();
  }

  static T of<T>(BuildContext context) =>
      Provider.of<T>(context, listen: false);
}

abstract class Fragment extends View {
  bool _isStop = false;

  bool get isStop => _isStop;

  bool topSafe() => false;

  Color background() => Colors.transparent;

  Future<bool> onWillPop() async => true;

  SystemUiOverlayStyle style() => SystemUiOverlayStyle.dark;

  void reLoad() {}

  @mustCallSuper
  void onCreate(BuildContext context) async {
    this.context = context;
    var activity = data[ACTIVITY] as Activity;
    activity?._fragments?.add(this);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: buildBody(context),
                ),
              )),
          onWillPop: onWillPop,
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context);

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

abstract class Activity extends Fragment with WidgetsBindingObserver {
  List<Fragment> _fragments = [];

  @override
  bool topSafe() => true;

  @override
  void onCreate(BuildContext context) {
    super.onCreate(context);
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
      return value.build(context);
    }, ChangeNotifierProvider<T>(
      create: (context) {
        var provider = autoSafeNotifierCreate<T>();
        provider.data.addAll(_data);
        _data.clear();
        after(() {
          onCreate(context, provider);
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

  onCreate(BuildContext buildContext, T value) {}

  _addConfig(List<_Config> configs) {}
}

class _IncludeFragment<T extends Fragment> extends _Include<T> {
  @override
  onCreate(BuildContext buildContext, T value) {
    value.onCreate(buildContext);
  }

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

class _IncludeActivity<T extends Activity> extends _IncludeFragment<T> {
  @override
  _addConfig(List<_Config> configs) {
    super._addConfig(configs);
    configs.add(_Config<ToastNotifier>(
        (context, value, child) => ToastWidget(value.toast)));
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

Widget view<T extends View>({
  Map<String, dynamic> parameters,
}) =>
    _Include<T>().._data.addAll(parameters ?? {});

Widget fragment<T extends Fragment>(
  Activity activity, {
  Map<String, dynamic> parameters,
}) {
  var includeFragment = _IncludeFragment<T>()
    .._data.addAll({ACTIVITY: activity, ...parameters ?? {}});
  return includeFragment;
}

Widget activity<T extends Activity>([Map<String, dynamic> parameters]) =>
    _IncludeActivity<T>().._data.addAll(parameters ?? {});

Future<dynamic> startActivity<T extends Activity>(Activity act,
    {Map<String, dynamic> parameters}) async {
  assert(act != null, "act 不能为null");
  act.onStop();
  var result = await Navigator.push(
    act.context,
    CupertinoPageRoute(builder: (contextBuild) => activity<T>(parameters)),
  );
  act.onRestart();
  return result;
}
