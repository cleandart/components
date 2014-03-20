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
  var movedIsLeft;

  var console;

  StreamSubscription ssMouseUp;
  StreamSubscription ssMouseMove;
  StreamSubscription ssTouchEnd;
  StreamSubscription ssTouchMove;

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
                        'onMouseDown': (ev)=>mouseDown(ev,true),
                        'onTouchStart': (ev)=>touchStart(ev,true)
                        }),
                      button({'className':'right-handle',
                        'style' : {'border-style':'none'},
                        'onMouseDown': (ev)=>mouseDown(ev,false),
                        'onTouchStart': (ev)=>touchStart(ev,false)
                        })
                  ])
               ]),
               div({'className':'form-range-legend'},[
                  span({'className':'form-range-min-value'},'${lowValueDisplayed}'),
                  span({'className':'form-range-max-value'},'${highValueDisplayed}')
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
    if (maxValue - minValue == 0) {
      left = 0;
      right = 0;
    } else {
      left = ((lowValueDisplayed - minValue)*(sliderWidth-barWidth)/(maxValue-minValue)).round();
      right = ((maxValue - highValueDisplayed)*(sliderWidth-barWidth)/(maxValue-minValue)).round();
    }
    redraw();
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

  mouseDown(ev,isLeft) {
    preventDefaultBehaviour(ev);
    movedIsLeft = isLeft;
    downEventOn(getPointFromMouse(ev));
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
    upEvent();
  }

  touchStart(ev, isLeft) {
    preventDefaultBehaviour(ev);
    movedIsLeft = isLeft;
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
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
    upEvent();
  }

  downEventOn(pos) {
    startX = pos.x;
    var value;
    if (movedIsLeft) {
      startPos = left;
      if (sliderWidth - barWidth == 0) {
          value = minValue;
      } else {
        value = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      }
    } else {
      startPos = right;
      if (sliderWidth - barWidth == 0) {
        value = maxValue;
      } else {
        value = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
      }
    }
  }

  moveEventOn(pos) {
    diffX = pos.x - startX;
    if (movedIsLeft) {
       var middle = startPos + diffX;
       if (middle < 0) {
         middle = 0;
       }
       if (middle + right > sliderWidth - barWidth) {
         middle = sliderWidth-barWidth-right;
       }
       left = middle;
       if (sliderWidth - barWidth == 0) {
         lowValueDisplayed = minValue;
       } else {
         lowValueDisplayed = (minValue + left*(maxValue-minValue)/(sliderWidth-barWidth)).round();
       }

     } else {

       var middle = startPos - diffX;
       if (middle < 0) {
         middle = 0;
       }
       if (middle + left > sliderWidth - barWidth) {
         middle = sliderWidth - barWidth - left;
       }
       right = middle;
       if (sliderWidth - barWidth == 0) {
         highValueDisplayed = maxValue;
       } else {
         highValueDisplayed = (maxValue - right*(maxValue-minValue)/(sliderWidth-barWidth)).round();
       }
     }

     this.redraw();
  }

  upEvent() {
    if (movedIsLeft) {
      (lowValue as DataReference).changeValue(lowValueDisplayed);
    } else {
      (highValue as DataReference).changeValue(highValueDisplayed);
    }
  }

}