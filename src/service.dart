/// droxy designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/droxy
///
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'global.dart';

class Service {
  bool epoch = Global.defaultEpochOption.parseBool();

  Map<WebSocketChannel, Map> _connections = Map();
  // Map<WebSocketChannel, dynamic> _payloads = Map();

  String _sid({bool epoch = true}) {
    final DateTime now = DateTime.now();
    if (epoch) return '${now.microsecondsSinceEpoch}';
    return now.toIso8601String();
  }

  void listen(WebSocketChannel ws) async {
    final String function = 'Service.listen';
    try {
      final parameters = Map();
      final String sid = _sid(epoch: epoch);
      parameters[Global.paramSid] = sid;
      _connections[ws] = parameters;
      print('$function: connections=${_connections.length}, sid=$sid');

      // final ReceivePort parent = ReceivePort();
      // parameters['parentSendPort'] = parent.sendPort;
      //
      // Isolate.spawn(echo, parameters).then((Isolate isolate) async {
      //   final SendPort childSendPort = await parent.first;
      //   parameters['childSendPort'] = childSendPort;
      //   // parameters['timer'] = Timer.periodic(Duration(), (Timer timer) { 
      //   //   if (_payloads.containsKey(ws)) {
      //   //     final int ts3 = DateTime.now().millisecondsSinceEpoch;
      //   //     final message = _payloads[ws];
      //   //     _payloads.remove(ws);
      //   //     final Map payload = json.decode(message);
      //   //     payload['ts2'] = parameters['ts2'];
      //   //     payload['sid'] = sid;
      //   //     payload['ts3'] = '$ts3';
      //   //     final data = json.encode(payload);
      //   //     ws.sink.add(data);

      //   //     final int ts1 = int.tryParse(payload['ts1'])!;
      //   //     final int dur = ts3 - ts1;
      //   //     print('$function: [timerSend] sid=$sid, dur=$dur ms');
      //   //   }
      //   // });
      //   _connections[ws] = parameters;
      //   print('$function: [isolate] connections=${_connections.length}, sid=$sid');
      // });

      ws.stream.listen((message) async {
        final int ts2 = DateTime.now().millisecondsSinceEpoch;
        final Map payload = json.decode(message);
        payload['ts2'] = '$ts2';
        payload['sid'] = sid;
        final String cid = payload['cid'];
        final int ts1 = int.tryParse(payload['ts1'])!;
        final int dur = ts2 - ts1;
        print('$function: [listen] sid=$sid, dur=$dur ms <- cid=$cid');

        // _payloads[ws] = message;
        // final int ts2 = DateTime.now().millisecondsSinceEpoch;
        // parameters['ts2'] = '$ts2';
        // final SendPort childSendPort = parameters['childSendPort'];
        // childSendPort.send([ts2, sid, message]);

        // send(ws, ts2, sid, message);
      }, onDone: () async {
        _connections.remove(ws);
        print('$function: close: sid=$sid, connections=${_connections.length}');
      }, onError: (error) async {
        _connections.remove(ws);
        print('$function: error: sid=$sid, connections=${_connections.length}, error=$error');
      });
    } catch (exc) {
      print('$function: $exc');
    }
  }

  void send(ws, ts2, sid, message) async {
      final Map payload = json.decode(message);
      payload['ts2'] = '$ts2';
      payload['sid'] = sid;
      final int ts3 = DateTime.now().millisecondsSinceEpoch;
      payload['ts3'] = '$ts3';
      final data = json.encode(payload);
      ws.sink.add(data);
  }

}

void echo(Map parameters) async {
  final String function = 'echo';
  try {
    final String sid = parameters[Global.paramSid];
    final SendPort parentSendPort = parameters['parentSendPort'];
    // print('$function: parameters=${parameters.length}, sid=$sid');

    final ReceivePort child = ReceivePort();
    parameters['childSendPortIn'] = child.sendPort;
    parentSendPort.send(child.sendPort);

    await for (var message in child) {
      final int ts2 = message[0];
      final String sid = message[1];
      final Map payload = json.decode(message[2]);
      final String cid = payload['cid'];
      final int ts1 = int.tryParse(payload['ts1'])!;
      final int dur = ts2 - ts1;
      print('$function: [listen] sid=$sid, dur=$dur ms <- cid=$cid');
    }
  } catch (exc) {
    print('$function: $exc');
  }
}
