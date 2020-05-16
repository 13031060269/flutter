import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

void printLog(Object obj) {
  if (!kReleaseMode) {
    print("===========$obj==============");
  }
}

class Utils {
  static pop<T extends Object>(BuildContext context, [T result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
    }
  }

  static bool isNotEmpty(Object object) {
    return !isEmpty(object);
  }

  static bool isEmpty(Object object) {
    if (object == null) return true;
    if (object is List && object.length == 0) {
      return true;
    }
    if (object is Map && object.length == 0) {
      return true;
    }
    return object.toString().length == 0;
  }

  static Future<T> push<T extends Object>(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      CupertinoPageRoute(builder: (ccc) => page),
    );
  }

  static Future<String> getCachePath() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    return tempPath;
  }

  static Future<String> getDownLoadPath() async {
    String path = await getCachePath();
    Directory download = Directory("$path/download");
    if (!download.existsSync()) {
      download.createSync(recursive: true);
    }
    return download.path;
  }

  static void saveLog(String log, [String name]) async {
    if (isEmpty(log)) return;
    if (isEmpty(name)) {
      name = DateTime.now().toIso8601String();
    }
    try {
      String path = (Platform.isAndroid
              ? (await getExternalStorageDirectory())
              : await getTemporaryDirectory())
          .path;
      Directory logDir = Directory("$path/logDir");
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }
      File file = File("$path/$name.txt");
      await file.writeAsString(log);
//      print("保存log文件成功，路径为：${file.path}");
    } catch (e) {
      print(e);
    }
  }

  static Future<String> readLog(String name) async {
    if (!isEmpty(name)) {
      try {
        String path = (Platform.isAndroid
                ? (await getExternalStorageDirectory())
                : await getTemporaryDirectory())
            .path;
        Directory logDir = Directory("$path/logDir");
        if (!logDir.existsSync()) {
          logDir.createSync(recursive: true);
        }
        File file = File("$path/$name.txt");
        return await file.readAsString();
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  static String getMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  static Future<File> getDownloadFile(String url) async {
    String suffix = "";
    String uri = Uri.base.resolve(url)?.path;
    int start = uri?.lastIndexOf(".");
    if ((start ??= 0) > 0) {
      suffix = uri.substring(start);
    }
    String path = await Utils.getDownLoadPath();
    return File("$path/${Utils.getMd5(url)}$suffix");
  }

  static Future<File> deleteIfDamaged(String url) async {
    File file = await getDownloadFile(url);
    File contentLengthFile = File("${file.path}.contentLength");
    var fileExists = file.existsSync();
    var contentLengthFileExists = contentLengthFile.existsSync();
    if (fileExists && contentLengthFileExists) {
      int length = await file.length();
      String lengthStr = await contentLengthFile.readAsString();
      if (length > 0 && length.toString() == lengthStr) {
        return file;
      }
    }
    if (fileExists) file.deleteSync();
    if (contentLengthFileExists) contentLengthFile.deleteSync();
    return file;
  }
}

after(Function function) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    function();
  });
}
