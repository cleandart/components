library item;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:html';
import 'slider.dart';
import 'selector.dart';
import 'dart:async';
import 'scrollbar.dart';

var itemList = registerComponent(() => new ComponentContainer());

var selectorComponent = registerComponent(() => new SelectorComponent(window));
var sliderComponent = registerComponent(() => new SliderComponent(window));
var scrollbarComponent = registerComponent(() => new ScrollbarComponent(window));

var count =12;
var _selectorItems = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, 21, 22, 23, 24, 25, 26, 27];

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
    
    return div({'style' : {'position' : 'absolute', 'right' : 0, 'left' : 0, 'top' : 0,'bottom':0},
                'onMouseMove': mouseEvent, 'onMouseUp': mouseEvent},[
// slider component                                                                     
           sliderComponent({'minValue':10, 'maxValue':50, 'sliderWidth' : 460,
                            'barWidth' : 30},[]), 
            div({'style':{'width':360}},
// scrollbar component
           scrollbarComponent({'scrollStep':25,'containerClass':''},
             _items
           )),
           button({'style':{'position':'absolute','left':400},'onClick':(e){count++;redraw();}},'add'),
// dummy space maker
           div({'key' : 'dummy', 'style' : {'height' : '350px'}},[]),
// selector component
           div({'key' : 'widgetSelector', 'className' : 'widget widget-dark widget-full'},
               selector(_selectorItems, selectorSelected, selectorActive, 
                   selectorLoading, selectorText : 'VYBER KOLA', fullSize : true))

           ]); 

  }
}
