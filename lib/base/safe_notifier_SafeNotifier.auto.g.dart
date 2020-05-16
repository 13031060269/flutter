import 'package:auto_construction/auto_construction.dart';
import "package:flutter_lwp/base/safe_notifier.dart";
import "package:flutter_lwp/base/base_notifier.dart";
import "package:flutter_lwp/base/toast_notifier.dart";
import "package:flutter_lwp/base/shade_notifier.dart";
T autoSafeNotifierCreate<T extends SafeNotifier>() {
	var result;
	var type = autoTypeOf<T>();
	switch (type) {
		case ToastNotifier:
			result = ToastNotifier();
			break;
		case ShadeNotifier:
			result = ShadeNotifier();
			break;
		case SafeNotifier:
			result = SafeNotifier();
			break;
		case BaseNotifier:
			result = BaseNotifier();
			break;
		default:
			throw Exception("$type 无法实例化");
	}
	return result;
}
