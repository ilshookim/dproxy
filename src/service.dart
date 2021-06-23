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

  String _sid({bool epoch = true}) {
    final DateTime now = DateTime.now();
    if (epoch) return '${now.microsecondsSinceEpoch}';
    return now.toIso8601String();
  }

  void echo(WebSocketChannel ws, sid, payload) async {
    final String function = 'Service.listen';
    try {
      Stopwatch sw = Stopwatch()..start();
      final String cid = payload['cid'];
      final int ts1 = int.tryParse(payload['ts1'])!;
      final int ts2 = int.tryParse(payload['ts2'])!;
      final int ts3 = DateTime.now().millisecondsSinceEpoch;
      payload['ts3'] = '$ts3';
      final String message = json.encode(payload);
      ws.sink.add(message);
      final int sent = ts2 - ts1;
      print('$function: sent: sid=$sid, cid=$cid, length=${message.length}, sent=$sent ms, consumed=${sw.elapsed.inMicroseconds / 1000} ms');
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
        final int ts2 = DateTime.now().millisecondsSinceEpoch;
        final Map payload = json.decode(message);
        payload['ts2'] = '$ts2';
        payload['sid'] = sid;
        echo(ws, sid, payload);
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
