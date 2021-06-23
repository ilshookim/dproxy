/// dangry designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/dangry
///
/// working directory:
/// /app         <- working directory (default)
///
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


import 'global.dart';

void main(List<String> arguments) async {
  final String function = Trace.current().frames[0].member!;
  try {
    /// ARGS
    /// 
    /// port: default api port          ex) 8088
    /// 
    final ArgParser argParser = ArgParser()
      ..addOption(Global.portOption, abbr: Global.portAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPortOption;

    /// WEBSOCKETS
    /// 
    /// sid: session id
    /// 
    Map<WebSocketChannel, String> _connections = Map();
    final Handler handler = webSocketHandler((WebSocketChannel ws) {
      final DateTime now = DateTime.now();
      final String sid = now.toIso8601String();
      _connections[ws] = sid;
      print('connections=${_connections.length}, sid=$sid');

      ws.stream.listen((message) {
        final String id = _connections[ws] ?? '(nothing)';
        final Map echo = { 'sid': id, 'msg': message };
        ws.sink.add("$echo");
        print('echo: sid=$id, msg=$message');
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
  } catch (exc) {
    print('$function: $exc');
  }
}
