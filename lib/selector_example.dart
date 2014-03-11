library selector_example;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'components.dart';
import 'dart:async';

var selectorExample = registerComponent(() => new SelectorExample());

var _items = new Iterable.generate(27, (i) => i).toList();

class SelectorExample extends Component {
  DataReference selected;
  DataReference active;
  DataReference loading;
  List items = new List();

  componentWillMount() {
    selected = new DataReference(1000);
    active = new DataReference(2);
    loading = new DataReference(null);
    loading.onChange.listen(load);
    for (var i = 0; i < 17; i++) {
      items.add({'text':'${i}a', 'value':i});
    }
  }

  load(_) {
    var selectorLastSelected = loading.value;
    return new Future.delayed(new Duration(seconds: 1), () {
      if (loading.value == selectorLastSelected) {
        selected.value = selectorLastSelected;
      }
    });
  }

  render() {
    return
        div({'key': 'widgetSelector',
             'className' :'widget widget-dark widget-full'},
               selector(items, selected, active, loading,
                   selectorText: 'CHOOSE ROUND', fullSize: true));
  }
}
