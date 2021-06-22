import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  var handler = webSocketHandler((WebSocketChannel ws) {
    print('connected');
    ws.stream.listen((message) {
      ws.sink.add("echo $message");
      print('echo $message');
    }, onDone: () {
      print('done');
    }, onError: (err) {
      print('error=$err');
    });
  });

  shelf_io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });
}
