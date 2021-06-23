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

import 'global.dart';
import 'api.dart';

void main(List<String> arguments) async {
  final String function = 'main';
  try {
    /// ARGS
    /// 
    /// port  : default api port      ex) 8088
    /// epoch : default sid epoch     default) disable
    /// 
    final ArgParser argParser = ArgParser()
      ..addOption(Global.portOption, abbr: Global.portAbbrOption)
      ..addOption(Global.epochOption, abbr: Global.epochAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPortOption;
    final String epochOption = argResults[Global.epochOption] ?? Platform.environment[Global.epochEnvOption] ?? Global.defaultEpochOption;

    /// API
    /// 
    /// configure:  curl http://localhost:8088/v1/configure?data=3KB&app=home1&connections=450
    /// 
    final API api = API();
    final Handler handler = api.v1(
      epoch: epochOption.parseBool(),
    );
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
