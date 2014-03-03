library item;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:html';
import 'slider.dart';
import 'dart:async';
import 'scrollbar.dart';

var itemList = registerComponent(() => new ComponentContainer());

var sliderComponent = registerComponent(() => new SliderComponent());
var scrollbarComponent = registerComponent(() => new ScrollbarComponent());

class ComponentContainer extends Component {

  StreamController sc;

  componentWillMount() {
    sc = new StreamController.broadcast();
  }

  mouseEvent(ev) {
    sc.add(ev);
  }
 
  render() { 
    
    var _items = [];
    
    for (var i = 0; i < 20; i++) {
      _items.add(div({'className':'list-item'},[
                   span({'className':'team-chart-position'},(i*1234).toString()),
                   span({'className':'long-club-name-text'},'Futbalovy tim cislo $i'),
                   span({'className':'account-type'}),
                   span({'className':'team-zone text-upcase'},'abcdef $i'),
                   span({'className':'team-chart-points'},(i*4321).toString())
                 ]));
    }
    
    
    return div({'style' : {'position' : 'absolute', 'right' : 0, 'left' : 0, 'top' : 0,'bottom':0},
      'onMouseMove': mouseEvent, 'onMouseUp': mouseEvent},[ 
      sliderComponent({'minValue':10, 'maxValue':50, 'sliderWidth' : 460,
          'stream' : sc.stream,'barWidth' : 30},[]),
      scrollbarComponent({'itemHeight':60,'windowHeight':285,'stream':sc.stream,'scrollStep':25},
          _items)]); 
  }
}
