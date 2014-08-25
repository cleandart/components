library selector_example;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'package:clean_data/clean_data.dart' as cd;
import 'package:components/components.dart';
import 'package:components/componentsTypes.dart';
import 'package:quiver/iterables.dart';
import 'dart:async';

var selectorExample = registerComponent(() => new SelectorExample());

var _items = new Iterable.generate(27, (i) => i).toList();

class SelectorExample extends Component {
  DataReference selected;
  DataReference active;
  DataReference loading;
  List items = new Iterable.generate(32);

  componentWillMount() {
    selected = new DataReference(31);
    active = new DataReference(31);
    loading = new DataReference(null);
    loading.onChange.listen(load);
    cd.onChange([loading, selected, active]).listen((_) => redraw());
  }

  get selectorItems =>
    items.map((i) => createSelectorItem(i, '${i}a', i == loading.value ? "loading" : i == selected.value ? 'selected' : '', i == selected.value)).toList();

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
               selector(items, onChange, selectorText: 'CHOOSE ROUND', selectorClass: 'round-selector round-selector-full'));
  }
}
