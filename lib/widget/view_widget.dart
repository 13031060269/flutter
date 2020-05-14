import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lwp/base/base_config.dart';
import 'package:flutter_lwp/base/base_config_PageConfig.auto.g.dart';
import 'package:provider/provider.dart';

class ViewWidget<P extends PageConfig> extends StatelessWidget {
  final P page = autoPageConfigCreate<P>();
  final Map<String, dynamic> parameters = {};

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: WillPopScope(
          child: Container(
              color: page.background(),
              child: SafeArea(
                top: page.topSafe(),
                child: MultiProvider(
                  providers: [page.getProvider(parameters), ...getProviders()],
                  child: getChild(),
                ),
              )),
          onWillPop: page.willPopCallback,
        ),
      ),
    );
  }

  getProviders() => const [];

  getChild() => page.consumer();
}
