import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lwp/base/base_config.dart';
import 'package:flutter_lwp/base/base_page_PageConfig.auto.g.dart';
import 'package:provider/provider.dart';

class ViewWidget<P extends PageConfig> extends StatelessWidget {
  final P page = autoPageConfigCreate<P>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [page.getProvider(), ...getProviders()],
      child: getChild(),
    );
  }

  getProviders() => const [];

  getChild() => page.consumer();
}
