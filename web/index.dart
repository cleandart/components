import 'dart:html';
import 'dart:async';
import "package:clean_sync/client.dart";
import "package:clean_ajax/client_browser.dart";
import 'package:logging/logging.dart';
import 'package:react/react.dart';
import 'package:react/react_client.dart';
import 'package:components/container.dart';
import 'package:components/slider.dart';

/**
 * Do not run this using DartEditor Launcher! It will not work due to same
 * origin policy. What to do: run dartium and follow this link:
 * http://0.0.0.0:8080/static/index.html
 */


void main() {
  setClientConfiguration();
  Subscription items;
  Subscription order;

  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.OFF;
//  new Logger('clean_sync').level = Level.FINE;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.message}');
  });

  // initialization of these Subscriptions
  Connection connection = createHttpConnection("http://0.0.0.0:8080/resources/",
      new Duration(milliseconds: 1000));

  Subscriber subscriber = new Subscriber(connection);
  subscriber.init().then((_) {
    renderComponent(itemList({}), querySelector('body'));
  });
}
