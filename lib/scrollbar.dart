library scrollbar;

import 'package:react/react.dart';
import 'dart:async';
import 'dart:math';
import 'dart:html';
import 'package:components/componentsTypes.dart';




class _UpdateOnChildrenChange extends Component {
  static register() {
     var r = registerComponent(() => new _UpdateOnChildrenChange());
     return (children) => r({}, children);
  }

  shouldComponentUpdate(nextProps, nextState) =>
    (nextProps['children'] != props['children']);

  render() => div({}, props['children']);
}

var _updateOnChildrenChange = _UpdateOnChildrenChange.register();

class ScrollbarComponent extends Component {
  var barTop;
  var contentTop;
  var barHeight;
  var startY;
  var startTop;
  var contentHeight;
  var windowHeight;
  Window htmlWindow;
  var redrawInvoked;
  var dragOnWindow;
  StreamSubscription ssMouseMove;
  StreamSubscription ssMouseUp;
  StreamSubscription ssTouchMove;
  StreamSubscription ssTouchEnd;
  get children => props['children'];
  get scrollStep => props['scrollStep'];
  get containerClass => props['containerClass'];

  get barHeightPx => (contentHeight == 0? windowHeight : windowHeight*windowHeight/contentHeight).round();

  ScrollbarComponent(this.htmlWindow);

  static ScrollbarType register(Window window) {
    var _registeredComponent = registerComponent(() => new ScrollbarComponent(window));
    return (children, {String containerClass : '', int scrollStep: 60 , scrollToPercent: null}) {

      return _registeredComponent({
        'containerClass':containerClass,
        'scrollStep':scrollStep,
        'scrollToPercent': scrollToPercent
      }, children);
    };
  }

  componentWillMount() {
    barTop = 0;
    contentTop = 0;
    dragOnWindow = false;
    redrawInvoked = false;
    pendingRedraw = false;
    //print('Number of children '+children.length.toString());
    //print('Scroll step: $scrollStep');
    var start = 97;
  }

  render() =>
    div({'className':'${containerClass}','style':{'position':'relative'}},[
      div({'className':'list-scrollbar'+(barHeight == 100 ? ' hide' : ''),
           'style':{'height':'${windowHeight}px'}},[
        div({'className':'dragger', 'style':{'top':'${barTop}px',
             'height':'${barHeight}%'},
             'ref': 'dragger'})
      ]),
      div({'className':'list-scrollable', 'ref': 'contentContainer'},[
        div({'className':'list-content','ref':'content',
             'style':{'top':contentTop.toString()+'px'}},
          _updateOnChildrenChange(children)
        )
      ])
    ]);


  recalculateBorders() {
    var content = ref('content');
    var window = ref('contentContainer');
    windowHeight = window.clientHeight;
    contentHeight = content.scrollHeight;
    if (contentHeight > 0) {
      barHeight = 100*(windowHeight/contentHeight);
      if (barHeight > 100) barHeight = 100;
    } else {
      barHeight = 100;
    }

    if (contentTop + contentHeight < windowHeight) {
      contentTop = windowHeight - contentHeight;
    }

    if (contentTop > 0) {
      contentTop = 0;
    }

    barTop = -(contentHeight == 0 ? 0 : contentTop*windowHeight/contentHeight).round();
  }

  List<StreamSubscription> reactionsToScrolling;
  componentDidMount(HtmlElement root) {
    var dragger = ref('dragger') as HtmlElement;
    var contentContainer = ref('contentContainer') as HtmlElement;
    reactionsToScrolling = [
       dragger.onMouseDown.listen(mouseDown),
       dragger.onTouchStart.listen((ev) => touchStart(ev, onWindow: false)),
       contentContainer.onMouseWheel.listen((ev) => onWheel(ev,scrollStep)),
       contentContainer.onTouchStart.listen((ev) => touchStart(ev, onWindow: true))
    ];
    recalculateBorders();
    if (props['scrollToPercent'] != null) moveToScrollPercent(props['scrollToPercent']);
    redrawInvoked = true;
    redraw();
  }

  componentWillUnmount() {
    reactionsToScrolling.forEach((ss) => ss.cancel());
  }

  componentDidUpdate(prevProps, prevState, rootNode) {
   if (!redrawInvoked) {
      recalculateBorders();
      redrawInvoked = true;
      myRedraw();
    } else {
      redrawInvoked = false;
    }
  }

  moveToScrollPercent(scrollPercent) {
    if (barHeight == 100) return;
    var newCntTop;
     var newBarTop;
     if (contentHeight > 0) {
       //scrollTo percena
         // Scroll down
         newCntTop = -scrollPercent * contentHeight;
         newBarTop = windowHeight*scrollPercent;
         if (newBarTop + barHeightPx > windowHeight) {
           newBarTop = windowHeight - barHeightPx;
           newCntTop = windowHeight - contentHeight;
       }
     } else {
       newBarTop = 0;
       newCntTop = 0;
     }
     barTop = newBarTop;
     contentTop = newCntTop;
  }

  onWheel(WheelEvent ev,step) {
    if (barHeight == 100) return;
    ev.preventDefault();
    var newCntTop;
    var newBarTop;
    if (contentHeight > 0) {
      if (ev.deltaY < 0) {
        // Scroll up
        newCntTop = contentTop + step;
        newBarTop = barTop - windowHeight*(step/contentHeight);
        if (newBarTop < 0) {
          newBarTop = 0;
          newCntTop = 0;
        }
      } else {
        // Scroll down
        newCntTop = contentTop - step;
        newBarTop = barTop + windowHeight*(step/contentHeight);
        if (newBarTop + barHeightPx > windowHeight) {
          newBarTop = windowHeight - barHeightPx;
          newCntTop = windowHeight - contentHeight;
        }
      }
    } else {
      newBarTop = 0;
      newCntTop = 0;
    }
    barTop = newBarTop;
    contentTop = newCntTop;
    redrawInvoked = true;
    redraw();
  }

  touchStart(TouchEvent ev, {onWindow: false}) {
    // Always dart event
    if (barHeight == 100) return;
    dragOnWindow = onWindow;
    ev.preventDefault();
    downEventOn(new Point(ev.touches[0].page.x,ev.touches[0].page.y));
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
    ssTouchMove = htmlWindow.onTouchMove.listen(touchMove);
    ssTouchEnd = htmlWindow.onTouchEnd.listen(touchEnd);
  }

  touchMove(ev) {
    /* As we are listening on window, the events passed here are not from React,
     but the former events from Dart */
    moveEventOn(new Point(ev.touches[0].page.x,ev.touches[0].page.y));
  }

  touchEnd(ev) {
    dragOnWindow = false;
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
  }

  mouseDown(MouseEvent ev) {
    ev.preventDefault();
    downEventOn(new Point(ev.page.x,ev.page.y));
    dragOnWindow = false;

    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
    ssMouseMove = htmlWindow.onMouseMove.listen(mouseMove);
    ssMouseUp = htmlWindow.onMouseUp.listen(mouseUp);
  }

  mouseMove(ev) {
    // Listening on window -> Dart MouseEvent
    moveEventOn(new Point(ev.page.x, ev.page.y));
  }

  mouseUp(ev) {
    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
  }

  downEventOn(pos) {
    startY = pos.y;
    if (dragOnWindow) {
      startTop = contentTop;
    } else {
      startTop = barTop;
    }
  }

  moveEventOn(pos) {
    var diffY = pos.y - startY;
    var newTop = startTop + diffY;
    if (dragOnWindow) {
      if (newTop + contentHeight < windowHeight) {
        newTop = windowHeight - contentHeight;
      }
      if (newTop > 0) {
        newTop = 0;
      }
      contentTop = newTop;
      barTop = -(contentHeight == 0 ? 0 : contentTop*windowHeight/contentHeight).round();
    } else {
      if (newTop + barHeightPx > windowHeight) {
        newTop = windowHeight - barHeightPx;
      }
      if (newTop < 0) {
        newTop = 0;
      }
      barTop = newTop;
      contentTop = -(windowHeight == 0 ? 0 :barTop*contentHeight/windowHeight).round();
    }
    redrawInvoked = true;
    myRedraw();
  }

  bool pendingRedraw = false;
  myRedraw() {
    if(!pendingRedraw) {
      Timer.run(() { pendingRedraw = false; redraw(); });
      pendingRedraw = true;
    }
  }

}