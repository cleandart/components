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
  get itemHeight => props['itemHeight'];
  get windowHeight => props['windowHeight'];
  get children => props['children'];
  get stream => props['stream'];
  get scrollStep => props['scrollStep'];
  get contentHeight => itemHeight*children.length;
  get barHeightPx => (windowHeight*windowHeight/contentHeight).round();
  
  ScrollbarComponent() {
    
  }
  
  componentWillMount() {
    barTop = 0;
    contentTop = 0;
    if (contentHeight > 0) {
      barHeight = 100*(windowHeight/contentHeight);
      if (barHeight > 100) barHeight = 100;
    } else {
      barHeight = 100;
    }
    print('Number of children '+children.length.toString());
    print('Scroll step: $scrollStep');
  }
  
  render() {
    
    return div({'style':{'position':'relative','width':'360px'}},[
              div({'className':'list-scrollbar'+(barHeight == 100 ? ' hide' : ''),'style':{'height':windowHeight.toString()+'px'}},[
                 div({'className':'dragger', 'style':{'top':barTop.toString()+'px',
               'height':barHeight.toString()+'%'}, 'onMouseDown': mouseDown},[])]),
            div({'className':'list-scrollable',
                'style':{'height':windowHeight.toString()+'px'}, 
                'onWheel':(ev) => onWheel(ev,scrollStep)},[
               div({'className':'list-content', 'style':{'top':contentTop.toString()+'px'}},
                children
               )])]);
        
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
    this.redraw();
    //print('Wheel event, delta: '+ev.deltaY.toString());
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
    var newTop = startTop + diffY;
    if (newTop < 0) {
      newTop = 0;
    } else if (newTop + barHeightPx > windowHeight) {
      newTop = windowHeight - barHeightPx;
    }
    barTop = newTop;
    contentTop = -(barTop*contentHeight/windowHeight).round();
    this.redraw();
  }
  
  mouseUp(ev) {
    ss.cancel();
  }
}