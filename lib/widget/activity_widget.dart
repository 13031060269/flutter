import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lwp/base/base_config.dart';
import 'package:flutter_lwp/base/shade_notifier.dart';
import 'package:flutter_lwp/base/toast_notifier.dart';
import 'package:provider/provider.dart';

import 'error_widget.dart';
import 'loading_widget.dart';
import 'toast_widget.dart';
import 'view_widget.dart';

class ActivityWidget<P extends PageConfig> extends ViewWidget<P> {
  @override
  getProviders() => [
        ChangeNotifierProvider(
          create: (c) => ShadeNotifier(),
        ),
        ChangeNotifierProvider.value(
          value: toastNotifier,
        )
      ];

  @override
  getChild() => Stack(
        children: <Widget>[
          page.consumer(),
          Consumer<ShadeNotifier>(builder: (context, notifier, _) {
            page.getNotifier(context)?.setShadeNotifier(notifier);
            return notifier.error
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: CusErrorWidget()..bgColor,
                    onTap: () {
                      page.getNotifier(context)?.reLoad();
                      notifier.hideError();
                    },
                  )
                : notifier.loading ? LoadingWidget() : Container();
          }),
          Consumer<ToastNotifier>(
              builder: (context, notifier, _) => ToastWidget(notifier.toast))
        ],
      );
}