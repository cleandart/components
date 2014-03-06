library userinfo_example;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'components.dart';
import 'dart:async';

var userInfoExample = registerComponent(() => new UserInfoExample());

var _items = new Iterable.generate(27, (i) => i).toList();

class UserInfoExample extends Component {

  String teamName = 'FC DOLNÁ PORUBA';
  int districtPlace = 88888;
  int districtPoints = 888;
  String top360;
  int seasonPlace = 88888;
  int seasonPoints = 888;
  int lastRound = 12;
  int accountType = 1; //0 = basic, 1 = premium
  String premiumUntil = '31.02.2048';
  int districtID = 333;

  componentWillMount() {

  }

  render() {
    return
        div({'key': 'widgetSelector',
             'className' :'widget widget-dark widget-full'},
               userInfo(teamName, districtPlace, districtPoints, top360,
                        seasonPlace, seasonPoints, lastRound, accountType,
                        premiumUntil : premiumUntil, districtID : districtID
                       ));
  }
}
