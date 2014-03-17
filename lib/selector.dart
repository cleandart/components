library selector;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:async';

typedef SelectorType(List items, DataReference selected,
                    DataReference active, DataReference loading,
                    {String key, String selectorText, bool fullSize});


class SelectorComponent extends Component {

  DataReference get selected => props['selected'];
  DataReference get loading => props['loading'];
  DataReference get active => props['active'];

  List get items => props['items'];
  String get selectorText => props['selectorText'];
  bool get fullSize => props['fullSize'];

  num scrollStep;
  var browserWindow;

  static const String VALUE = 'value';
  static const String TEXT = 'text';

  List<StreamSubscription> subscriptions;

  SelectorComponent(this.browserWindow);

  static SelectorType register(window) {
    var _registeredComponent = registerComponent(() => new SelectorComponent(window));
    return (List items, DataReference selected,
        DataReference active, DataReference loading,
        {String key : 'selector', String selectorText : '', bool fullSize : true}) {

      return _registeredComponent({
        'key' : key,
        'selected' : selected,
        'active' : active,
        'loading' : loading,
        'items' : items,
        'selectorText' : selectorText,
        'fullSize' : fullSize
      });
    };
  }

  componentWillMount() {
    subscriptions = new List();

    subscriptions.add(selected.onChange.listen((_) => scrollToSelectedIfNotVisible()));
    subscriptions.add(loading.onChange.listen((_) => redraw()));
    subscriptions.add(active.onChange.listen((_) => redraw()));
    subscriptions.add(browserWindow.onResize.listen(checkAndSetScrollStep));

    scrollStep = 16;
  }

  componentDidMount(_) {
    setScrollStepSize();

    var _scrollListDiv = ref('round-list');
    var _itemSpan = ref(items[0][VALUE].toString());
    var _spanWidth = _itemSpan.marginEdge.width;
    var _visibleItemsWindowSize = scrollStep * _spanWidth;
    var selectedItemOrder = 0;

    if (items.length > 40){ //hack due to testing 100 items in rounds, causing troubles with css width of round-list div
      _scrollListDiv.style.width = '4000px';
    }
    selectedItemOrder = items.map((e) => e[VALUE]).toList().indexOf(selected.value);

    var _scrollStep = (0 - (selectedItemOrder *
                            _spanWidth - _visibleItemsWindowSize * 0.8)).round();

    checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
  }

  componentWillUnmount(){
    for (StreamSubscription subscr in subscriptions) {
      subscr.cancel();
    }
  }

  render() {
    var _items = [];
    for (var item in items) {
      var classes = [];
      var className = '';
      if (selected.value == item[VALUE]) classes.add('selected');
      if (active.value == item[VALUE]) classes.add('active');
      if (loading.value == item[VALUE]) classes.add('loading');
      _items.add(span({'ref' : '${item[VALUE]}', 'key': '${item[VALUE]}',
        'onMouseDown': (ev) => mouseDown(item),
        'className' : '${classes.join(" ")}'}, '${item[TEXT]}'));
    }

    var leftArrowButton = div({'key': 'leftArrowButton', 'onMouseDown': (ev) =>
        scroll(toLeft: true)}, '<');
    var rightArrowButton = div({'key': 'rightArrowButton', 'onMouseDown': (ev) =>
        scroll(toLeft: false)}, '>');

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

  scrollToSelectedIfNotVisible() {
    setScrollStepSize();

    var _scrollListDiv = ref('round-list');
    var _itemSpan = ref(items[0][VALUE].toString());
    var _spanWidth = _itemSpan.marginEdge.width;
    var _visibleItemsWindowSize = scrollStep * _spanWidth;
    var selectedItemOrder = 0;

    selectedItemOrder = items.map((e) => e[VALUE]).toList().indexOf(selected.value);

    var _scrollStep = (0 - (selectedItemOrder *
                            _spanWidth - _visibleItemsWindowSize * 0.8)).round();

    var _leftMargin = _scrollListDiv.style.marginLeft.replaceAll('px','');
    _leftMargin = num.parse(_leftMargin).round();

    var mostLeftItem = -_leftMargin / _spanWidth;
    var mostRightItem =  (-_leftMargin + _visibleItemsWindowSize) / _spanWidth;

    if (selectedItemOrder < mostLeftItem || selectedItemOrder > mostRightItem) {
      checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
    }
    else {
      redraw();
    }
  }

  checkAndSetScrollStep(_){
    setScrollStepSize();

    var _scrollListDiv = ref('round-list');
    var _scrollStep = _scrollListDiv.style.marginLeft;

    if (_scrollStep == '') {
      _scrollListDiv.style.marginLeft = '-5px';
      _scrollStep = '-5px';
    }

    _scrollStep = _scrollStep.replaceAll('px','');
    _scrollStep = num.parse(_scrollStep).round();

    checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
  }

  mouseDown(item) {
    loading.value = item[VALUE];
  }

  scroll({toLeft: true}) {
    var _itemSpan = ref(items[0][VALUE].toString());
    var _scrollListDiv = ref('round-list');
    var _visibleItemsWindowSize = scrollStep * _itemSpan.marginEdge.width;
    var _scrollStep = _scrollListDiv.style.marginLeft;

    setScrollStepSize();

    if (_scrollStep == '') {
      _scrollListDiv.style.marginLeft = '-5px';
      _scrollStep = '-5px';
    }

    _scrollStep = _scrollStep.replaceAll('px','');
    _scrollStep = num.parse(_scrollStep).round();

    if (toLeft) {
      _scrollStep += _visibleItemsWindowSize;
    }
    else {
      _scrollStep -= _visibleItemsWindowSize;
    }

    checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
  }

  num getMinMarginLeft() {
    var _itemSpan = ref(items[0][VALUE].toString());
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

    if (scrollStep >= items.length) _scrollStep = 0;

    _scrollListDiv.style.marginLeft = '${_scrollStep}px';
    redraw();
  }
}
