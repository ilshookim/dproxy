/// droxy designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/droxy
///
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'global.dart';
import 'service.dart';

class API {
  final Service service = Service();
  final Router router = Router();

  /// configure: curl http://localhost:8088/v1/configure
  Response onConfigure(Request request) {
    final String function = 'API.onConfigure';
    final Uri uri = request.requestedUri;
    String message = 'empty';
    try {

    } catch (exc) {
      message = '$function: $exc';
    } finally {
      print('$uri: $function: $message');
    }
    return Response.ok(message + '\n');
  }

  Handler v1({
    bool? epoch}) {
    final String function = 'API.v1';
    try {
      final Handler ws = webSocketHandler(service.listen);
      final Handler index = createStaticHandler(Global.currentPath,
          defaultDocument: Global.indexName);
      final Handler favicon = createStaticHandler(Global.currentPath,
          defaultDocument: Global.faviconName);

      const String ver1 = "v1";
      router.get(uri(Global.uriConfigure), onConfigure);
      router.get(uri(Global.uriConfigure, version: ver1), onConfigure);

      final Handler cascade =
          Cascade().add(ws).add(index).add(favicon).add(router).handler;
      final Handler handler =
          Pipeline().addMiddleware(logRequests()).addHandler(cascade);
      return handler;
    } catch (exc) {
      print('$function: $exc');
    } finally {
      service.epoch = epoch ?? service.epoch;
    }
    final Handler defaultHandler = Pipeline().addHandler((Request request) {
      return Response.ok('Request for ${request.url}');
    });
    return defaultHandler;
  }

  String uri(String path, {String? version}) {
    if (version == null) return join('/', path);
    return join('/', version, path);
  }
}
