import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_lwp/utils/utils.dart';
const Duration timeout = Duration(seconds: 10);

_printLog(String msg, bool logAble, [StringBuffer sb]) {
  if (!Utils.isEmpty(msg) && logAble) {
    print(msg);
  }
  sb?.writeln(msg ?? "");
}
class BaseNet {
  static String ip;

  static Future<dynamic> request(String uri,
      {Map data,
      Map parameters,
      Method method = Method.POST,
      List<Function> functions,
      bool logAble = false,
      ValueChanged<HttpException> error,
      Map header}) async {
    await Future.delayed(Duration(milliseconds: 200));
    StringBuffer stringBuffer;
    StringBuffer keyStringBuffer = StringBuffer();
    keyStringBuffer.write(uri);
    if (!Utils.isEmpty(data)) {
      keyStringBuffer.write(jsonEncode(data));
    }
    if (!Utils.isEmpty(parameters)) {
      keyStringBuffer.write(jsonEncode(parameters));
    }
    String key = Utils.getMd5(keyStringBuffer.toString());
    Function function;
    if (!kReleaseMode) {
      stringBuffer = StringBuffer();
    }
    try {
      String host = ip;
      var httpUri;
      var _httpClient = HttpClient()
        ..autoUncompress = false
        ..connectionTimeout = timeout;
      if (host == null) {
        httpUri = new Uri.http("new-car-aos.oss-cn-shenzhen.aliyuncs.com",
            "/conf/app-setup/hosts.txt");
        var request = await _httpClient.openUrl("GET", httpUri);
        var response = await request.close();
        var responseBody = await response.transform(Utf8Decoder()).join();
        var json = jsonDecode(responseBody);
        ip = host = json["mini.server.com"];
      }
      httpUri = new Uri.http("$host:8001", uri, parameters);

      _printLog("========url========", logAble, stringBuffer);
      _printLog("$httpUri", logAble, stringBuffer);

      _printLog("========method========", logAble, stringBuffer);
      _printLog("$method", logAble, stringBuffer);

      _printLog("========header========", logAble, stringBuffer);
      _printLog("${jsonEncode(header)}", logAble, stringBuffer);

      _printLog("========data========", logAble, stringBuffer);
      _printLog("$data", logAble, stringBuffer);

      _printLog("========parameters========", logAble, stringBuffer);
      _printLog(
          "${jsonEncode(httpUri.queryParameters)}", logAble, stringBuffer);
      function = () {
        _httpClient.close(force: true);
      };
      functions?.add(function);
      var request =
          await _httpClient.openUrl(method.toString().split(".")[1], httpUri);
      request.headers.add('Content-Type', 'application/json;charset=utf-8');
      header?.forEach((k, v) {
        request.headers.add(k, v);
      });

      if (!Utils.isEmpty(data)) {
        var convert = Utf8Encoder().convert(jsonEncode(data));
        request.contentLength = convert.length;
        request.add(convert);
      }

      var response = await request.close();
      var responseBody = await response.transform(Utf8Decoder()).join();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(responseBody, response.statusCode);
      }
      _printLog("========responseBody========", logAble, stringBuffer);
      _printLog("$responseBody", logAble, stringBuffer);
      var json = jsonDecode(responseBody);
      if ("${json["code"]}" == "0") {
        Utils.saveLog(jsonEncode(json["data"]), key);
        return json["data"];
      } else {
        throw HttpException(json['message'], json["code"]);
      }
    } catch (e, st) {
      _printLog(e.toString(), logAble, stringBuffer);
      _printLog(st.toString(), logAble, stringBuffer);
      String history = await Utils.readLog(key);
      if (Utils.isEmpty(history)) {
        HttpException httpException;
        if (error != null) {
          if (e is HttpException) {
            httpException = e;
          } else {
            httpException = HttpException("请求失败", -1);
          }
          error(httpException);
        }
      } else {
        return jsonDecode(history);
      }
    } finally {
      functions?.remove(function);
//      Utils.saveLog(stringBuffer?.toString());
    }
  }

  static Future<File> downLoad(String url,
      {ValueChanged<Plan> changed,
      bool autoUncompress = true,
      ValueChanged<HttpClient> httpBack,
      Map header = const {}}) async {
    StreamController<Plan> planEvents;
    try {
      if (changed != null) {
        planEvents = StreamController<Plan>();
        planEvents.stream.listen(changed);
      }
      File file = await Utils.deleteIfDamaged(url);
      if (file.existsSync()) {
        return file;
      }
      File contentLengthFile = File("${file.path}.contentLength");
      final Uri resolved = Uri.base.resolve(url);
      HttpClient client = HttpClient()
        ..autoUncompress = false
        ..connectionTimeout = timeout;
      if (httpBack != null) {
        httpBack(client);
      }
      final HttpClientRequest request = await client.getUrl(resolved);
      header.forEach((k, v) {
        request.headers.add(k, v);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw HttpException("失败", response.statusCode);

      final Completer<File> completer = Completer<File>.sync();
      IOSink ioSink = file.openWrite();
      Sink sink = ioSink;
      int contentLength = response.contentLength;
      if (contentLength == -1) {
        return null;
      }
      contentLengthFile.writeAsString(contentLength.toString());
      switch (response.compressionState) {
        case HttpClientResponseCompressionState.compressed:
          if (autoUncompress) {
            sink = gzip.decoder.startChunkedConversion(ioSink);
          }
          break;
        case HttpClientResponseCompressionState.decompressed:
          contentLength = null;
          break;
        case HttpClientResponseCompressionState.notCompressed:
          break;
      }

      int bytesReceived = 0;
      StreamSubscription<List<int>> subscription;
      subscription = response.listen((List<int> chunk) async {
        sink.add(chunk);
        bytesReceived += chunk.length;
        try {
          if (contentLength != null) {
            planEvents?.add(Plan(bytesReceived, contentLength));
          }
        } catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
          subscription.cancel();
          return;
        }
      }, onDone: () async {
        sink.close();
        await ioSink.close();
        completer.complete(file);
      }, onError: completer.completeError, cancelOnError: true);
      return await completer.future;
    } catch (e, st) {} finally {
      planEvents?.close();
    }
    return null;
  }
}

class HttpException implements Exception {
  String msg;
  int code;

  HttpException(this.msg, this.code);

  @override
  String toString() {
    return msg;
  }
}

enum Method { GET, POST, PUT, DELETE, FORM }

class Plan {
  int bytesLoaded;
  int totalBytes;

  Plan(this.bytesLoaded, this.totalBytes);

  get site => bytesLoaded * 100 ~/ totalBytes;
}
