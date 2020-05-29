import 'package:auto_construction/auto_construction.dart';
import "package:flutter_lwp/base/safe_notifier.dart";
import "package:flutter_lwp/base/toast_notifier.dart";
import "package:flutter_lwp/base/shade_notifier.dart";
import "package:flutter_lwp/base/data_life.dart";
T autoSafeNotifierCreate<T extends SafeNotifier>() {
	var result;
	var type = autoTypeOf<T>();
	switch (type) {
		case DataLifeWhole:
			result = DataLifeWhole();
			break;
		case DataLife:
			result = DataLife();
			break;
		case ToastNotifier:
			result = ToastNotifier();
			break;
		case ShadeNotifier:
			result = ShadeNotifier();
			break;
		case DataLifePart:
			result = DataLifePart();
			break;
		case SafeNotifier:
			result = SafeNotifier();
			break;
		default:
			throw Exception("$type 无法实例化");
	}
	return result;
}
