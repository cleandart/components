library slider;

import 'package:react/react.dart';
import 'dart:async';
import 'package:clean_data/clean_data.dart';
import 'dart:math';
import 'dart:mirrors';

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
    print('Preventing default behaviour');
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

  mouseDown(ev,isLeft) {
    preventDefaultBehaviour(ev);
    var pos = null;
    if (ev is SyntheticMouseEvent) {
      pos = ev.pageX;
    } else {
      try {
        pos = ev.page.x;
      } catch (e) {
        print('Cannot get position, error: $e');
      }
    }
    movedIsLeft = isLeft;
    downEventOn(pos);
    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
    ssMouseMove = htmlWindow.onMouseMove.listen(mouseMove);
    ssMouseUp = htmlWindow.onMouseUp.listen(mouseUp);

  }

  mouseMove(ev) {
    var pos = null;
    if (down) {
      if (ev is SyntheticMouseEvent) {
        print('Synthetic move');
        pos = ev.pageX;
      } else {
        print('normal move');
        try {
          pos = ev.page.x;
        } catch (e) {
          print('Cannot get mouse position, error: $e');
        }
      }
    }
    moveEventOn(pos);
  }

  mouseUp(ev) {
    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
    upEvent();
  }

  touchStart(ev, isLeft) {
    print('TOUCH START !');
    var pos = null;
    preventDefaultBehaviour(ev);
    try {
      pos = ev.nativeEvent.touches[0].page.x;
    } catch (e) {
      try {
        pos = ev.touches[0].page.x;
      } catch (e) {
        print('Cannot get touch position, error: $e');
      }
    }
    movedIsLeft = isLeft;
    downEventOn(pos);
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
    ssTouchMove = htmlWindow.onTouchMove.listen(touchMove);
    ssTouchEnd = htmlWindow.onTouchEnd.listen(touchEnd);
  }

  touchMove(ev) {
    if (down) {
      print('TOUCH MOVE !');
      var pos = null;
      try {
        pos = ev.nativeEvent.touches[0].page.x;
      } catch (e) {
        try {
          pos = ev.touches[0].page.x;
        } catch (e) {
          print('Could not get touch position, error: $e');
        }
      }
      moveEventOn(pos);
    }
  }

  touchEnd(ev) {
    print('TOUCH END !');
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
    upEvent();
  }

  downEventOn(pos) {
    down = true;
    startX = pos;
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
    diffX = pos - startX;
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
    down = false;

    if (movedIsLeft) {
      (lowValue as DataReference).changeValue(lowValueDisplayed);
    } else {
      (highValue as DataReference).changeValue(highValueDisplayed);
    }
  }

}