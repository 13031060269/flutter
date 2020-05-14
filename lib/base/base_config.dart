import 'package:auto_construction/auto_construction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lwp/base/base_notifier.dart';
import 'package:flutter_lwp/utils/utils.dart';
import 'package:provider/provider.dart';

import 'base_notifier_BaseNotifier.auto.g.dart';

@AutoConstruction()
abstract class PageConfig<T extends BaseNotifier> {
  Future<bool> willPopCallback() async => true;

  PreferredSizeWidget appBar() => null;

  Color background() => Colors.transparent;

  bool topSafe() => true;

  ChangeNotifierProvider<T> getProvider(Map<String, dynamic> parameters) =>
      ChangeNotifierProvider<T>(
        create: (context) {
          T provider = autoBaseNotifierCreate<T>();
          provider.parameters.addAll(parameters);
          after(() {
            provider.onCreate(context);
          });
          return provider;
        },
      );

  Widget consumer() => Consumer<T>(builder: (context, value, _) {
        return build(context, value);
      });

  T getNotifier(BuildContext context) =>
      (Provider.of<T>(context, listen: false));

  Widget build(BuildContext context, T value);

  Widget buildRoot(BuildContext context, Widget child) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: WillPopScope(
          child: Container(
              color: background(),
              child: SafeArea(
                top: topSafe(),
                child: child,
              )),
          onWillPop: willPopCallback,
        ),
      ),
    );
  }
}
