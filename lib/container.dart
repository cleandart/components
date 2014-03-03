library item;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:html';
import 'slider.dart';
import 'dart:async';

var itemList = registerComponent(() => new ComponentContainer());

var sliderComponent = registerComponent(() => new SliderComponent());

class ComponentContainer extends Component {

  StreamController sc;

  componentWillMount() {
    sc = new StreamController.broadcast();
  }

  mouseEvent(ev) {
    sc.add(ev);
  }
 
  render() { 
    return div({'style' : {'position' : 'absolute', 'right' : 0, 'left' : 0, 'top' : 0,'bottom':0},
      'onMouseMove': mouseEvent, 'onMouseUp': mouseEvent}, 
      sliderComponent({'minValue':10, 'maxValue':50, 'sliderWidth' : 460,
          'stream' : sc.stream,'barWidth' : 30},[])); 
  }
}
