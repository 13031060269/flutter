import 'package:auto_construction/auto_construction.dart';
import "package:flutter_lwp/ui/home/home_rule.dart";
import "package:flutter_lwp/base/safe_notifier.dart";
import "package:flutter_lwp/base/shade.dart";
import "package:flutter_lwp/base/toast.dart";
import "package:flutter_lwp/base/data_life.dart";
T autoSafeNotifierCreate<T extends SafeNotifier>() {
	var result;
	var type = autoTypeOf<T>();
	switch (type) {
		case DataLife:
			result = DataLife();
			break;
		case SafeNotifier:
			result = SafeNotifier();
			break;
		case DataLifeWhole:
			result = DataLifeWhole();
			break;
		case HomeDataLife:
			result = HomeDataLife();
			break;
		case ShadeNotifier:
			result = ShadeNotifier();
			break;
		case ToastNotifier:
			result = ToastNotifier();
			break;
		case DataLifeBar:
			result = DataLifeBar();
			break;
		default:
			throw Exception("$type 无法实例化");
	}
	return result;
}
