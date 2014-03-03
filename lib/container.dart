library item;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:html';
import 'slider.dart';
import 'selector.dart';
import 'dart:async';
import 'scrollbar.dart';

var itemList = registerComponent(() => new ComponentContainer());

var sliderComponent = registerComponent(() => new SliderComponent());
var selectorComponent = registerComponent(() => new SelectorComponent());

var lastSelected;

var scrollbarComponent = registerComponent(() => new ScrollbarComponent());


class ComponentContainer extends Component {

  StreamController sc;

  componentWillMount() {
    sc = new StreamController.broadcast();
  }

  mouseEvent(ev) {
    sc.add(ev);
  }
 
  Future load(item){
    lastSelected = item;
    return new Future.delayed(new Duration(seconds: 2), () {
      if (lastSelected == item) {
        return true;
      }
      else {
        return false;
      }
    });
  }
  
  render() { 
    
    return div({'style' : {'position' : 'absolute', 'right' : 0, 'left' : 0, 'top' : 0,'bottom':0},
      'onMouseMove': mouseEvent, 'onMouseUp': mouseEvent}, [
//      sliderComponent({'minValue':10, 'maxValue':50, 'sliderWidth' : 460,
//        'stream' : sc.stream,'barWidth' : 30},[])]);
      selectorComponent({/*'selected':0, */'items':[0,1,2,3], 'load': load},[])    
          ]); 

  }
}
