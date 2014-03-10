library components;

import 'dart:html';
import 'package:components/slider.dart';
import 'package:components/scrollbar.dart';
import 'package:components/selector.dart';

var doubleSlider = SliderComponent.register(window);
var scrollableWindow = ScrollbarComponent.register(window);
var selector = SelectorComponent.register(window);
