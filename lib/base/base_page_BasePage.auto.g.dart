import 'package:auto_construction/auto_construction.dart';
import "package:flutterapp/ui/home/home_page.dart";
import "package:flutterapp/base/base_page.dart";
T autoBasePageCreate<T extends BasePage>() {
	var result;
	switch (autoTypeOf<T>()) {
		case HomePage:
			result = HomePage();
			break;
		default:
			result = null;
			break;
	}
	return result;
}
