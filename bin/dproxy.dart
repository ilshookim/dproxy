import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  Map<WebSocketChannel, String> _connections = Map();

  var handler = webSocketHandler((WebSocketChannel ws) {
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

  shelf_io.serve(handler, 'localhost', 9450).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}
