import 'package:auto_construction/auto_construction.dart';
import "package:flutterapp/base/base_notifier.dart";
T autoBaseNotifierCreate<T extends BaseNotifier>() {
	var result;
	switch (autoTypeOf<T>()) {
		case BaseNotifier:
			result = BaseNotifier();
			break;
		default:
			result = null;
			break;
	}
	return result;
}
