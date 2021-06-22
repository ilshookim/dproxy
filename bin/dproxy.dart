import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  Map<WebSocketChannel, String> connections = Map();

  var handler = webSocketHandler((WebSocketChannel ws) {
    final DateTime now = DateTime.now();
    final String sid = now.toIso8601String();
    connections[ws] = sid;
    print('connected: sid=$sid, connections=${connections.length}');

    ws.stream.listen((message) {
      final String id = connections[ws] ?? '(nothing)';
      final Map echo = { 'sid': id, 'message': message };
      ws.sink.add("$echo");
      print('echo: sid=$id, message=$message');
    }, onDone: () {
      print('close: sid=$sid, connections=${connections.length}');
    }, onError: (error) {
      print('error: sid=$sid, connections=${connections.length}, error=$error');
    });

  });

  shelf_io.serve(handler, 'localhost', 9450).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}
