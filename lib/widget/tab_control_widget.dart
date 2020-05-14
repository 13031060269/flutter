import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabControlWidget extends StatefulWidget {
  final bool bottom;
  final List<Tab> bars = [];
  final List<Widget> bodes = [];
  final double barHeight;
  double topHeight = 0;
  final ValueChanged<int> tabChange;

  TabControlWidget(List<TabPage> tabBeans,
      {this.bottom = true, this.barHeight = 80, this.tabChange}) {
    tabBeans.forEach((element) {
      bars.add(element.tab);
      bodes.add(element.body);
      if (!bottom) {
        topHeight = MediaQueryData.fromWindow(window).padding.top;
      }
    });
  }

  @override
  State<StatefulWidget> createState() {
    return _TabControlState();
  }
}

class _TabControlState extends State<TabControlWidget>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    if (_tabController == null ||
        _tabController.length != widget.bodes.length) {
      int index = _tabController?.index ?? 0;
      if (index >= widget.bodes.length) {
        index = widget.bodes.length - 1;
      }
      _tabController?.dispose();
      _tabController = TabController(
          vsync: this, length: widget.bodes.length, initialIndex: index);

      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          if (widget.tabChange != null) {
            widget.tabChange(_tabController.index);
          }
        }
      });
    }

    Widget appBar;
    Widget body = TabBarView(
      physics: widget.bottom ? NeverScrollableScrollPhysics() : null,
      controller: _tabController,
      children: widget.bodes,
    );
    Widget bottomNavigationBar;
    Widget title = PreferredSize(
        child: Container(
          color: Colors.blue,
          width: double.infinity,
          padding: EdgeInsets.only(top: widget.topHeight),
          height: widget.barHeight,
          child: TabBar(
            indicator: BoxDecoration(
//                    gradient:
//                        LinearGradient(colors: [Colors.yellow, Colors.yellow])
                ),
            controller: this._tabController,
            tabs: widget.bars,
          ),
        ),
        preferredSize:
            Size(double.infinity, widget.barHeight + widget.topHeight));
    if (widget.bottom) {
      bottomNavigationBar = title;
    } else {
      appBar = title;
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class TabPage {
  Tab tab;
  Widget body;

  TabPage(this.tab, this.body);

  factory TabPage.string(String title, Widget body) =>
      TabPage(Tab(text: title), body);
}
