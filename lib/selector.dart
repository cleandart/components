library selector;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:html';

class SelectorComponent extends Component {
 
  DataReference get selected => props['selected'];
  DataReference get loading => props['loading'];
  DataReference get active => props['active'];
  
  get items => props['items'];
  get selectorText => props['selectorText'];
  get fullSize => props['fullSize'];
  //get scrollStep => props['scrollStep'];
  
  var scrollStep;
  var browserWindow;


  componentWillMount() {
    selected.onChange.listen((_) => redraw());
    loading.onChange.listen((_) => redraw());
    active.onChange.listen((_) => redraw());
    
    browserWindow = window;
    browserWindow.onResize.listen(checkAndSetScrollStep);

    scrollStep = 16;
  }
  
  componentDidMount(_) {
    setScrollStepSize();
    
    var _scrollListDiv = ref('round-list');
    var _itemSpan = ref(items[0].toString());
    var _spanWidth = _itemSpan.marginEdge.width;
    var _visibleItemsWindowSize = scrollStep * _spanWidth;
    var activeItemOrder = 0;
    
    for (int i=0; i<items.length; i++){
      if (items[i] == active.value){
        activeItemOrder = i;
      }
    }
    var _scrollStep = (0 - (activeItemOrder * 
                            _spanWidth - _visibleItemsWindowSize * 0.8)).round();
    
    checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
  }
  
  render() {
    var _items = [];
    for (var item in items) {
      if (selected.value == item) {
        _items.add(span({'ref' : '$item', 'key': item, 
          'onMouseDown': (ev) => mouseDown(ev, item), 
          'className' : 'selected'}, item));
      }
      else if (loading.value == item) {
//TODO: missing css class for loading element
        _items.add(span({'ref' : '$item', 'key': item, 
          'onMouseDown': (ev) => mouseDown(ev, item), 'className' : '', 
          'style' : {'background-color' : 'red'}}, item)); 
      }
      else if (active.value == item) {
        _items.add(span({'ref' : '$item', 'key': item, 
          'onMouseDown': (ev) => mouseDown(ev, item), 
          'className' : 'active'}, item));
      }
      else {
        _items.add(span({'ref' : '$item', 'key': item, 
          'onMouseDown': (ev) => mouseDown(ev, item)}, item));  
      }
    }
    
    var leftArrowButton = div({'key': 'leftArrowButton', 'onMouseDown': (ev) => 
        arrowLeftRightMouseDown(ev, true)}, '<');
    var rightArrowButton = div({'key': 'rightArrowButton', 'onMouseDown': (ev) => 
        arrowLeftRightMouseDown(ev, false)}, '>');
    
    var textSpan = span({'key': selectorText, 
      'className' : 'round-selector-text'}, selectorText);
    var leftArrowDiv = div({'key': 'leftArrow', 
      'className' : 'left-arrow'}, leftArrowButton);
    var selectorItemsListDiv = div({'ref' : 'itemsDiv', 
      'className' : 'round-list-fixed-width'},
        div({'ref' : 'round-list', 'className' : 'round-list'}, _items));
    var rightArrowDiv = div({'key': 'rightArrow', 
      'className' : 'right-arrow'}, rightArrowButton);
    
    var _cssSelectorClass = 'round-selector';
    
    if (fullSize){
      _cssSelectorClass = 'round-selector round-selector-full';
    }
    
    return div({'className' : _cssSelectorClass},
        [textSpan, leftArrowDiv, selectorItemsListDiv, rightArrowDiv]);
  }

  checkAndSetScrollStep(_){
    setScrollStepSize();
    
    var _scrollListDiv = ref('round-list');
    var _scrollStep = _scrollListDiv.style.left;
    
    if (_scrollStep == '') {
      _scrollListDiv.style.left = '-5px';
      _scrollStep = '-5px';
    }

    _scrollStep = _scrollStep.replaceAll('px','');
    _scrollStep = num.parse(_scrollStep).round();
    
    checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
  }
  
  mouseDown(ev, item) {
    loading.value = item;
  }
  
  arrowLeftRightMouseDown(ev,isLeft) {
    var _itemSpan = ref(items[0].toString());
    var _scrollListDiv = ref('round-list');
    var _visibleItemsWindowSize = scrollStep * _itemSpan.marginEdge.width;
    var _scrollStep = _scrollListDiv.style.left;

    setScrollStepSize();
    
    if (_scrollStep == '') {
      _scrollListDiv.style.left = '-5px';
      _scrollStep = '-5px';
    }

    _scrollStep = _scrollStep.replaceAll('px','');
    _scrollStep = num.parse(_scrollStep).round();

    if (isLeft) {
      _scrollStep += _visibleItemsWindowSize;
    }
    else {
      _scrollStep -= _visibleItemsWindowSize;
    }

    checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
  }
  
  num getMinMarginLeft() {
    var _itemSpan = ref(items[0].toString());
    var _spanWidth = _itemSpan.marginEdge.width;
    var _visibleItemsWindowSize = scrollStep * _spanWidth;
    
    return (0 - _spanWidth * items.length + _visibleItemsWindowSize); 
  }
  
  setScrollStepSize() {
    var _itemsDivWindowSize = ref('itemsDiv').marginEdge.width;

    if (_itemsDivWindowSize <= 240) { //phone size
      scrollStep = 6;
    }
    else if (_itemsDivWindowSize <= 600) { //tablet size
      scrollStep = 10;
    }
    else { //big size
      scrollStep = 16;
    }
  }
  
  checkSetScrollStepRedraw(_scrollStep, _scrollListDiv){
    if (_scrollStep > 0){
      _scrollStep = 0;
    }
    
    if (_scrollStep < getMinMarginLeft()) {
      _scrollStep = getMinMarginLeft();
    }
    _scrollListDiv.style.left = '${_scrollStep}px';
    redraw();
  }
}