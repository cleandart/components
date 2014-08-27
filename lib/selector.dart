library selector;
import 'package:react/react.dart';
import 'package:components/componentsTypes.dart';
import 'dart:html';
import 'dart:async';
import "package:quiver/iterables.dart";

class SelectorComponent extends Component {

  static SelectorType register() {
    var _registeredComponent = registerComponent(() => new SelectorComponent());
    return (List items, Function onChange, {String selectorClass: "", String selectorText: "", bool showFirstLast: false, key: null}) {
      return _registeredComponent({
        "items": items,
        "selectorClass": selectorClass,
        "selectorText" : selectorText,
        "showFirstLast" : showFirstLast,
        "onChange": onChange,
//      }..addAll({"key": key == null ? "__length-only${items.length}" : "${key}-length${items.length}"}));
      }..addAll(key == null ? {} : {"key": key}));
    };
  }

  List get items => props["items"];
  Function get onChange => props["onChange"];
  String get selectorClass => props["selectorClass"];
  String get selectorText => props["selectorText"];
  bool get showFirstLast => props["showFirstLast"];

  get _visibleItemsWindowSize => ref('itemsDiv') != null ? ref('itemsDiv').marginEdge.width : null;
  get _shownItemCount => _visibleItemsWindowSize ~/ _spanWidth;
  get _minMarginLeft => min(_visibleItemsWindowSize - _scrollListWidth, 0);
  get _shouldDrawLeft => firstShownIndex != 0;
  get _shouldDrawRight => _scrollListDiv == null ? true : items.length > _shownItemCount && items.length - _shownItemCount > firstShownIndex;
  get _scrollListWidth => _spanWidth*(lastIndex-firstIndex);
  List get selectedIndices => _selectedIndices(items);

  get noAnimationClass => "transition-disabled";

  var _firstIndex = 0; // inclusive
  var _lastIndex = 1;  // exclusive
  var _firstShownIndex = 0;
  var _spanWidth;

  static const READY = "ready";
  static const BEFORE_ADJUST = "before_adjust";
  static const AFTER_ADJUST = "after_adjust";
  static const SCROLLING = "scrolling";
// READY -> SCROLLING -> BEFORE_ADJUST -> AFTER_ADJUST -> READY
// READY -> AFTER_ADJUST -> READY

  var _state = READY;

  get firstShownIndex => _firstShownIndex;
  set firstShownIndex(val) => _firstShownIndex = max(val, firstIndex);
  get lastIndex => _lastIndex;
  set lastIndex(val) {
    _lastIndex = val;
    adjustIndexes(items.length);
  }

  get firstIndex => _firstIndex;
  set firstIndex(val) {
    _firstIndex = val;
    adjustIndexes(items.length);
  }

  DivElement _scrollListDiv;
  List<StreamSubscription> ss;
  bool useAnimation = false;

  min(num a, num b) => a < b ? a : b;
  max(num a, num b) => -min(-a,-b);

  List _selectedIndices(items) => enumerate(items).where((e) => e.value[SELECTED]).map((e) => e.index).toList();

  adjustIndexes(maxIndex) {
    if (_firstIndex < 0) {
      _firstIndex = 0;
      if (_lastIndex < _firstIndex + 2*_shownItemCount) _lastIndex = min(_firstIndex + 2*_shownItemCount, maxIndex);
    }
    if (_lastIndex > maxIndex) {
      _lastIndex = maxIndex;
      if (_firstIndex > _lastIndex - 2*_shownItemCount) _firstIndex = max(_lastIndex - 2*_shownItemCount, 0);
    }
    if ((_lastIndex - _firstIndex < 2*_shownItemCount) && (_lastIndex - _firstIndex < maxIndex)) {
      _firstIndex = _lastIndex - 2*_shownItemCount;
      adjustIndexes(maxIndex);
    }

  }

  _moveScrollDivToFirstShown() {
    firstIndex = firstShownIndex - _shownItemCount;
    lastIndex = firstShownIndex + 2*_shownItemCount;
    _scrollListDiv.style.marginLeft = '${(firstIndex - firstShownIndex)*_spanWidth}px';
    _state = AFTER_ADJUST;
    redraw();
  }

  _adjustScrollDiv() {
    if (marginToNum(_scrollListDiv.style.marginLeft) == 0) {
      // Moved left, first _shownItemCount items from firstIndex are currently shown
      firstShownIndex = firstIndex;
    } else {
      // Moved right, last _shownItemCount items up to lastIndex are currently shown
      firstShownIndex = lastIndex - _shownItemCount;
    }
    _moveScrollDivToFirstShown();
  }

//  Index can be double !
  _scrollToIndex(num index, {num relativePos: 0.8}) {
    if (index < 0 || index > items.length) {
      throw new RangeError("Cannot scroll to index $index, out of range [0, ${items.length})");
    }
    firstShownIndex = min(max((index - _shownItemCount*relativePos).ceil(), 0), items.length - _shownItemCount);
    _moveScrollDivToFirstShown();
  }

// Returns index of a centroid in [items]. If it's not exactly on an item, it returns a double representing relative pos
// That said, if centroid is between indices 6 and 7, it returns 6.5
  num _calculateCentroid() {
    return selectedIndices.length == 0 ? 0 : selectedIndices.reduce((v,e) => v + e) / selectedIndices.length;
  }

  _scrollToCentroid() =>
    _scrollToIndex(_calculateCentroid());

  _reevaluateSpanWidth() => _spanWidth = ref('${items[firstIndex][VALUE]}').marginEdge.width;

  componentDidMount(root) {
    _scrollListDiv = ref('round-list');
    _reevaluateSpanWidth();
    ss = [];
    ss.add(_scrollListDiv.onTransitionEnd.where((t) => t.target is DivElement && (t.target as DivElement).className.contains("round-list")).listen((_) {
      _state = BEFORE_ADJUST;
      useAnimation = false;
      redraw();
    }));
    ss.add(window.onResize.listen((_) => _scrollToCentroid()));
    _scrollToCentroid();
    redraw();
  }

  componentWillUpdate(nextProps, nextState) {
    print("Current: ${items.length}, Next: ${nextProps["items"].length}");
    adjustIndexes(nextProps["items"].length);
  }

  componentDidUpdate(prevProps,__,___) {
    checkIfSelectedChanged() {
      List oldSel = _selectedIndices(prevProps["items"]);
      if (!(new Set.from(oldSel).containsAll(selectedIndices) && new Set.from(selectedIndices).containsAll(oldSel))
          || (items.length < prevProps["items"].length)) {
        var centroid = _calculateCentroid();
        if ((centroid < firstShownIndex) || (centroid > firstShownIndex + _shownItemCount)) {
          _scrollToCentroid();
        }
      }
    }
    switch(_state) {
      case READY: checkIfSelectedChanged(); break;
      case BEFORE_ADJUST: useAnimation = false; _adjustScrollDiv(); break;
      case AFTER_ADJUST: useAnimation = true; _state = READY; redraw(); break;
    }
  }

  componentWillUnmount() {
    ss.forEach((s) => s.cancel());
  }

  marginToNum(String margin) {
    if (margin == '') return -5;
    return num.parse(margin.replaceAll('px', '')).round();
  }

  bool transitionWillHappen({toLeft: true}) =>
      toLeft ?
          _scrollListDiv.style.marginLeft != "0px"
        :
          _visibleItemsWindowSize < _scrollListWidth && _scrollListDiv.style.marginLeft != "${_visibleItemsWindowSize - _scrollListWidth}px";

  scroll({toLeft: true}) {
    if (_state == READY) {
      _state = transitionWillHappen(toLeft: toLeft) ? SCROLLING : READY;
      if (toLeft) {
        _scrollListDiv.style.marginLeft = "0px";
      } else if(_visibleItemsWindowSize < _scrollListWidth) {
        _scrollListDiv.style.marginLeft = "${_visibleItemsWindowSize - _scrollListWidth}px";
      }
      redraw();
    }
  }

  showFirst() {
    if (_state == READY) {
      useAnimation = false;
      firstIndex = 0;
      firstShownIndex = 0;
      lastIndex = 2*_shownItemCount;
      _scrollListDiv.style.marginLeft = "0px";
      _state = AFTER_ADJUST;
      redraw();
    }
  }

  showLast() {
    if (_state == READY) {
      useAnimation = false;
      lastIndex = items.length;
      firstShownIndex = lastIndex - _shownItemCount;
      firstIndex = lastIndex - 2*_shownItemCount;
      _scrollListDiv.style.marginLeft = "${_minMarginLeft}px";
      _state = AFTER_ADJUST;
      redraw();
    }
  }

  _getArrowClass(isLeft) =>
      " ${isLeft ? "left" : "right"}-arrow "
      " ${(isLeft ? _shouldDrawLeft : _shouldDrawRight) ? "" : "disabled"} ";

  _renderArrow(isLeft) =>
      div({"className": _getArrowClass(isLeft)},
          div({"onMouseDown": (ev) => scroll(toLeft: isLeft)}, isLeft?"<":">"));

  _renderFastLeftArrow() =>
      div({'className' : _getArrowClass(true), 'onMouseDown' : (ev) => showFirst()},'<<');
  _renderFastRightArrow() =>
      div({'className' : _getArrowClass(false), 'onMouseDown' : (ev) => showLast()},'>>');

  render() {
    print("First: $firstIndex, Last: $lastIndex");
    return div({'className': selectorClass}, [
        span({"className": "round-selector-text"}, selectorText),
        showFirstLast ? _renderFastLeftArrow() : div({}),
        _renderArrow(true),
        div({"ref": "itemsDiv", "className": "round-list-fixed-width"},
            div({
                  "ref":"round-list",
                  "className" : "round-list ${useAnimation ? "" : noAnimationClass}",

                },  items.getRange(firstIndex, lastIndex).map((item) => span({
                      'ref' : '${item[VALUE]}',
                      'onMouseDown': (_) => onChange(item[VALUE]),
                      'className': "${item[CLASSNAME]} ${useAnimation ? "" : noAnimationClass}",
                    }, item[TEXT])).toList()
            )
        ),
        _renderArrow(false),
        showFirstLast ? _renderFastRightArrow() : div({})
      ]);
  }

}