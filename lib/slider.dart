library slider;

import 'package:react/react.dart';
import 'dart:async';
import 'package:clean_data/clean_data.dart';
import 'dart:math';
import 'dart:html';
import 'package:components/componentsTypes.dart';
import 'package:intl/intl.dart';

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
  var sliderWidth;
  Window htmlWindow;
  var startPos;
  var lowValueDisplayed;
  var highValueDisplayed;
  var movedIsLeft;

  StreamSubscription ssMouseUp;
  StreamSubscription ssMouseMove;
  StreamSubscription ssTouchEnd;
  StreamSubscription ssTouchMove;

  SliderComponent(this.htmlWindow);

  static SliderType register(window) {
    var _registeredComponent = registerComponent(() => new SliderComponent(window));
    return (int minValue, int maxValue, DataReference lowValue, DataReference highValue, {NumberFormat formater}) {
      return _registeredComponent({
        'minValue':minValue,
        'maxValue':maxValue,
        'lowValue':lowValue,
        'highValue':highValue,
        'formater': formater
      });
    };
  }

  render() {

    return div({'className' : 'form-range'},
              [div({'className':'rail','ref':'slider'}, [
                  div({'className':'rail-selected',
                        'style':{'left': left.toString()+'px',
                                  'right': right.toString()+'px'}},
                      [
                      button({'className':'left-handle',
                        'ref': 'leftHandle',
                        'style' : {'border-style':'none'},
                        //'onMouseDown': (ev)=>mouseDown(ev,true),
                        //'onTouchStart': (ev)=>touchStart(ev,true)
                        }),
                      button({'className':'right-handle',
                        'ref': 'rightHandle',
                        'style' : {'border-style':'none'},
                        //'onMouseDown': (ev)=>mouseDown(ev,false),
                        //'onTouchStart': (ev)=>touchStart(ev,false)
                        })
                  ])
               ]),
               div({'className':'form-range-legend'},[
                  span({'className':'form-range-min-value'},'${formatValues(lowValueDisplayed)}'),
                  span({'className':'form-range-max-value'},'${formatValues(highValueDisplayed)}')
               ])
           ]);
  }

  formatValues(val) =>
    val == null?
        val
      :
        (props['formater'] == null? val : props['formater'].format(val));

  List<StreamSubscription> reactionsOnTouchClick;
  componentDidMount(root) {
    var sliderElement = ref('slider') as HtmlElement;
    var leftHandleElement = ref('leftHandle') as HtmlElement;
    var rightleftHandleElement = ref('rightHandle') as HtmlElement;

    reactionsOnTouchClick = [
       leftHandleElement.onMouseDown.listen((ev)=>mouseDown(ev,true)),
       leftHandleElement.onTouchStart.listen((ev)=>touchStart(ev,true)),
       rightleftHandleElement.onMouseDown.listen((ev)=>mouseDown(ev,false)),
       rightleftHandleElement.onTouchStart.listen((ev)=>touchStart(ev,false)),
    ];


    //print('slider width: ${sliderElement.clientWidth}');
    //print('handle width: ${leftHandleElement}');
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

  componentWillUnmount() {
    reactionsOnTouchClick.forEach((ss) => ss.cancel());
  }

  mouseDown(MouseEvent ev,isLeft) {
    // Always a React event -> SyntheticMouseEvent
    ev.preventDefault();
    movedIsLeft = isLeft;
    downEventOn(new Point(ev.page.x, ev.page.y));
    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
    ssMouseMove = htmlWindow.onMouseMove.listen(mouseMove);
    ssMouseUp = htmlWindow.onMouseUp.listen(mouseUp);

  }

  mouseMove(MouseEvent ev) {
    // As we listen on window, this is not React event, but just MouseEvent
    moveEventOn(new Point(ev.page.x, ev.page.y));
  }

  mouseUp(MouseEvent ev) {
    if (ssMouseMove != null) ssMouseMove.cancel();
    if (ssMouseUp != null) ssMouseUp.cancel();
    upEvent();
  }

  touchStart(TouchEvent ev, isLeft) {
    // React event -> SyntheticTouchEvent
    ev.preventDefault();
    movedIsLeft = isLeft;
    downEventOn(new Point(ev.touches[0].page.x, ev.touches[0].page.y));
    if (ssTouchMove != null) ssTouchMove.cancel();
    if (ssTouchEnd != null) ssTouchEnd.cancel();
    ssTouchMove = htmlWindow.onTouchMove.listen(touchMove);
    ssTouchEnd = htmlWindow.onTouchEnd.listen(touchEnd);
  }

  touchMove(TouchEvent ev) {
    // Listening on window -> former dart TouchEvent
    moveEventOn(new Point(ev.touches[0].page.x, ev.touches[0].page.y));
  }

  touchEnd(TouchEvent ev) {
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