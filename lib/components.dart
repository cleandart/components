library components;

import 'dart:html';
import 'package:components/slider.dart';
import 'package:components/scrollbar.dart';
import 'package:components/selector.dart';
import 'package:components/componentsTypes.dart';

SliderType doubleSlider = SliderComponent.register(window);
ScrollbarType scrollableWindow = ScrollbarComponent.register(window);
SelectorType selector = SelectorComponent.register(window);
