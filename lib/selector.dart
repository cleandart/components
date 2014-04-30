library selector;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'dart:async';

typedef SelectorType(List items, DataReference selected,
                    DataReference active, DataReference loading,
                    {String key, String selectorText, bool showFirstLast,
                      String className, onChange});


class SelectorComponent extends Component {

  DataReference get selected => props['selected'];
  DataReference get loading => props['loading'];
  DataReference get active => props['active'];

  List get items => props['items'];
  String get selectorText => props['selectorText'];
  get _onChange => props['onChange'] != null ? props['onChange'] : _defaultOnChange;
  get _cssSelectorClass => props['className'] != null ? props['className'] : 'round-selector';
  get _showFirstLast => props['showFirstLast'];

  get _visibleItemsWindowSize => ref('itemsDiv') != null ? ref('itemsDiv').marginEdge.width : null;
  get _spanWidth => ref('${items[0][VALUE]}') != null ? ref('${items[0][VALUE]}').marginEdge.width : null;

  var browserWindow;

  static const String VALUE = 'value';
  static const String TEXT = 'text';

  List<StreamSubscription> subscriptions;

  SelectorComponent(this.browserWindow);

  static SelectorType register(window) {
    var _registeredComponent = registerComponent(() => new SelectorComponent(window));
    return (List items, DataReference selected,
        DataReference active, DataReference loading,
        {String key : 'selector', String selectorText : '', bool showFirstLast: false, String className,
          onChange}) {

      return _registeredComponent({
        'key' : key,
        'selected' : selected,
        'active' : active,
        'loading' : loading,
        'items' : items,
        'selectorText' : selectorText,
        'className' : className,
        'onChange': onChange,
        'showFirstLast' : showFirstLast,
      });
    };
  }

  componentWillMount() {
    subscriptions = new List();

    subscriptions.add(selected.onChange.listen((_) => scrollToSelectedIfNotVisible()));
    subscriptions.add(loading.onChange.listen((_) => redraw()));
    subscriptions.add(active.onChange.listen((_) => redraw()));
    subscriptions.add(browserWindow.onResize.listen(checkAndSetScrollStep));

  }

  componentDidMount(_) {

    var _scrollListDiv = ref('round-list');
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

  _defaultOnChange(item) {
    loading.value = item[VALUE];
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
        'onMouseDown': (ev) => _onChange(item),
        'className' : '${classes.join(" ")}'}, '${item[TEXT]}'));
    }

    var leftArrowButton = div({'key': 'leftArrowButton', 'onMouseDown': (ev) =>
        scroll(toLeft: true)}, '<');
    var rightArrowButton = div({'key': 'rightArrowButton', 'onMouseDown': (ev) =>
        scroll(toLeft: false)}, '>');

    var showFirstDiv = div({'className' : 'left-arrow', 'onMouseDown' : (ev) => showFirst()},'<<');
    var showLastDiv = div({'className' : 'right-arrow', 'onMouseDown' : (ev) => showLast()}, '>>');

    var textSpan = span({'key': selectorText,
      'className' : 'round-selector-text'}, selectorText);
    var leftArrowDiv = div({'key': 'leftArrow',
      'className' : 'left-arrow'}, leftArrowButton);
    var selectorItemsListDiv = div({'ref' : 'itemsDiv',
      'className' : 'round-list-fixed-width'},
        div({'ref' : 'round-list', 'className' : 'round-list'}, _items));
    var rightArrowDiv = div({'key': 'rightArrow',
      'className' : 'right-arrow'}, rightArrowButton);

    List children = [textSpan, leftArrowDiv, selectorItemsListDiv, rightArrowDiv];
    if (_showFirstLast) {
      children.insert(1, showFirstDiv);
      children.add(showLastDiv);
    }

    return div({'className' : _cssSelectorClass},children);
  }

  scrollToSelectedIfNotVisible() {

    var _scrollListDiv = ref('round-list');
    var selectedItemOrder = 0;

    selectedItemOrder = items.map((e) => e[VALUE]).toList().indexOf(selected.value);

    var _scrollStep = (0 - (selectedItemOrder *
                            _spanWidth - _visibleItemsWindowSize * 0.8)).round();

    var _leftMargin = _scrollListDiv.style.marginLeft.replaceAll('px','');
    _leftMargin = num.parse(_leftMargin).round();

    var mostLeftItem = (-_leftMargin / _spanWidth).round();
    var mostRightItem =  ((-_leftMargin + _visibleItemsWindowSize) / _spanWidth).round();

    if (selectedItemOrder < mostLeftItem || selectedItemOrder >= mostRightItem) {
      checkSetScrollStepRedraw(_scrollStep, _scrollListDiv);
    }
    else {
      redraw();
    }
  }

  checkAndSetScrollStep(_){

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

  showFirst() =>
      checkSetScrollStepRedraw(0, ref('round-list'));

  showLast() =>
      checkSetScrollStepRedraw(getMinMarginLeft(), ref('round-list'));

  scroll({toLeft: true}) {
    var _itemSpan = ref(items[0][VALUE].toString());
    var _scrollListDiv = ref('round-list');
    var _scrollStep = _scrollListDiv.style.marginLeft;

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

  num getMinMarginLeft() =>
      (0 - _spanWidth * items.length + ref('itemsDiv').marginEdge.width);

  checkSetScrollStepRedraw(_scrollStep, _scrollListDiv){
    if (_scrollStep > 0){
      _scrollStep = 0;
    }

    if (_scrollStep < getMinMarginLeft()) {
      _scrollStep = getMinMarginLeft();
    }

    if (_visibleItemsWindowSize ~/_spanWidth >= items.length) _scrollStep = 0;

    _scrollListDiv.style.marginLeft = '${_scrollStep}px';
    redraw();
  }
}
