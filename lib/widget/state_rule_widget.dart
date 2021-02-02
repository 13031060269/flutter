import 'package:flutter/cupertino.dart';

class StateRuleWidget extends StatefulWidget{
  final Widget widget;
  StateRuleWidget(this.widget);
  @override
  State<StatefulWidget> createState() {
    return _StateRuleState();
  }
}
class _StateRuleState extends State<StateRuleWidget> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.widget;
  }

  @override
  bool get wantKeepAlive => true;
}
