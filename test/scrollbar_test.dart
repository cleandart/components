import 'package:unittest/unittest.dart';
import 'package:react/react_test.dart';
import 'package:components/scrollbar.dart';
import 'package:unittest/mock.dart';
import 'package:clean_data/clean_data.dart';
import 'package:react/react.dart';
import 'dart:async';

void main() {

  group('Scrollbar',() {
    var window;
    var scrollStep;
    var className;
    var childrenCount;
    List children;
    ScrollbarComponent scrollbar;
    setUp(() {
      window = new Mock()
        ..when(callsTo('get onMouseMove')).alwaysReturn(new StreamController.broadcast().stream)
        ..when(callsTo('get onMouseUp')).alwaysReturn(new StreamController.broadcast().stream);
      scrollbar = new ScrollbarComponent(window);
      scrollStep = 50;
      className = '';
      for (var i = 0; i < childrenCount; i++) {
        children.add(div({'className':'list-item'},[
                       span({'className':'team-chart-position'},(i*1234).toString()),
                       span({'className':'long-club-name-text'},'Futbalovy tim cislo $i'),
                       span({'className':'account-type'}),
                       span({'className':'team-zone text-upcase'},'abcdef $i'),
                       span({'className':'team-chart-points'},(i*4321).toString())
                     ])
        );
      }
      initializeComponent(scrollbar, {'scrollStep' : 50, 'containerClass': className}, children);
    });

  });

}