library componentsTypes;

import 'package:clean_data/clean_data.dart';
import 'package:intl/intl.dart';

//typedefs must be here so you can import it and dont get dart:html import

typedef ScrollbarType(List children, {String containerClass, int scrollStep});

typedef SliderType(int minValue, int maxValue,
  DataReference lowValue, DataReference highValue, {NumberFormat formater});

// This selector is not used and can be deleted in future

//typedef SelectorType(List items, DataReference selected,
//                    DataReference active, DataReference loading,
//                    {String key, String selectorText, bool showFirstLast,
//                      String className, onChange});

typedef SelectorType(List items, Function onChange, {String selectorClass, String selectorText, bool showFirstLast, String key});

const VALUE = "value";
const TEXT = "text";
const CLASSNAME = "className";
const SELECTED = "selected";

createSelectorItem(dynamic value,  text, String className, bool selected) =>
    {
      "value": value,
      "text": text,
      "className": className,
      "selected": selected
    };