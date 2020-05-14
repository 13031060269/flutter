import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ShadeNotifier with ChangeNotifier {
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

  hideLoading() {
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
