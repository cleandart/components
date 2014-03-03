library scrollbar;

import 'package:react/react.dart';
import 'dart:async';

class ScrollbarComponent extends Component {
  
  var barTop;
  var contentTop;
  var barHeight;
  var startY;
  var startTop;
  StreamSubscription ss;
  get items => props['items'];
  get itemHeight => props['itemHeight'];
  get windowHeight => props['windowHeight'];
  get stream => props['stream'];
  get contentHeight => itemHeight*items.length;
  get barHeightPx => (windowHeight*windowHeight/contentHeight).round();
  
  ScrollbarComponent() {
    
  }
  
  componentWillMount() {
    if (contentHeight > 0) {
      barHeight = 100*(windowHeight/contentHeight);
      if (barHeight > 100) barHeight = 100;
    } else {
      barHeight = 100;
    }
  }
  
  render() {
    
    return div({},[
              div({'className':'list-scrollbar'},[
                 div({'className':'dragger', 'style':{'top':barTop.toString()+'px',
               'height':barHeight.toString()+'%'}, 'onMouseDown': mouseDown},[])]),
            div({'className':'list-scrollable'},[
               div({'className':'list-content', 'style':{'top':contentTop.toString()+'px'}},[
                  items
               ])])]);
        
  }
  
  mouseDown(ev) {
    ev.nativeEvent.preventDefault();
    
    startTop = barTop;
    startY = ev.pageY;
    ss = stream.listen((ev){
      if (ev.type == 'mousemove') {
        mouseMove(ev);
      }
      if (ev.type == 'mouseup') {
        mouseUp(ev);
      }
    });
  }
  
  mouseMove(ev) {
    var diffY = ev.pageY - startY;
    var newPos = startTop+diffY;
    if (newPos < 0) {
      newPos = 0;
    } else if (newPos + barHeightPx > windowHeight) {
      newPos = windowHeight - barHeightPx;
    }
    barTop = newPos;
    contentTop = (barTop*contentHeight/windowHeight).round();
    this.redraw();
  }
  
  mouseUp(ev) {
    ss.cancel();
  }
}