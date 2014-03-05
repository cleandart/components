library item;

import 'package:react/react.dart';
import 'dart:html';
import 'slider.dart';
import 'dart:async';
import 'scrollbar.dart';
import 'package:clean_data/clean_data.dart';

var itemList = registerComponent(() => new ComponentContainer());

var sliderComponent = registerComponent(() => new SliderComponent(window));
var scrollbarComponent = registerComponent(() => new ScrollbarComponent(window));

class ComponentContainer extends Component {

  StreamController sc;

  componentWillMount() {
    sc = new StreamController.broadcast();
  }

  mouseEvent(ev) {
    sc.add(ev);
  }
 
  var count =12;
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
           sliderComponent({'minValue':10, 'maxValue':50, 'barWidth' : 30,'lowValue':new DataReference(10), 'highValue': new DataReference(50)},[]), 
            div({'style':{'width':360}},
             scrollbarComponent({'scrollStep':25,'containerClass':''},
               _items
             )),
             button({'style':{'position':'absolute','left':400},'onClick':(e){count++;redraw();}},'add')
           ]); 
  }
}
