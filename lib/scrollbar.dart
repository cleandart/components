library scrollbar;

import 'package:react/react.dart';
import 'dart:async';
import 'dart:math';
import 'dart:html';

var scrollbar = ScrollbarComponent.register(window);

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
  StreamSubscription ssMouseMove;
  StreamSubscription ssMouseUp;
  get children => props['children'];
  get scrollStep => props['scrollStep'];
  get containerClass => props['containerClass'];
  get barHeightPx => (windowHeight*windowHeight/contentHeight).round();
  
  ScrollbarComponent(_htmlWindow) {
    htmlWindow = _htmlWindow;
  }
  
  static ScrollbarType register(window) {
    var _registeredComponent = registerComponent(() => new ScrollbarComponent(window));
    return (children, {String containerClass : '', int scrollStep: 25}) {

      return _registeredComponent({
        'containerClass':containerClass,
        'scrollStep':scrollStep
      }, children);
    };
  }
  
  componentWillMount() {
    barTop = 0;
    contentTop = 0;
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
             'height':'${barHeight}%'}, 'onMouseDown': mouseDown},[])
      ]),
      div({'className':'list-scrollable', 
           'style':{'height':(windowHeight==0 ? '285px' : '${windowHeight}px')},
           'ref':'${windowId}',
           'onWheel':(ev) => onWheel(ev,scrollStep)},[
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
   // print('Content Height: ${contentHeight}');
   // print('Window Height: ${windowHeight}');

    if (contentHeight > 0) {
      barHeight = 100*(windowHeight/contentHeight);
      if (barHeight > 100) barHeight = 100;
    } else {
      barHeight = 100;
    }

  }
  
  componentDidMount(root) {
    recalculateBorders();
    redraw();
  }
  
  componentDidUpdate(prevProps, prevState, rootNode) {
   // print('Component did update');
    if (!redrawInvoked) {
      recalculateBorders();
      redrawInvoked = true;
      redraw();
    } else {
      redrawInvoked = false;
    }
  }
  
  onWheel(ev,step) {
    ev.nativeEvent.preventDefault();
    if (barHeight == 100) return;
    var newCntTop;
    var newBarTop;
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
    barTop = newBarTop;
    contentTop = newCntTop;
    redraw();
    //print('Wheel event, delta: '+ev.deltaY.toString());
  }
  
  mouseDown(ev) {
    ev.nativeEvent.preventDefault();      
    startY = ev.pageY;
    startTop = barTop;
    
    ssMouseMove = htmlWindow.onMouseMove.listen(mouseMove);
    ssMouseUp = htmlWindow.onMouseUp.listen(mouseUp);
    /*
    ss = stream.listen((ev){
      if (ev.type == 'mousemove') {
        mouseMove(ev);
      }
      if (ev.type == 'mouseup') {
        mouseUp(ev);
      }
    });
    */
  }
  
  mouseMove(ev) {
    var diffY = ev.pageY - startY;  
    var newTop = startTop + diffY;
    if (newTop < 0) {
      newTop = 0;
    } else if (newTop + barHeightPx > windowHeight) {
      newTop = windowHeight - barHeightPx;
    }
    barTop = newTop;
    contentTop = -(barTop*contentHeight/windowHeight).round();
    redraw();
  }
  
  mouseUp(ev) {
   // ss.cancel();
    ssMouseMove.cancel();
    ssMouseUp.cancel();
  }
}