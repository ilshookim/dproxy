/// dangry designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/dangry
///
/// working directory:
/// /app         <- working directory (default)
///
import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


import 'global.dart';

String _sid({bool epoch = true}) {
  final DateTime now = DateTime.now();
  if (epoch) return '${now.microsecondsSinceEpoch}';
  return now.toIso8601String();
}

void main(List<String> arguments) async {
  final String function = Trace.current().frames[0].member!;
  try {
    /// ARGS
    /// 
    /// port: default api port          ex) 8088
    /// 
    final ArgParser argParser = ArgParser()
      ..addOption(Global.portOption, abbr: Global.portAbbrOption)
      ..addOption(Global.epochOption, abbr: Global.epochAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPortOption;
    final String epochOption = argResults[Global.epochOption] ?? Platform.environment[Global.epochEnvOption] ?? Global.defaultEpochOption;

    /// WEBSOCKETS
    /// 
    /// sid: session id
    /// 
    Map<WebSocketChannel, String> _connections = Map();
    final bool epoch = epochOption.parseBool();
    final Handler handler = webSocketHandler((WebSocketChannel ws) {
      final String sid = _sid(epoch: epoch);
      _connections[ws] = sid;
      print('connections=${_connections.length}, sid=$sid');

      ws.stream.listen((message) {
        final int ended = DateTime.now().millisecondsSinceEpoch;
        final Map payload = json.decode(message);
        final String pts = payload['pts'];
        final int began = int.tryParse(pts) ?? ended;
        final int dur = ended - began;

        ws.sink.add("$message");
        final String sid = _connections[ws] ?? '(notFound)';
        print('echo: dur=$dur ms, sid=$sid, length=${message.length}');

        // Stopwatch sw = Stopwatch()..start();
        // final String data = json.encode(payload);
        // final String sid = _connections[ws] ?? '(nothing)';
        // payload['sid'] = sid;
        // // ws.sink.add("${json.encode(payload)}");
        // ws.sink.add("$message");
        // print('echo: dur=${dur / 1000} ms, sid=$sid, length=${message.length}, consumed=${sw.elapsed.inMicroseconds / 1000} ms');
      }, onDone: () {
        _connections.remove(ws);
        print('close: sid=$sid, connections=${_connections.length}');
      }, onError: (error) {
        _connections.remove(ws);
        print('error: sid=$sid, connections=${_connections.length}, error=$error');
      });

    });

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption)!;
    final HttpServer server = await serve(handler, host, port);

    final Map pubspec = await Global.pubspec();
    final String name = pubspec[Global.name];
    final String version = pubspec[Global.version];
    final String description = pubspec[Global.description];
    print('$name $version - $description serving at http://${server.address.host}:${server.port}');
    print('options: epoch=$epochOption');
  } catch (exc) {
    print('$function: $exc');
  }
}
