library slider;

import 'package:react/react.dart';
import 'dart:async';
import 'dart:html';
import 'package:clean_data/clean_data.dart';
import 'dart:math';


class SliderComponent extends Component {
  
  var left;
  var right;
  get barWidth => props['barWidth'];
  get minValue => props['minValue'];
  get maxValue => props['maxValue'];
  get lowValue => props['lowValue'];
  get highValue => props['highValue'];
  var startX;
  var diffX;
  var sliderId;
  var sliderWidth;
  var htmlWindow;
  var startPos;
  var lowValueDisplayed;
  var highValueDisplayed;
  var down = false;
  var movedIsLeft;
  StreamSubscription ssMouseUp;
  StreamSubscription ssMouseMove;
  
  SliderComponent(_htmlWindow){    
    htmlWindow = _htmlWindow;
  }
  
  componentWillMount() {
    left = 0;
    right = 0;
    lowValueDisplayed = minValue;
    highValueDisplayed = maxValue;
    var rnd = new Random();
    sliderId = 'Slider${rnd.nextInt(100000)}';
  }
  
  render() {
    
    return div({'className' : 'form-range'},
              [div({'className':'rail','ref':'${sliderId}'}, [
                  div({'className':'rail-selected', 
                        'style':{'left': left.toString()+'px', 
                                  'right': right.toString()+'px'}},
                      [
                      button({'className':'left-handle', 
                        'style' : {'border-style':'none'},
                        'onMouseDown': (ev)=>mouseDown(ev,true)
                        },'${lowValueDisplayed}'),
                      button({'className':'right-handle', 
                        'style' : {'border-style':'none'}, 
                        'onMouseDown': (ev)=>mouseDown(ev,false),
                        },'${highValueDisplayed}')
                  ])
               ]),
               div({'className':'form-range-legend'},[
                  span({'className':'form-range-min-value'},minValue.toString()),
                  span({'className':'form-range-max-value'},maxValue.toString())
               ])
           ]);
  }
 
  componentDidMount(root) {
    var sliderElement = ref('$sliderId');
    print('slider width: ${sliderElement.clientWidth}');
    sliderWidth = sliderElement.clientWidth;
  }
  
  mouseDown(ev,isLeft) {
    down = true;
    movedIsLeft = isLeft;
    var value;
    if (ev is MouseEvent) {  
      startX = ev.page.x;
    } else {
      startX = ev.pageX;    
    }
    if (movedIsLeft) {
      startPos = left;
      value = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      print('Drag of left handle started at value: $value');
    } else {
      startPos = right;
      value = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      print('Drag of right handle started at value: $value');
    }
    
    ssMouseMove = htmlWindow.onMouseMove.listen(mouseMove);
    ssMouseUp = htmlWindow.onMouseUp.listen(mouseUp);

  }
  
  mouseMove(ev) {
    if (down) {
      if (ev is MouseEvent) {
        diffX = ev.page.x - startX;
      } else {
        diffX = ev.pageX - startX;
      }
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
        lowValueDisplayed = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
        
      } else {

        var middle = startPos - diffX;
        if (middle < 0) {
          middle = 0;
        }
        if (middle + left > sliderWidth - barWidth) {
          middle = sliderWidth - barWidth - left;
        }
        right = middle;
        highValueDisplayed = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
        
      }
      
      this.redraw();
    }
  }
  
  mouseUp(ev) {
    down = false;
    
    ssMouseMove.cancel();
    ssMouseUp.cancel();
    
    if (movedIsLeft) {
      (lowValue as DataReference).changeValue(lowValueDisplayed);
      print('Drag of left handle stopped at value: $lowValueDisplayed');
    } else {
      (highValue as DataReference).changeValue(highValueDisplayed);
      print('Drag of right handle stopped at value: $highValueDisplayed');
    }
  }
  
}