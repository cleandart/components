library slider;

import 'package:react/react.dart';
import 'dart:async';
import 'package:clean_data/clean_data.dart';
import 'dart:math';

typedef SliderType(int minValue, int maxValue, 
  DataReference lowValue, DataReference highValue);

class SliderComponent extends Component {
  
  var left;
  var right;
  get minValue => props['minValue'];
  get maxValue => props['maxValue'];
  get lowValue => props['lowValue'];
  get highValue => props['highValue'];
  var barWidth;
  var startX;
  var diffX;
  var sliderId;
  var leftHandleId;
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
  
  static SliderType register(window) {
    var _registeredComponent = registerComponent(() => new SliderComponent(window));
    return (int minValue, int maxValue, DataReference lowValue, DataReference highValue) {

      return _registeredComponent({
        'minValue':minValue,
        'maxValue':maxValue,
        'lowValue':lowValue,
        'highValue':highValue
      });
    };
  }
  
  componentWillMount() {
    var rnd = new Random();
    var ids = rnd.nextInt(100000);
    sliderId = 'Slider$ids';
    leftHandleId = 'LeftHandle$ids';    
  }
  
  render() {
    
    return div({'className' : 'form-range'},
              [div({'className':'rail','ref':'${sliderId}'}, [
                  div({'className':'rail-selected', 
                        'style':{'left': left.toString()+'px', 
                                  'right': right.toString()+'px'}},
                      [
                      button({'className':'left-handle',
                        'ref': '${leftHandleId}',
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
    var leftHandleElement = ref('$leftHandleId');
    print('slider width: ${sliderElement.clientWidth}');
    print('handle width: ${leftHandleElement}');
    sliderWidth = sliderElement.clientWidth;
    barWidth = leftHandleElement.clientWidth;
    if (lowValue.value < minValue) {
      lowValue.changeValue(minValue);
    }
    if (highValue.value > maxValue) {
      highValue.changeValue(maxValue);
    }
    lowValueDisplayed = lowValue.value;
    highValueDisplayed = highValue.value;
    left = ((lowValueDisplayed - minValue)*(sliderWidth-barWidth)/(maxValue-minValue)).round();
    right = ((maxValue - highValueDisplayed)*(sliderWidth-barWidth)/(maxValue-minValue)).round();
    redraw();
  }
  
  mouseDown(ev,isLeft) {
    if (ev is SyntheticMouseEvent) {
      startX = ev.pageX;
    } else {
      startX = ev.page.x;
    }
    down = true;
    movedIsLeft = isLeft;
    var value; 
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
      if (ev is SyntheticMouseEvent) {
        diffX = ev.pageX - startX;        
      } else {
        diffX = ev.page.x - startX;
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