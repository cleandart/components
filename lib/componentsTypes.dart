library componentsTypes;

import 'package:clean_data/clean_data.dart';
import 'package:intl/intl.dart';

//typedefs must be here so you can import it and dont get dart:html import

typedef ScrollbarType(List children, {String containerClass, int scrollStep});

typedef SliderType(int minValue, int maxValue,
  DataReference lowValue, DataReference highValue, {NumberFormat formater});

typedef SelectorType(List items, DataReference selected,
                    DataReference active, DataReference loading,
                    {String key, String selectorText, bool showFirstLast,
                      String className, onChange});
