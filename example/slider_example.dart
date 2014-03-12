library slider_example;

import 'package:react/react.dart';
import 'package:components/components.dart';
import 'package:clean_data/clean_data.dart';

var sliderExample = registerComponent(() => new SliderExample());

class SliderExample extends Component {
  var count;
  DataReference low;
  DataReference high;
  var minValue;
  var maxValue;

  componentWillMount() {
    count = 3;
    minValue = 10;
    maxValue = 80;
    low = new DataReference(minValue);
    high = new DataReference(50);
    low.onChange.listen((val){
      (val as Change);
      print('Changed low from ${val.oldValue} to ${val.newValue}');
    });
    high.onChange.listen((val){
      (val as Change);
      print('Changed high from ${val.oldValue} to ${val.newValue}');
    });
  }

  render() {
    var _items = [];

    for (var i = 0; i < count; i++) {
      _items.add(div({'className':'list-item'},[
                   span({'className':'team-chart-position'},(i*1234).toString()),
                   span({'className':'long-club-name-text'},'Futbalovy tim cislo $i'),
                   span({'className':'account-type'}),
                   span({'className':'team-zone text-upcase'},'abcdef $i'),
                   span({'className':'team-chart-points'},(i*4321).toString())
                 ]));
    }

    return
        div({},
         doubleSlider(10,80,low,high));

  }
}
