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

  componentWillMount() {
    selected = new DataReference(null);
    active = new DataReference(15);
    loading = new DataReference(null);
    loading.onChange.listen(load);
  }

  load(_) {
    var selectorLastSelected = loading.value;
    return new Future.delayed(new Duration(seconds: 2), () {
      if (loading.value == selectorLastSelected) {
        selected.value = selectorLastSelected;
      }
    });
  }

  render() {
    return
        div({'key': 'widgetSelector',
             'className' :'widget widget-dark widget-full'},
               selector(_items, selected, active, loading,
                   selectorText: 'CHOOSE ROUND', fullSize: true));
  }
}
