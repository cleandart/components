library userinfo;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'package:intl/intl.dart';
//import 'dart:async';



typedef UserInfoType(String teamName, int districtPlace, int districtPoints,
    String top360, int seasonPlace, int seasonPoints, int lastRound,
    int accountType,
    {String key, String premiumUntil, String districtID});

class UserInfoComponent extends Component{

  final iDISTRICT = Intl.message('Okrsok:', name : 'DISTRICT');
  final iTOP_360 = Intl.message('Top 360:', name : 'TOP_360');
  final iTOP_360_NOT_QUALIFIED = Intl.message('Nekvalifikovaný', name : 'TOP_360_NOT_QUALIFIED');
  final iSEASON = Intl.message('Sezóna:', name : 'SEASON');
  final iPLACE = Intl.message('. miesto', name : 'PLACE');
  final iPOINT_UNIT = Intl.message('b', name : 'POINT_UNIT');
  final iLAST_ROUND = Intl.message('Posledné kolo:', name : 'LAST_ROUND');
  final iACCOUNT = Intl.message('ÚČET', name : 'ACCOUNT');
  final iACCOUNT_BASIC = Intl.message('basic', name : 'ACCOUNT_BASIC');
  final iACCOUNT_PREMIUM = Intl.message('ultimate', name : 'ACCOUNT_PREMIUM');
  final iACCOUNT_PREMIUM_UNTIL = Intl.message('do', name : 'ACCOUNT_PREMIUM_UNTIL');
  final iREGISTER_TEAM = Intl.message('Prihlásiť tím', name : 'REGISTER_TEAM');

  String get teamName => props['teamName'];
  get districtPlace => props['districtPlace'];
  get districtPoints => props['districtPoints'];
  get top360 => props['top360'];
  get seasonPlace => props['seasonPlace'];
  get seasonPoints => props['seasonPoints'];
  get lastRound => props['lastRound'];
  int get accountType => props['accountType'];
  get premiumUntil => props['premiumUntil'];
  get districtID => props['districtID'];


  static UserInfoType register() {
    var _registeredComponent = registerComponent(() => new UserInfoComponent());
    return (String teamName, int districtPlace, int districtPoints,
        String top360, int seasonPlace, int seasonPoints, int lastRound,
        int accountType, {String key : 'userInfo', String premiumUntil : '',
        String districtID : ''}) {

        return _registeredComponent({
          'key' : key,
          'teamName' : teamName,
          'districtPlace' : districtPlace,
          'districtPoints' : districtPoints,
          'top360' : top360,
          'seasonPlace' : seasonPlace,
          'seasonPoints' : seasonPoints,
          'lastRound' : lastRound,
          'accountType' : accountType,
          'premiumUntil' : premiumUntil,
          'districtID' : districtID
        });
      };
  }

  render() {
    var divDistrictID = div({'className' : 'widget-column col-1-2'},[
                          div({'className' : 'text-subtitle'}, iDISTRICT),
                          span({'className' : 'team-zone-hexa'}, districtID)
                        ]);

    var divRow1 = div({'className' : 'widget-row'},
                    div({'className' : 'widget-column col-1-1'},
                      span({'className' : 'text-xl text-upcase text-bold'}, teamName)
                    )
                  );

    var divRow2 = div({'className' : 'widget-row'},
                    div({'className' : 'widget-column col-1-1'},
                      div({'className' : 'widget-table'}, [
                        div({'className' : 'table-row'}, [
                          span({}, iDISTRICT),
                          span({}, '${createFancyNumbersWithSpaces(districtPlace)}'
                                   '$iPLACE (${createFancyNumbersWithSpaces(districtPoints)}$iPOINT_UNIT)'),
                          i({'className' : 'icon-down'}) // or icon-up
                        ]),
                        div({'className' : 'table-row  table-dark-row'}, [
                          span({}, iTOP_360),
                          span({}, iTOP_360_NOT_QUALIFIED), // for now it is hardscripted
                        ]),
                        div({'className' : 'table-row'}, [
                          span({}, iSEASON),
                          span({}, '${createFancyNumbersWithSpaces(seasonPlace)}'
                                   '$iPLACE (${createFancyNumbersWithSpaces(seasonPoints)}$iPOINT_UNIT)'),
                          i({'className' : 'icon-up'}) // or icon-down
                        ]),
                        div({'className' : 'table-row'}, [
                          span({}, iLAST_ROUND),
                          span({}, '$lastRound$iPOINT_UNIT')
                        ])
                      ])
                    )
                  );

    var spanPremium = span({'className' : 'account-type account-type-ultimate'});
    var spanPremiumUntil = span({'className' : 'text-darker text-s text-block'},
                                 '$iACCOUNT_PREMIUM_UNTIL $premiumUntil');

    var premiumPart = ['$iACCOUNT_PREMIUM ', spanPremium, spanPremiumUntil];
    var basicPart = '$iACCOUNT_BASIC';
    var accountTypePart = (accountType == 1) ? premiumPart : basicPart;

    var divRow3 = div({'className' : 'widget-row'}, [
                    div({'className' : 'widget-column col-1-2'}, [
                      span({'className' : 'text-subtitle'}, iACCOUNT),
                      span({'className' : 'account-type-text'}, accountTypePart)
                    ]),
                    divDistrictID
                  ]);

    var componentDiv = div({'className' : "widget-content"}, [divRow1, divRow2, divRow3]);

    var testingPackaging = div({'className' : 'widget widget-team-info'}, componentDiv);
    return div({'className' : 'column'}, testingPackaging);
  }
}

String createFancyNumbersWithSpaces(int number) {
  if (number < 1000 && number > -1000) {
    return number.toString();
  }

  String _split = number.toString();
  var _result = '';

  for (int i = _split.length-1; i >= 0; i--){
    _result += _split[i];
    if (i.remainder(3) == 0 && i != 0) {
      _result += ' ';
    }
  }
  return _result;
}
