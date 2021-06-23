/// dangry designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/dangry
///
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Global {
  static final String defaultApp = 'DROXY';
  static final String defaultHost = '0.0.0.0';

  static final String portOption = 'port';
  static final String portAbbrOption = 'p';
  static final String portEnvOption = '${defaultApp}_PORT';
  static final String defaultPortOption = '9455';
  static final String epochOption = 'epoch';
  static final String epochAbbrOption = 'h';
  static final String defaultEpochOption = 'true';
  static final String epochEnvOption = '${defaultApp}_EPOCH';

  static final String uriConfigure = "configure";

  static final String indexName = 'index.html';
  static final String faviconName = 'favicon.ico';
  static final int exitCodeCommandLineUsageError = 64;
  static final String dsStoreFile = '.DS_Store';

  static final String currentPath = dirname(Platform.script.toFilePath());
  static final String yamlName = 'pubspec.yaml';
  static final String name = 'name';
  static final String version = 'version';
  static final String description = 'description';

  static Future<Map> pubspec() async {
    final String function = 'Global.pubspec';
    Map yaml = Map();
    try {
      final String path = join(current, yamlName);
      final File file = new File(path);
      final String text = await file.readAsString();
      yaml = loadYaml(text);
    } catch (exc) {
      print('$function: $exc');
    }
    return yaml;
  }
}

extension BoolParsing on String {
  bool parseBool() {
    final String lowerCase = this.toLowerCase();
    if (lowerCase.isEmpty || lowerCase == 'false') return false;
    return lowerCase == 'true' || lowerCase != '0';
  }
}
