import 'package:auto_construction/auto_construction.dart';
import "package:flutterapp/base/base_notifier.dart";
import "package:flutterapp/ui/home/home_notifier.dart";
T autoBaseNotifierCreate<T extends BaseNotifier>() {
	var result;
	switch (autoTypeOf<T>()) {
		case HomeNotifier:
			result = HomeNotifier();
			break;
		case BaseNotifier:
			result = BaseNotifier();
			break;
		default:
			result = null;
			break;
	}
	return result;
}
