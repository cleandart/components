import 'dart:html';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:react/react.dart';
import 'package:react/react_client.dart';
import '../example/container.dart';

void main() {
  setClientConfiguration();

  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.message}');
  });

  renderComponent(container({}), querySelector('body'));
}
