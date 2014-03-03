library selector;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
//import 'dart:async';
import 'dart:html';

class SelectorComponent extends Component {
 
  DataReference selected; // => props['selected'];
  var clicked;
  
  get items => props['items'];
  get load => props['load'];
  get scrollStep => props['scrollStep'];
  
  
  SelectorComponent() {    
  }
  
  componentWillMount() {
    selected = new DataReference(props['selected']);
  }
  
  render() {
    var _items = [];
    for (var item in items) {
      if (selected.value == item){
        _items.add(span({'onMouseDown': (ev) => mouseDown(ev, item),
            'className' : 'active'},item));
      }
      else if (clicked == item){
        _items.add(span({'onMouseDown': (ev) => mouseDown(ev, item), 
            'className' : 'selected'},item));
      }
      else {
        _items.add(span({'onMouseDown': (ev) => mouseDown(ev, item)},item));  
      }
    }
    
    var leftArrowButton = div({'onMouseDown': (ev) => 
        arrowLeftRightMouseDown(ev, true)},'<');
    var rightArrowButton = div({'onMouseDown': (ev) => 
        arrowLeftRightMouseDown(ev, false)},'>');
    
    var leftArrowDiv = div({'className' : 'left-arrow'},leftArrowButton);
    var selectorItemsListDiv = div({'className' : 'round-list-fixed-width'},
        div({'className' : 'round-list'}, _items));
    var rightArrowDiv = div({'className' : 'right-arrow'},rightArrowButton);
    
    return div({'className' : 'round-selector round-selector-full'},
        [leftArrowDiv, selectorItemsListDiv, rightArrowDiv]);
  }
  
  mouseDown(ev, item) {
    clicked = item;
    load(item).then((loaded){
      if (loaded) {
        selected.value = item;
        clicked = null;
        redraw();
      }
    });
    redraw();
  }
  
  arrowLeftRightMouseDown(ev,isLeft) {
    var _scrollListDiv = querySelector('.round-list');
    var _visibleItemsWindowSize = scrollStep * 
        querySelector('.round-selector-full span').marginEdge.width;
    var _scrollStep = _scrollListDiv.style.left;

    if (_scrollStep == '') {
      _scrollListDiv.style.left = '-5px';
      _scrollStep = '-5px';
    }
    
    _scrollStep = _scrollStep.replaceAll('px','');
    _scrollStep = int.parse(_scrollStep);

    if (isLeft) {
      _scrollStep += _visibleItemsWindowSize;
    }
    else {
      _scrollStep -= _visibleItemsWindowSize;
    }
    
    if (_scrollStep > 0){
      _scrollStep = 0;
    }
    
    if (_scrollStep < getMinMarginLeft()) {
      _scrollStep = getMinMarginLeft();
    }
    
    _scrollListDiv.style.left = '${_scrollStep}px';
    redraw();
  }
  
  num getMinMarginLeft() {
    var _itemSpan = querySelector('.round-selector-full span');
    var _spanWidth = _itemSpan.marginEdge.width;
    var _visibleItemsWindowSize = scrollStep * 
        querySelector('.round-selector-full span').marginEdge.width;
    
    return (0 - _spanWidth * items.length + _visibleItemsWindowSize); 
  }
}

