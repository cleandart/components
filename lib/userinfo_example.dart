library userinfo_example;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'components.dart';
import 'dart:async';

var userInfoExample = registerComponent(() => new UserInfoExample());

var _items = new Iterable.generate(27, (i) => i).toList();

class UserInfoExample extends Component {



  componentWillMount() {

  }

  render() {
    return
        div({'key': 'widgetSelector',
             'className' :'widget widget-dark widget-full'},
               userInfo(/*teamName, bucketRank, bucketPoints, top360,
                        seasonRank, seasonPoints, lastRound, accountType,
                        premiumUntil : premiumUntil, bucketID : bucketID*/
                       ));
  }
}
