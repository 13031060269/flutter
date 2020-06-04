import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lwp/widget/measure_widget.dart';

class RefreshGridView extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorXBuilder;
  final IndexedWidgetBuilder separatorYBuilder;

  ///item数量
  final int itemCount;

  ///一行个数
  final int rowCount;

  ///刷新
  final RefreshCallback onRefresh;

  ///加载更多
  final RefreshCallback onLoadMore;

  ///加载更多控件
  final Widget loadMoreWidget;

  ///当前是否为最后一页(用于是否请求加载更多)
  final bool isLastPage;

  RefreshGridView(
      {this.itemBuilder,
      this.isLastPage = true,
      this.separatorXBuilder,
      this.separatorYBuilder,
      this.itemCount = 0,
      this.rowCount = 3,
      this.onLoadMore,
      this.loadMoreWidget,
      this.onRefresh});

  @override
  State<StatefulWidget> createState() {
    return _RefreshGridViewState();
  }
}

class _RefreshGridViewState extends State<RefreshGridView> {
  ///是否正在加载更多
  bool _isLoading = false;
  double _footHeight = 0;
  ScrollController _controller;

  int get _itemCount =>
      ((widget.itemCount + widget.rowCount - 1) ~/ widget.rowCount) + 1;

  ScrollController get control {
    if (_controller == null) {
      _controller = ScrollController();
      _controller.addListener(() async {
        if (!_isLoading &&
            !widget.isLastPage &&
            _controller.offset > 0 &&
            _controller.offset >=
                _controller.position.maxScrollExtent - _footHeight * 2 / 3) {
          _isLoading = true;
          try {
            await widget.onLoadMore();
          } catch (e) {
            print(e);
          }
          Future.delayed(Duration(milliseconds: 200), () async {
            if (_controller.offset >
                _controller.position.maxScrollExtent - _footHeight) {
              await _controller.animateTo(
                  _controller.position.maxScrollExtent - _footHeight,
                  duration: Duration(milliseconds: 150),
                  curve: Curves.linear);
            }
            _isLoading = false;
          });
        }
      });
    }
    return _controller;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return _EmptyWidget();
    }
    return RefreshIndicator(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ScrollConfiguration(
                behavior: _RefreshBehavior(),
                child: ListView.separated(
                    controller: control,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: _itemBuilder,
                    separatorBuilder:
                        widget.separatorXBuilder ?? _separatorXBuilder,
                    itemCount: _itemCount)),
          )
        ],
      ),
      onRefresh: widget.onRefresh,
    );
  }

  ///默认横向分割线
  Widget _separatorXBuilder(BuildContext context, int index) {
    return Container(
      height: 1,
      color: Colors.red,
    );
  }

  ///默认纵向分割线
  Widget _separatorYBuilder(BuildContext context, int index) {
    return VerticalDivider(
      width: 1,
      color: Colors.red,
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    ///上拉加载 footView
    if (index == _itemCount - 1) {
      if (!widget.isLastPage) {
        return MeasureWidget(
          child: widget.loadMoreWidget ?? _LoadMoreWidget(),
          size: (size) {
            _footHeight = size.height;
          },
        );
      } else {
        return _LoadMoreWidget(text: "没有更多", icon: Container());
      }
    }
    int i = index * widget.rowCount;
    List<Widget> list = [];

    for (int j = 0; j < widget.rowCount; j++) {
      list.add(_getRealItem(i + j));
    }
    return Row(
      children: list,
    );
  }

  Widget _getRealItem(int index) {
    Widget child;
    if (index < widget.itemCount) {
      child = widget.itemBuilder(context, index);
    } else {
      child = Container();
    }
    return Expanded(
        child: Container(
      alignment: Alignment.center,
      child: child,
    ));
  }
}

///去除弹性效果
class _RefreshBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}

class _EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "暂无相关数据",
        style: TextStyle(fontSize: 14, color: Color(0xff505050)),
      ),
    );
  }
}

class _LoadMoreWidget extends StatelessWidget {
  final String text;
  final Widget icon;

  _LoadMoreWidget({this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        icon ??
            SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              text ?? "正在加载...",
              style: TextStyle(fontSize: 15, color: Color(0xFF4D4D4D)),
            ))
      ],
    );
  }
}
