library selector;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:async';

class SelectorComponent extends Component {
  
//  get barWidth => props['barWidth'];
//  get selectorWidth => props['selectorWidth'];
  
  DataReference selected; // => props['selected'];
  var clicked;
  get items => props['items'];
  get load => props['load'];
  
  
  SelectorComponent() {    
  }
  
  componentWillMount() {
    selected = new DataReference(props['selected']);
  }
  
  render() {
    var _items = [];
    for (var item in items) {
      if (selected.value == item){
        _items.add(button({'onMouseDown': (ev) => mouseDown(ev, item),'style' : {'background-color':'red'}},[item]));
      }
      else if (clicked == item){
        _items.add(button({'onMouseDown': (ev) => mouseDown(ev, item),'style' : {'background-color':'green'}},[item]));
      }
      else {
        _items.add(button({'onMouseDown': (ev) => mouseDown(ev, item),'style' : {'background-color':'#cccccc'}},[item]));  
      }
      
    }
    var leftArrowButton = button({'onMouseDown': (ev) => arrowLeftMouseDown(ev)},'<');
    var rightArrowButton = button({'onMouseDown': (ev) => arrowRightMouseDown(ev)},'>');
    
    var leftArrowDiv = div({'className' : 'left-arrow'},leftArrowButton);
    var selectorItemsListDiv = div({'className' : 'round-list-fixed-width'}, _items);
    var rightArrowDiv = div({'className' : 'right-arrow'},rightArrowButton);
    
    return div({'className' : 'round-selector round-selector-full'},[leftArrowDiv, selectorItemsListDiv, rightArrowDiv]);
  }
  
  mouseDown(ev, item) {
    clicked = item;
    load(item).then((loaded){
      if (loaded) {
        selected.value = item;
        clicked = null;
        print(item);
        redraw();
      }
    });
    redraw();
  }
  
  arrowLeftMouseDown(ev) {
    
    redraw();
  }
  
  arrowRightMouseDown(ev) {
    
    redraw();
  }
}

