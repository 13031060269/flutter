import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabControlWidget extends StatefulWidget {
  final bool bottom;
  final List<Tab> bars = [];
  final List<Widget> bodes = [];
  final double barHeight;
  final ValueChanged<int> tabChange;

  TabControlWidget(List<TabPage> tabBeans,
      {this.bottom = true, this.barHeight = 80, this.tabChange}) {
    tabBeans.forEach((element) {
      bars.add(element.tab);
      bodes.add(element.body);
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
  PageController _pageController;

  @override
  Widget build(BuildContext context) {
    double topHeight = 0;
    if (!widget.bottom) {
      topHeight = MediaQueryData.fromWindow(window).padding.top;
    }
    if (_tabController == null ||
        _tabController.length != widget.bodes.length) {
      _pageController?.dispose();
      int index = _tabController?.index ?? 0;
      _pageController = PageController(initialPage: index);
      if (index >= widget.bodes.length) {
        index = widget.bodes.length - 1;
      }
      _tabController?.dispose();
      _tabController = TabController(
          vsync: this, length: widget.bodes.length, initialIndex: index);
      _tabController.addListener(() {
        if (_pageController.page.round() != _tabController.index) {
          _pageController.jumpToPage(_tabController.index);
        }
      });
    }

    Widget appBar;
    Widget body = PageView(
      physics: widget.bottom ? NeverScrollableScrollPhysics() : null,
      controller: _pageController,
      children: widget.bodes,
      onPageChanged: (index) async {
        _tabController.animateTo(index, duration: Duration(milliseconds: 300));
        if (widget.tabChange != null) {
          widget.tabChange(_tabController.index);
        }
      },
    );
    Widget bottomNavigationBar;
    Widget title = PreferredSize(
        child: Container(
          color: Colors.blue,
          width: double.infinity,
          padding: EdgeInsets.only(top: topHeight),
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
        preferredSize: Size(double.infinity, widget.barHeight + topHeight));
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

  @override
  void dispose() {
    super.dispose();
    _pageController?.dispose();
    _tabController?.dispose();
  }
}

class TabPage {
  Tab tab;
  Widget body;

  TabPage(this.tab, this.body);

  factory TabPage.string(String title, Widget body) =>
      TabPage(Tab(text: title), body);
}

//typedef BuildChild<T> = Widget Function(BuildContext context, T child);
