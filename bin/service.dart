/// dangry designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/dangry
///
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'global.dart';

class Service {
  bool epoch = Global.defaultEpochOption.parseBool();

  Map<WebSocketChannel, String> _connections = Map();
  Map<WebSocketChannel, dynamic> _messages = Map();

  String _sid({bool epoch = true}) {
    final DateTime now = DateTime.now();
    if (epoch) return '${now.microsecondsSinceEpoch}';
    return now.toIso8601String();
  }

  void echo(WebSocketChannel ws) {
    final String function = 'Service.listen';
    try {
        final message = _messages[ws];
        ws.sink.add("$message");
    } catch (exc) {
      print('$function: $exc');
    }
  }
  
  void listen(WebSocketChannel ws) {
    final String function = 'Service.listen';
    try {
      final String sid = _sid(epoch: epoch);
      _connections[ws] = sid;
      print('$function: connections=${_connections.length}, sid=$sid');

      ws.stream.listen((message) {
        final int ended = DateTime.now().millisecondsSinceEpoch;
        final Map payload = json.decode(message);
        final String pts = payload['pts'];
        final int began = int.tryParse(pts) ?? ended;
        final int dur = ended - began;
        final String sid = _connections[ws] ?? '(notFound)';
        print('$function: dur=$dur ms, sid=$sid, length=${message.length}');

        _messages[ws] = message;
        echo(ws);
        // ws.sink.add("$message");
        // echo(ws, message);
        // ws.sink.add("$message");
        // final String sid = _connections[ws] ?? '(notFound)';
        // print('$function: echo: dur=$dur ms, sid=$sid, length=${message.length}');

        // Stopwatch sw = Stopwatch()..start();
        // final String data = json.encode(payload);
        // final String sid = _connections[ws] ?? '(nothing)';
        // payload['sid'] = sid;
        // // ws.sink.add("${json.encode(payload)}");
        // ws.sink.add("$message");
        // print('echo: dur=${dur / 1000} ms, sid=$sid, length=${message.length}, consumed=${sw.elapsed.inMicroseconds / 1000} ms');
      }, onDone: () {
        _connections.remove(ws);
        print('$function: close: sid=$sid, connections=${_connections.length}');
      }, onError: (error) {
        _connections.remove(ws);
        print('$function: error: sid=$sid, connections=${_connections.length}, error=$error');
      });
    } catch (exc) {
      print('$function: $exc');
    }
  }
}
