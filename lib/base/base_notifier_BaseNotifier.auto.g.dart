import 'package:auto_construction/auto_construction.dart';
import "package:flutter_lwp/base/base_notifier.dart";
T autoBaseNotifierCreate<T extends BaseNotifier>() {
	var result;
	var type = autoTypeOf<T>();
	switch (type) {
		case BaseNotifier:
			result = BaseNotifier();
			break;
		default:
			throw Exception("$type 无法实例化");
	}
	return result;
}
