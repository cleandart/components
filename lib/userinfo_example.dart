library userinfo_example;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'components.dart';
import 'dart:async';

var userInfoExample = registerComponent(() => new UserInfoExample());

var _items = new Iterable.generate(27, (i) => i).toList();

class UserInfoExample extends Component {

  String teamName = 'FC DOLNÁ PORUBA';
  int bucketRank = 88888;
  int bucketPoints = 888;
  String top360;
  int seasonRank = 88888;
  int seasonPoints = 888;
  int lastRound = 12;
  String accountType = 'premium'; //'basic', 'premium'
  String premiumUntil = '31.02.2048';
  int bucketID = 333;

  componentWillMount() {

  }

  render() {
    return
        div({'key': 'widgetSelector',
             'className' :'widget widget-dark widget-full'},
               userInfo(teamName, bucketRank, bucketPoints, top360,
                        seasonRank, seasonPoints, lastRound, accountType,
                        premiumUntil : premiumUntil, bucketID : bucketID
                       ));
  }
}
