library selector_new;
import 'package:react/react.dart';
import 'package:components/componentsTypes.dart';
import 'dart:html';
import 'dart:async';

const VALUE = "value";
const TEXT = "text";
const CLASSNAME = "className";

class SelectorNewComponent extends Component {

  SelectorNewComponent();

  static SelectorNewType register() {
    var _registeredComponent = registerComponent(() => new SelectorNewComponent());
    return (List items, String selectorClass, String selectorText, bool showFirstLast, Function onChange) {
      return _registeredComponent({
        "items": items,
        "selectorClass": selectorClass,
        "selectorText" : selectorText,
        "showFirstLast" : showFirstLast,
        "onChange": onChange,
      });
    };
  }

  List get items => props["items"];
  Function get onChange => props["onChange"];
  String get selectorClass => props["selectorClass"];
  String get selectorText => props["selectorText"];
  bool get showFirstLast => props["showFirstLast"];

  get _visibleItemsWindowSize => ref('itemsDiv') != null ? ref('itemsDiv').marginEdge.width : null;
  get _shownItemCount => _visibleItemsWindowSize ~/ _spanWidth;
  get _shouldDrawLeft => true;
  get _shouldDrawRight => true;
  get _scrollListWidth => _spanWidth*(lastIndex-firstIndex);

  get noAnimationClass => "transition-disabled";

  var _firstIndex = 0; // inclusive
  var _lastIndex = 1;  // exclusive
  var _spanWidth;

  get lastIndex => _lastIndex;
  set lastIndex(val) {
    _lastIndex = val;
    adjustIndexes();
  }

  get firstIndex => _firstIndex;
  set firstIndex(val) {
    _firstIndex = val;
    adjustIndexes();
  }


  DivElement _scrollListDiv;
  List<StreamSubscription> ss;
  bool useAnimation = false;
  bool clickAllowed = true;

  min(num a, num b) => a < b ? a : b;

  adjustIndexes() {
    if (_firstIndex < 0) {
      _firstIndex = 0;
    }
    if (_lastIndex > items.length) _lastIndex = items.length;
  }

  _adjustScrollDiv() {
    var firstShownIndex;
    if (marginToNum(_scrollListDiv.style.marginLeft) == 0) {
      // Moved left, first _shownItemCount items from firstIndex are currently shown
      firstShownIndex = firstIndex;
    } else {
      // Moved right, last _shownItemCount items up to lastIndex are currently shown
      firstShownIndex = lastIndex - _shownItemCount;
    }
    firstIndex = firstShownIndex - _shownItemCount;
    lastIndex = firstShownIndex + 2*_shownItemCount;
    useAnimation = false;

    _scrollListDiv.style.marginLeft = '${(firstIndex - firstShownIndex)*_spanWidth}px';
    redraw();
  }

  componentDidMount(root) {
    _scrollListDiv = ref('round-list');
    _spanWidth = ref('${items[firstIndex][VALUE]}').marginEdge.width;
    ss = [];
    ss.add(_scrollListDiv.onTransitionEnd.where((t) => t.target is DivElement && (t.target as DivElement).className.contains("round-list")).listen((_) {
      clickAllowed = true;
      _adjustScrollDiv();
    }));
    lastIndex = 2*_shownItemCount;
    redraw();
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
          _scrollListDiv.style.marginLeft != "${_visibleItemsWindowSize - _scrollListWidth}px";

  scroll({toLeft: true}) {
    if (clickAllowed) {
      clickAllowed = !transitionWillHappen(toLeft: toLeft);
      useAnimation = true;
      if (toLeft) {
        _scrollListDiv.style.marginLeft = "0px";
      } else {
        _scrollListDiv.style.marginLeft = "${_visibleItemsWindowSize - _scrollListWidth}px";
      }
      redraw();
    }
  }

  showFirst() {
    if (clickAllowed) {
      useAnimation = false;
      firstIndex = 0;
      lastIndex = 2*_shownItemCount;
      _scrollListDiv.style.marginLeft = "0px";
      redraw();
    }
  }

  showLast() {
    if (clickAllowed) {
      useAnimation = false;
      lastIndex = items.length;
      firstIndex = lastIndex - 2*_shownItemCount;
      _scrollListDiv.style.marginLeft = "${_visibleItemsWindowSize - _scrollListWidth}px";
      redraw();
    }
  }

  _getArrowClass(isLeft) =>
      "${isLeft ?
             "left"
           :
             "right"}-arrow${
             isLeft ?
               _shouldDrawLeft ?
                   ""
                 :
                   " disabled"
               :
                 _shouldDrawRight ?
                   ""
                 :
                   " disabled"}";

  _renderArrow(isLeft) =>
      div({"className": _getArrowClass(isLeft)},
          div({"onMouseDown": (ev) => scroll(toLeft: isLeft)}, isLeft?"<":">"));

  _renderFastLeftArrow() =>
      div({'className' : _getArrowClass(true), 'onMouseDown' : (ev) => showFirst()},'<<');
  _renderFastRightArrow() =>
      div({'className' : _getArrowClass(false), 'onMouseDown' : (ev) => showLast()},'>>');

  render() =>
     div({'className': selectorClass}, [
        span({"className": "round-selector-text"}, selectorText),
        showFirstLast ? _renderFastLeftArrow() : div(),
        _renderArrow(true),
        div({"ref": "itemsDiv", "className": "round-list-fixed-width"},
            div({
                  "ref":"round-list",
                  "className" : "round-list ${useAnimation ? "" : noAnimationClass}",

                },  items.getRange(firstIndex, lastIndex).map((item) => span({
                      'ref' : '${item[VALUE]}',
                      'onMouseDown': (_) => onChange(item),
                      'className': item[CLASSNAME],
                    }, item[TEXT])).toList()
            )
        ),
        _renderArrow(false),
        showFirstLast ? _renderFastRightArrow() : div()
      ]);

}