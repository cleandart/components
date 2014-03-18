library scrollbar;

import 'package:react/react.dart';
import 'dart:async';
import 'dart:math';

typedef ScrollbarType(List children, {String containerClass, int scrollStep});

class ScrollbarComponent extends Component {

  var barTop;
  var contentTop;
  var barHeight;
  var startY;
  var startTop;
  var contentId;
  var windowId;
  var contentHeight;
  var windowHeight;
  var window;
  var htmlWindow;
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

  ScrollbarComponent(_htmlWindow) {
    htmlWindow = _htmlWindow;
  }

  static ScrollbarType register(window) {
    var _registeredComponent = registerComponent(() => new ScrollbarComponent(window));
    return (children, {String containerClass : '', int scrollStep: 60 }) {

      return _registeredComponent({
        'containerClass':containerClass,
        'scrollStep':scrollStep
      }, children);
    };
  }

  componentWillMount() {
    barTop = 0;
    contentTop = 0;
    dragOnWindow = false;
    redrawInvoked = false;
    print('Number of children '+children.length.toString());
    print('Scroll step: $scrollStep');
    var start = 97;
    var rnd = new Random();
    contentId = 'Scrollbar${rnd.nextInt(100000)}';
    windowId = 'Window${rnd.nextInt(100000)}';
    print('Scrollbar content Id is: $contentId');
    print('Scrollbar window Id is: $windowId');
  }

  render() {
  // print('Render');
  return
    div({'className':'${containerClass}','style':{'position':'relative'}},[
      div({'className':'list-scrollbar'+(barHeight == 100 ? ' hide' : ''),
           'style':{'height':'${windowHeight}px'}},[
        div({'className':'dragger', 'style':{'top':'${barTop}px',
             'height':'${barHeight}%'},
             'onMouseDown': mouseDown,
             'onTouchStart': (ev) => touchStart(ev, onWindow: false)},[])
      ]),
      div({'className':'list-scrollable',
           'ref':'${windowId}',
           'onWheel':(ev) => onWheel(ev,scrollStep),
           'onClick': (ev) => print('CLICKED !'),
           'onTouchStart': (ev) => touchStart(ev, onWindow: true)},[
        div({'className':'list-content','ref':'${contentId}',
             'style':{'top':contentTop.toString()+'px'}},
          children
        )
      ])
    ]);
  }

  recalculateBorders() {
    var content = ref('$contentId');
    window = ref('$windowId');
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

  componentDidMount(root) {
    recalculateBorders();
    redrawInvoked = true;
    redraw();
  }

  componentDidUpdate(prevProps, prevState, rootNode) {
   if (!redrawInvoked) {
      recalculateBorders();
      redrawInvoked = true;
      redraw();
    } else {
      redrawInvoked = false;
    }
  }

  preventDefaultBehaviour(ev) {
    try {
      ev.nativeEvent.preventDefault();
    } catch (e) {
      try {
        ev.preventDefault();
      } catch (e) {
        print('Could not prevent default behaviour, error: $e');
      }
    }
  }

  getPointFromTouch(ev) {
    var posX, posY;
    try {
      posX = ev.nativeEvent.touches[0].page.x;
      posY = ev.nativeEvent.touches[0].page.y;
    } catch (e) {
      try {
        posX = ev.touches[0].page.x;
        posY = ev.touches[0].page.y;
      } catch (e) {
        print('Cannot get touch position, error: $e');
      }
    }
    return new Point(posX,posY);
  }

  getPointFromMouse(ev) {
    var posX, posY;
    if (ev is SyntheticMouseEvent) {
      posX = ev.pageX;
      posY = ev.pageY;
    } else {
      posX = ev.page.x;
      posY = ev.page.y;
    }
    return new Point(posX, posY);
  }

  onWheel(ev,step) {
    if (barHeight == 100) return;
    if (ev is SyntheticMouseEvent) {
      ev.nativeEvent.preventDefault();
    } else {
      ev.preventDefault();
    }
    var newCntTop;
    var newBarTop;
    if (contentHeight > 0) {
      if (ev.deltaY > 0) {
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

  touchStart(ev, {onWindow: false}) {
    dragOnWindow = onWindow;
    preventDefaultBehaviour(ev);
    downEventOn(getPointFromTouch(ev));
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
    ssTouchMove = htmlWindow.onTouchMove.listen(touchMove);
    ssTouchEnd = htmlWindow.onTouchEnd.listen(touchEnd);
  }

  touchMove(ev) {
    moveEventOn(getPointFromTouch(ev));
  }

  touchEnd(ev) {
    dragOnWindow = false;
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
  }

  mouseDown(ev) {
    preventDefaultBehaviour(ev);
    downEventOn(getPointFromMouse(ev));
    dragOnWindow = false;

    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
    ssMouseMove = htmlWindow.onMouseMove.listen(mouseMove);
    ssMouseUp = htmlWindow.onMouseUp.listen(mouseUp);

  }

  mouseMove(ev) {
    moveEventOn(getPointFromMouse(ev));
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
    redraw();
  }

}