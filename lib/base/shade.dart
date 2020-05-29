import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lwp/base/safe_notifier.dart';
import 'package:provider/provider.dart';

class ShadeWidget<T> extends StatelessWidget {
  final bool _showLoading;
  final bool _showError;
  final GestureTapCallback onTap;

  ShadeWidget(this._showLoading, this._showError, this.onTap);

  ShadeWidget.simple(ShadeNotifier shade, GestureTapCallback onTap)
      : this(shade._loading, shade._error, onTap);

  @override
  Widget build(BuildContext context) {
    if (!_showLoading && !_showError) {
      return Container();
    } else if (_showError) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: _ErrorWidget(),
        onTap: onTap,
      );
    } else {
      return _LoadingWidget(_showLoading);
    }
  }
}

class _ErrorWidget extends StatelessWidget {
  final Color bgColor;

  _ErrorWidget([this.bgColor = Colors.white]);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: bgColor,
      alignment: Alignment.center,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "images/icon_none.png",
              height: 107,
              width: 137,
            ),
            Padding(
              padding: EdgeInsets.only(top: 36),
              child: Text(
                "网络错误",
                style: TextStyle(fontSize: 16, color: Color(0xffb7b7b7)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  final bool loading;

  _LoadingWidget([this.loading = true]);

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      return Container();
    }
    return SizedBox(
      child: GestureDetector(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.black12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                  height: 40,
                  width: 40,
                )
              ],
            ),
            height: 100,
            width: 100,
          ),
        ),
        onTap: () {},
        onDoubleTap: () {},
        onVerticalDragUpdate: (d) {},
        onHorizontalDragUpdate: (d) {},
        behavior: HitTestBehavior.opaque,
      ),
      height: double.infinity,
      width: double.infinity,
    );
  }
}

class ShadeNotifier extends SafeNotifier {
  bool _loading = false;
  bool _error = false;

  ShadeNotifier();

  static ShadeNotifier get(BuildContext context) {
    try {
      if (context != null) {
        return Provider.of<ShadeNotifier>(context, listen: false);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  showLoading() {
    if (!_loading) {
      _loading = true;
      _error = false;
      notifyListeners();
    }
  }

  dismissLoading() {
    if (_loading) {
      _loading = false;
      _error = false;
      notifyListeners();
    }
  }

  showError() {
    if (!_error) {
      _loading = false;
      _error = true;
      notifyListeners();
    }
  }

  hideError() {
    if (_error) {
      _error = false;
      notifyListeners();
    }
  }
}
