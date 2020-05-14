import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterapp/base/base_page.dart';
import 'package:flutterapp/base/base_page_BasePage.auto.g.dart';
import 'package:flutterapp/base/shade_notifier.dart';
import 'package:flutterapp/base/toast_notifier.dart';
import 'package:flutterapp/widget/toast_widget.dart';
import 'package:provider/provider.dart';

import 'error_widget.dart';
import 'loading_widget.dart';

class ActivityWidget<P extends BasePage> extends StatelessWidget {
  final P page = autoBasePageCreate<P>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: WillPopScope(
          child: SafeArea(
            child: MultiProvider(
              providers: [
                page.getProvider(),
                ChangeNotifierProvider(
                  create: (c) => ShadeNotifier(),
                ),
                ChangeNotifierProvider.value(
                  value: toastNotifier,
                )
              ],
              child: Stack(
                children: <Widget>[
                  page.consumer(),
                  Consumer<ShadeNotifier>(
                      builder: (context, notifier, _) => notifier.error
                          ? GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: CusErrorWidget()..bgColor,
                              onTap: () {
                                page.getNotifier(context)?.reLoad();
                                ShadeNotifier.get(context)?.hideError();
                              },
                            )
                          : notifier.loading ? LoadingWidget() : Container()),
                  Consumer<ToastNotifier>(
                      builder: (context, notifier, _) =>
                          ToastWidget(notifier.toast))
                ],
              ),
            ),
          ),
          onWillPop: page.willPopCallback,
        ),
      ),
    );
  }
}
