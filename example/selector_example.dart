library selector_example;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'package:components/components.dart';
import 'dart:async';

var selectorExample = registerComponent(() => new SelectorExample());

var _items = new Iterable.generate(27, (i) => i).toList();

class SelectorExample extends Component {
  DataReference selected;
  DataReference active;
  DataReference loading;
  List items = new List();

  componentWillMount() {
    selected = new DataReference(31);
    active = new DataReference(31);
    loading = new DataReference(null);
    loading.onChange.listen(load);
    for (var i = 0; i < 32; i++) {
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

  onChange(item) {
    loading.value = item['value'];
    print((item['text']));
  }
  render() {
    return
        div({'key': 'widgetSelector',
             'className' :'widget widget-dark widget-full'},
               selector(items, selected, active, loading,
                   selectorText: 'CHOOSE ROUND', className: 'round-selector round-selector-full', onChange: onChange));
  }
}
