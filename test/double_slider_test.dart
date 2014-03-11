// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:unittest/unittest.dart';
import 'package:react/react_test.dart';
import 'package:components/slider.dart';
import 'package:unittest/mock.dart';
import 'package:clean_data/clean_data.dart';
import 'package:react/react.dart';
import 'dart:async';

class EventMock extends Mock implements SyntheticMouseEvent {
  int x;
  int pageX;

  get page => new Mock()..when(callsTo('x')).alwaysReturn(this.x);

}

void main() {

  group('Double Slider', () {
    SliderComponent slider;
    var window;
    DataReference lowValue, highValue;
    int minValue;
    int maxValue;
    setUp( () {
      window = new Mock()
        ..when(callsTo('get onMouseMove')).alwaysReturn(new StreamController.broadcast().stream)
        ..when(callsTo('get onMouseUp')).alwaysReturn(new StreamController.broadcast().stream);
      slider = new SliderComponent(window);
      slider.sliderWidth = 501;
      slider.barWidth = 30;
      slider.left = 0;
      slider.right = 0;
      minValue = 500;
      maxValue = 1000;
      lowValue = new DataReference(minValue);
      highValue = new DataReference(maxValue);
      initializeComponent(slider, {'minValue':minValue, 'maxValue':maxValue,
          'lowValue': lowValue, 'highValue': highValue}, []);
    });

    test('Shall not slide below minimum', () {

      slider.left = (slider.sliderWidth-slider.barWidth)/2;
      lowValue.value = (maxValue+minValue)/2;

      EventMock ev = new EventMock();
      ev.pageX = 500;

      slider.mouseDown(ev, true);
      ev.pageX = 100;
      slider.mouseMove(ev);
      slider.mouseUp(ev);

      expect(lowValue.value, equals(minValue));
    });

    test('Shall not slide above maximum', () {

      slider.right = (slider.sliderWidth-slider.barWidth)/2;
      highValue.value = (maxValue+minValue)/2;

      EventMock ev = new EventMock();
      ev.pageX = 100;
      slider.mouseDown(ev, false);
      ev.pageX = 400;
      slider.mouseMove(ev);
      slider.mouseUp(ev);

      expect(highValue.value, equals(maxValue));
    });

    test('Shall not slide left handle above right handle', () {

      slider.right = (slider.sliderWidth-slider.barWidth)/2;
      highValue.value = (maxValue+minValue)/2;

      EventMock ev = new EventMock();
      ev.pageX = 50;
      slider.mouseDown(ev, true);
      ev.pageX = 450;
      slider.mouseMove(ev);
      slider.mouseUp(ev);

      expect(lowValue.value, equals(highValue.value));
      expect(slider.left, equals(slider.sliderWidth-slider.right-slider.barWidth));
    });

    test('Shall not slide right handle below left handle', () {

      slider.left = (slider.sliderWidth-slider.barWidth)/2;
      lowValue.value = (maxValue+minValue)/2;

      EventMock ev = new EventMock();
      ev.pageX = 800;
      slider.mouseDown(ev, false);
      ev.pageX = 300;
      slider.mouseMove(ev);
      slider.mouseUp(ev);

      expect(highValue.value, equals(lowValue.value));
      expect(slider.right, equals(slider.sliderWidth-slider.left-slider.barWidth));
    });

    test('Slides to the position if it\'s possible (moved by 1/3 of width)', () {

      EventMock ev = new EventMock();
      ev.pageX = 200;
      slider.mouseDown(ev, true);
      ev.pageX = ev.pageX + ((slider.sliderWidth-slider.barWidth)/3).round();
      slider.mouseMove(ev);
      slider.mouseUp(ev);

      expect(lowValue.value, closeTo(minValue+((maxValue-minValue)/3).round(),1));
    });

    test('Slides to the position if it\'s possible (moved by 1/19 of width)', () {

      EventMock ev = new EventMock();
      ev.pageX = 500;
      slider.mouseDown(ev, false);
      ev.pageX = ev.pageX - ((slider.sliderWidth-slider.barWidth)/19).round();
      slider.mouseMove(ev);
      slider.mouseUp(ev);

      expect(highValue.value, closeTo(maxValue-((maxValue-minValue)/19).round(),1));
    });
  });
 }
