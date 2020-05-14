import 'package:flutter/cupertino.dart';
import 'package:flutterapp/base/base_notifier.dart';
import 'package:auto_construction/auto_construction.dart';
import 'package:provider/provider.dart';

import 'base_notifier_BaseNotifier.auto.g.dart';

@AutoConstruction()
abstract class BasePage<T extends BaseNotifier> {
  Future<bool> willPopCallback() async => true;

  ChangeNotifierProvider<T> getProvider() => ChangeNotifierProvider<T>(
        create: (c) {
          T provider = autoBaseNotifierCreate<T>();
          provider.onCreate();
          return provider;
        },
      );

  Widget consumer() => Consumer<T>(builder: (context, value, _) {
        return build(context, value);
      });

  T getNotifier(BuildContext context) =>
      (Provider.of<T>(context, listen: false));

  Widget build(BuildContext context, T value);
}
