import 'package:react/react_client.dart';
import 'dart:html';
import 'package:react/react.dart';
import 'package:components/selector.dart';
import 'package:components/componentsTypes.dart';
import 'package:components/components.dart';
import 'package:clean_data/clean_data.dart';
import 'package:clean_data/clean_data.dart' as cd;
import 'dart:async';
import 'dart:convert';

void main() {
  setClientConfiguration();

  var selectorExample = registerComponent(() => new SelectorExample());

  renderComponent(selectorExample({}), querySelector('body'));

}


class SelectorExample extends Component {
  DataReference selected;
  DataReference active;
  DataReference loading;
  DataMap selectorProps;
  DataReference _propsInputValid;

  DataReference inputProps;
  DataReference inputItem;
  DataReference inputGenerate;
  List items = new Iterable.generate(32).toList();

  componentWillMount() {
    selected = new DataReference(31);
    active = new DataReference(31);
    loading = new DataReference(null);
    selectorProps = new DataMap.from({
        "items" : selectorItems(items),
        "selectorText": "CHOOSE",
        "selectorClass": "round-selector full",
        "showFirstLast": false
    });
    _propsInputValid = new DataReference(true);
    inputItem = new DataReference(JSON.encode({"value":0,"text":"0a","className":"","selected":false}));
    inputProps = new DataReference(JSON.encode(selectorProps));
    inputGenerate = new DataReference(0);
    loading.onChange.listen(load);
    selectorProps.onChange.listen((_) => inputProps.value = JSON.encode(selectorProps));
    cd.onChange([selectorProps, _propsInputValid]).listen((_) => redraw());
    cd.onChange([loading, selected, active]).listen((_) => adjustItems());
  }

  selectorItems(items) =>
    items.map((i) => createSelectorItem(i, '${i}a', i == loading.value ? "loading" : i == selected.value ? 'selected' : '', i == selected.value)).toList();

  load(_) {
    if (loading.value == null) return new Future.value(null);
    var selectorLastSelected = loading.value;
    return new Future.delayed(new Duration(seconds: 1), () {
      if (loading.value == selectorLastSelected) {
        loading.value = null;
        selected.value = selectorLastSelected;
      }
    });
  }

  onChange(item) {
    loading.value = item;
  }

  selectProperItems(List items) {
    getItemClass(item) {
      bool sel = item["value"] == selected.value;
      bool act = item["value"] == active.value;
      bool ld = item["value"] == loading.value;
      return ld ? "loading" : sel ? "selected" : act ? "active" : "";
    }
    return items.map((i) => i..addAll({"className" : getItemClass(i), "selected": i["value"] == selected.value})).toList();
  }

  adjustItems() {
    selectorProps["items"] = selectProperItems(selectorProps["items"]);
    print("adjust");
  }

  isDecodable(String str) {
    try {
      JSON.decode(str);
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  saveProps() {
    if (!isDecodable(inputProps.value)) {
      return;
    }
    selectorProps.clear();
    selectorProps.addAll(JSON.decode(inputProps.value));
  }

  addItem(String item) {
    if (!isDecodable(inputProps.value) || !isDecodable(item)) {
      return;
    }
    Map newProps = JSON.decode(inputProps.value);
    newProps["items"].add(JSON.decode(item));
    inputProps.value = JSON.encode(newProps);
  }

  generateItems(num count) {
    if (!isDecodable(inputProps.value)) {
      return;
    }
    Map newProps = JSON.decode(inputProps.value);
    newProps["items"].addAll(selectorItems(new Iterable.generate(count).toList()));
    inputProps.value = JSON.encode(newProps);
  }

  deleteItems() {
    if (!isDecodable(inputProps.value)) {
      return;
    }
    Map newProps = JSON.decode(inputProps.value);
    newProps["items"] = [];
    inputProps.value = JSON.encode(newProps);
  }

  toggleFirstLast() {
    if (!isDecodable(inputProps.value)) {
      return;
    }
    Map newProps = JSON.decode(inputProps.value);
    newProps["showFirstLast"] = !newProps["showFirstLast"];
    inputProps.value = JSON.encode(newProps);
  }

  render() {
    print("REDRAWW");
    return
        div({'style':{"margin":"0 auto", "width":"800px"}},[
          div({"className":"widget-row"},
            div({"className":"widget-column col-1-1"},[
              cInput(value: inputGenerate),
              button({"onClick": (e) => generateItems((inputGenerate.value is int) ? inputGenerate.value : num.parse(inputGenerate.value,(str) => 0))}, "Generate"),
            ])
          ),
          div({"className":"widget-row"},[
            div({"className": "widget-column col-1-1"},[
              cTextArea(value: inputItem)
            ]),
            div({"className": "widget-column col-1-2"},[
              button({"onClick": (e) => addItem(inputItem.value)}, "Add item"),
              button({"onClick": (e) => toggleFirstLast()}, "Show/hide fast arrows"),
            ]),
          ]),
          div({"className": 'widget-row'},[
            div({"className": "widget-column col-1-1"},[
              cTextArea(value: inputProps, onChange: (e) => _propsInputValid.value = isDecodable(e)),
            ]),
          ]),
          div({"className": 'widget-row'},[
            div({"className":"widget-column col-1-1"},[
              button({"onClick": (e) => deleteItems()}, "Delete items"),
              button({"onClick": (e) => saveProps()}, "SAVE"),
              span({},"Props JSON valid: ${_propsInputValid.value}"),
            ]),
          ]),
          div({'className' : 'widget-row'},[
              div({'className' : 'widget-column col-1-1'},
               selectorProps["items"].isEmpty ? "Selector must have at least one item !" :
                 selector(selectorProps["items"], onChange, selectorText: selectorProps["selectorText"],
                   selectorClass: selectorProps['selectorClass'], showFirstLast: selectorProps["showFirstLast"],
                   key: selectorProps["key"]))])
        ]);
  }
}

InputType cInput = Input.register();

typedef InputType({String id, String type, String className, value, String placeholder, bool readOnly, Function onChange, Function onBlur, String name, Function onEnter});

class Input extends Component {
  static InputType register(/*constructor param*/) {
    var _registeredComponent = registerComponent(() => new Input(/*constructor param*/));
    return ({String id:null, String type:'text', String className:'', value:null,
      String placeholder:'', bool readOnly:false, onChange: null, onBlur: null, String name:'', onEnter : null}) {
      //TODO maybe create it
      assert(value is DataReference);

      return _registeredComponent({
        'id': id,
        'type' : type,
        'name': name,
        'className': className,
        'placeholder': placeholder,
        'value': value,
        'readOnly' : readOnly,
        'onChange': onChange,
        'onEnter': onEnter,
        'onBlur': onBlur
      },null);
    };
  }

  onEnter(e) {
    if (props['onEnter'] != null) props['onEnter']();
  }

  onChange(e) {
    var value = e.target.value;
    if (props['type'] == 'checkbox') value = e.target.checked;
    if (props['readOnly']) return;
    props['value'].value = value;
    redraw();
    if (props['onChange'] != null) props['onChange'](value);
  }

  onBlur(e) {
    if (props['onBlur'] != null)  props['onBlur'](e.target.value);
  }

  StreamSubscription updateSubscription;

  componentWillMount() {
    updateSubscription = props['value'].onChange.listen((_) => redraw());
  }

  componentWillUnmount() {
    updateSubscription.cancel();
  }

  componentWillReceiveProps(newProps) {
    if (props['value'] != newProps['value']) {
      updateSubscription.cancel();
      updateSubscription = props['value'].onChange.listen((_) => redraw());
    }
  }

  onKeyDown(SyntheticKeyboardEvent e) {
    if (e.keyCode == 13) onEnter(e);
  }

  render() {
    return input({
      'id': props['id'],
      'type': props['type'],
      'name': props['name'],
      'placeholder': props['placeholder'],
      'className': '${props['className']} ${(props['readOnly'])?'readonly':''}',
      'checked': (props['type'] == 'checkbox')?props['value'].value:null,
      'value': (props['value'].value == null)? '' : props['value'].value ,
      'onChange': onChange,
      'onBlur': onBlur,
      'onKeyDown': onKeyDown
    });
  }
}

TextAreaType cTextArea = TextArea.register();

typedef TextAreaType({String id, String type, String className, value, String placeholder, bool readOnly, Function onChange, Function onBlur, String name});
class TextArea extends Component {
  static TextAreaType register(/*constructor param*/) {
    var _registeredComponent = registerComponent(() => new TextArea(/*constructor param*/));
    return ({String id:null, String type:'text', String className:'', value:null,
      String placeholder:'', bool readOnly:false, onChange: null, onBlur: null, String name:''}) {

      //TODO maybe create it
      assert(value is DataReference);

      return _registeredComponent({
        'id': id,
        'type' : type,
        'name': name,
        'className': className,
        'placeholder': placeholder,
        'value': value,
        'readOnly' : readOnly,
        'onChange': onChange,
        'onBlur': onBlur
      },null);
    };
  }
  onChange(e) {
    var value = e.target.value;
    if (props['readOnly']) return;
    props['value'].value = value;
    redraw();
    if (props['onChange'] != null) props['onChange'](value);
  }

  onBlur(e) {
    if (props['onBlur'] != null)  props['onBlur'](e.target.value);
  }

  StreamSubscription updateSubscription;

  componentWillMount() {
    updateSubscription = props['value'].onChange.listen((_) => redraw());
  }

  componentWillUnmount() {
    updateSubscription.cancel();
  }

  render() {
    return textarea({
      'id': props['id'],
      'type': props['type'],
      'name': props['name'],
      'placeholder': props['placeholder'],
      'className': '${props['className']} ${(props['readOnly'])?'readonly':''}',
      'checked': (props['type'] == 'checkbox')?props['value'].value:null,
      'value': (props['value'].value == null)? '' : props['value'].value ,
      'onChange': onChange,
      'onBlur': onBlur,
    });
  }
}
