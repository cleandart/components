library slider;

import 'package:react/react.dart';
import 'dart:async';


class SliderComponent extends Component {
  
  var left;
  var right;
  get barWidth => props['barWidth'];
  get sliderWidth => props['sliderWidth'];
  get minValue => props['minValue'];
  get maxValue => props['maxValue'];
  get stream => props['stream'];
  var startX;
  var diffX;
  var startPos;
  var lowValue;
  var highValue;
  var down = false;
  var movedIsLeft;
  StreamSubscription ss;
  
  SliderComponent(){    
    
  }
  
  componentWillMount() {
    left = 0;
    right = 0;
    lowValue = minValue;
    highValue = maxValue;
  }
  
  render() {
    
    return div({'className' : 'form-range'},
              [div({'className':'rail'}, [
                  div({'className':'rail-selected', 
                        'style':{'left': left.toString()+'px', 
                                  'right': right.toString()+'px'}},
                      [
                      button({'className':'left-handle', 
                        'style' : {'border-style':'none'},
                        'onMouseDown': (ev)=>mouseDown(ev,true)
                        },lowValue.toString()),
                      button({'className':'right-handle', 
                        'style' : {'border-style':'none'}, 
                        'onMouseDown': (ev)=>mouseDown(ev,false),
                        },highValue.toString())
                  ])
               ]),
               div({'className':'form-range-legend'},[
                  span({'className':'form-range-min-value'},minValue.toString()),
                  span({'className':'form-range-max-value'},maxValue.toString())
               ])
           ]);
  }
 
  
  mouseDown(ev,isLeft) {
    down = true;
    movedIsLeft = isLeft;
    var value;
    startX = ev.pageX;    
    if (movedIsLeft) {
      startPos = left;
      value = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      print('Drag of left handle started at value: $value');
    } else {
      startPos = right;
      value = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      print('Drag of right handle started at value: $value');
    }
    
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
    if (down) {
      diffX = ev.pageX - startX;
      var leftCorner = startPos + diffX - barWidth/2;
      var rightCorner = startPos + diffX + barWidth/2;
      
      if (movedIsLeft) {

        var middle = startPos + diffX;
        if (middle < 0) {
          middle = 0;
        }
        if (middle + right > sliderWidth - barWidth) {
          middle = sliderWidth-barWidth-right;
        }
        left = middle;
        lowValue = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
        
      } else {

        var middle = startPos - diffX;
        if (middle < 0) {
          middle = 0;
        }
        if (middle + left > sliderWidth - barWidth) {
          middle = sliderWidth - barWidth - left;
        }
        right = middle;
        highValue = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
        
      }
      
      this.redraw();
    }
  }
  
  mouseUp(ev) {
    down = false;
    ss.cancel();
    var value;
    if (movedIsLeft) {
      value = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      print('Drag of left handle stopped at value: $value');
    } else {
      value = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      print('Drag of right handle stopped at value: $value');
    }
  }
  
}