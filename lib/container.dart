library item;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
//import 'dart:html';
import 'slider.dart';
import 'selector.dart';
import 'dart:async';
import 'scrollbar.dart';

var itemList = registerComponent(() => new ComponentContainer());

var sliderComponent = registerComponent(() => new SliderComponent());
var selectorComponent = registerComponent(() => new SelectorComponent());
var scrollbarComponent = registerComponent(() => new ScrollbarComponent());

DataReference selectorSelected;
DataReference selectorActive;
DataReference selectorLoading;

class ComponentContainer extends Component {

  StreamController sc;

  componentWillMount() {
    sc = new StreamController.broadcast();
    
    selectorSelected = new DataReference(null);
    selectorActive = new DataReference(15);
    selectorLoading = new DataReference(null);
    selectorLoading.onChange.listen(load);
  }

  mouseEvent(ev) {
    sc.add(ev);
  }
 
  load(item){
    var selectorLastSelected = selectorLoading.value;
    return new Future.delayed(new Duration(seconds: 2), () {
      if (selectorLoading.value == selectorLastSelected) {
        selectorSelected.value = selectorLastSelected;
      }
    });
  }
  
  render() {
    var _items = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, 21, 22, 23, 24, 25, 26, 27];
    return div({'style' : {'position' : 'absolute', 'right' : 0, 'left' : 0, 'top' : 0,'bottom':0},
      'onMouseMove': mouseEvent, 'onMouseUp': mouseEvent}, [
      sliderComponent({'key' : 'slider', 'minValue':10, 'maxValue':50, 'sliderWidth' : 460,
        'stream' : sc.stream,'barWidth' : 30},[]),
      div({'key' : 'dummy', 'style' : {'height' : '50px'}},[]),  
      div({'key' : 'widgetSelector', 'className' : 'widget widget-dark widget-full'},
//scrollStep 6,10,16 based on browser window width 
          selectorComponent({'key' : 'selector', 'selected' : selectorSelected,
            'active' : selectorActive, 'loading': selectorLoading,
            'items' : _items, 'scrollStep' : 10,
            'selectorText' : 'VYBER KOLA', 'fullSize' : true},[]))
          ]); 

  }
}
