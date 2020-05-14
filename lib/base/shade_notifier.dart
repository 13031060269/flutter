import 'package:flutter/cupertino.dart';
import 'package:flutter_lwp/base/safe_notifier.dart';
import 'package:provider/provider.dart';

class ShadeNotifier extends SafeNotifier {
  bool loading;
  bool error = false;

  ShadeNotifier([this.loading = false]);

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
    if (!loading) {
      loading = true;
      error = false;
      notifyListeners();
    }
  }

  dismissLoading() {
    if (loading) {
      loading = false;
      error = false;
      notifyListeners();
    }
  }

  showError() {
    if (!error) {
      loading = false;
      error = true;
      notifyListeners();
    }
  }

  hideError() {
    if (error) {
      error = false;
      notifyListeners();
    }
  }
}
