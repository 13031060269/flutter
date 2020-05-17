import 'package:auto_construction/auto_construction.dart';
import "package:flutter_lwp/base/safe_notifier.dart";
import "package:flutter_lwp/ui/home/second_fragment.dart";
import "package:flutter_lwp/base/toast_notifier.dart";
import "package:flutter_lwp/ui/home/home_activity.dart";
import "package:flutter_lwp/ui/home/third_fragment.dart";
import "package:flutter_lwp/base/shade_notifier.dart";
import "package:flutter_lwp/ui/home/first_fragment.dart";
T autoSafeNotifierCreate<T extends SafeNotifier>() {
	var result;
	var type = autoTypeOf<T>();
	switch (type) {
		case SafeNotifier:
			result = SafeNotifier();
			break;
		case ShadeNotifier:
			result = ShadeNotifier();
			break;
		case HomeActivity:
			result = HomeActivity();
			break;
		case ToastNotifier:
			result = ToastNotifier();
			break;
		case ThirdFragment:
			result = ThirdFragment();
			break;
		case FirstFragment:
			result = FirstFragment();
			break;
		case SecondFragment:
			result = SecondFragment();
			break;
		default:
			throw Exception("$type 无法实例化");
	}
	return result;
}
