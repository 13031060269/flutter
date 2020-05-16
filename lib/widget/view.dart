import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwp/base/base_notifier.dart';
import 'package:flutter_lwp/base/safe_notifier.dart';
import 'package:flutter_lwp/base/safe_notifier_SafeNotifier.auto.g.dart';
import 'package:flutter_lwp/base/shade_notifier.dart';
import 'package:flutter_lwp/base/toast_notifier.dart';
import 'package:flutter_lwp/utils/utils.dart';
import 'package:flutter_lwp/widget/toast_widget.dart';
import 'package:provider/provider.dart';

import 'error_widget.dart';
import 'loading_widget.dart';

abstract class View<T extends BaseNotifier> extends StatelessWidget {
  final Map<String, dynamic> _parameters = {};

  @override
  Widget build(BuildContext context) {
    if (T is BaseNotifier) {
      return builder(context, null);
    } else {
      List<_Config> configs = [];
      List<InheritedProvider> providers = [];
      List<Consumer> consumers = [];
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
  }

  @mustCallSuper
  _addConfig(List<_Config> configs) {
    configs.add(_Config<T>(
        (context, value, child) => builder(context, value),
        ChangeNotifierProvider<T>(
          create: (context) => _createT(context),
        )));
  }

  Widget builder(BuildContext context, T notifier);

  T _createT(BuildContext buildContext) => autoSafeNotifierCreate<T>();
}

abstract class Fragment<T extends BaseNotifier> extends View<T> {
  PreferredSizeWidget appBar() => null;

  Color background() => Colors.transparent;

  Future<bool> willPopCallback() async => true;

  topSafe() => false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: appBar(),
        body: WillPopScope(
          child: Container(
              color: background(),
              child: SafeArea(
                top: topSafe(),
                child: super.build(context),
              )),
          onWillPop: willPopCallback,
        ),
      ),
    );
  }

  @override
  _addConfig(List<_Config> configs) {
    super._addConfig(configs);
    configs.add(_Config<ShadeNotifier>((context, value, child) => value.error
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: CusErrorWidget(),
            onTap: () {
              autoSafeNotifierCreate<T>()?.reLoad();
              value.hideError();
            },
          )
        : LoadingWidget(value.loading)));
  }
}

abstract class Activity<T extends BaseNotifier> extends Fragment<T> {
  Future<dynamic> startActivity(BuildContext context, Activity activity,
      {Map<String, dynamic> parameters, BaseNotifier notifier}) async {
    notifier?.onStop();
    if (Utils.isEmpty(parameters)) {
      activity._parameters.addAll(parameters);
    }
    var result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (contextBuild) => activity),
    );
    notifier?.onRestart();
    return result;
  }

  @override
  _addConfig(List<_Config> configs) {
    super._addConfig(configs);
    configs.add(_Config<ToastNotifier>(
        (context, value, child) => ToastWidget(value.toast)));
  }

  @override
  T _createT(BuildContext context) {
    var provider = super._createT(context);
    provider.parameters
      ..addAll(_parameters)
      ..clear();
    after(() {
      provider.onCreate();
    });
    return provider;
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
