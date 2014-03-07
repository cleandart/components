library userinfo;

import 'package:react/react.dart';
import 'package:clean_data/clean_data.dart';
import 'package:intl/intl.dart';
//import 'package:fanleague/round/round.dart';
import 'dart:async';



typedef UserInfoType(DataReference selectedRoundRef, {String key});

class UserInfoComponent extends Component{

  var svkNumberFormat = new NumberFormat.decimalPattern('sk_SK');

  final iBUCKET = Intl.message('Okrsok:', name : 'BUCKET');
  final iTOP_360 = Intl.message('Top 360:', name : 'TOP_360');
  final iTOP_360_NOT_QUALIFIED = Intl.message('Nekvalifikovaný', name : 'TOP_360_NOT_QUALIFIED');
  final iSEASON = Intl.message('Sezóna:', name : 'SEASON');
  final iRANK = Intl.message('. miesto', name : 'RANK');
  final iPOINT_UNIT = Intl.message('b', name : 'POINT_UNIT');
  final iLAST_ROUND = Intl.message('Posledné kolo:', name : 'LAST_ROUND');
  final iACCOUNT = Intl.message('ÚČET', name : 'ACCOUNT');
  final iACCOUNT_BASIC = Intl.message('basic', name : 'ACCOUNT_BASIC');
  final iACCOUNT_PREMIUM = Intl.message('ultimate', name : 'ACCOUNT_PREMIUM');
  final iACCOUNT_PREMIUM_UNTIL = Intl.message('do', name : 'ACCOUNT_PREMIUM_UNTIL');
  final iREGISTER_TEAM = Intl.message('Prihlásiť tím', name : 'REGISTER_TEAM');

  DataSet user;

  DataReference get selectedRound => props['selectedRoundRef'];
  String get selectedRoundId => selectedRound.value==null?null:selectedRound.value['_id']; //ID

  Map userMap;

  StreamSubscription ssSelectedRound;

  static UserInfoType register(DataSet user) {
    var _registeredComponent = registerComponent(() => new UserInfoComponent(user));
    return (DataReference selectedRoundRef, {String key : 'userInfo'}) {

        return _registeredComponent({
          'selectedRoundRef' : selectedRoundRef,
          'key' : key,
        });
      };
  }

  UserInfoComponent(this.user);

  componentWillMount() {
    ssSelectedRound = selectedRound.onChange.listen((_) => redraw());
  }

  componentWillUnmount(){
    ssSelectedRound.cancel();
  }

  Map prepareOutput(){
    var _user = user.first;
    var _fanliga = _user['productInfo']['fanliga'];
    var _round = _fanliga['rounds'][selectedRoundId]; //here we have to get actual round id

    var _teamName = _fanliga['teamName'];
    var _bucketRank = _round['roundStats']['rank'];
    _bucketRank = (_bucketRank != null) ? svkNumberFormat.format(_bucketRank) : 'null';
    var _bucketPoints = _round['roundStats']['points'];
    _bucketPoints = (_bucketPoints != null) ? svkNumberFormat.format(_bucketPoints) : 'null';
    var _top360 = '';
    var _seasonRank = _round['seasonStats']['rank'];
    _seasonRank = (_seasonRank != null) ? svkNumberFormat.format(_round['seasonStats']['rank']) : 'null';
    var _seasonPoints = _round['seasonStats']['points'];
    _seasonPoints = (_seasonPoints != null) ? svkNumberFormat.format(_round['seasonStats']['points']) : 'null';
    var _lastRound = _fanliga['lastRoundPoints'];
    var _accountType = _round['accountType'];
    var _premiumUntil = '31.02.2048';
    var _bucketID = _user['bucket'];

    userMap = {
      'teamName' : _teamName,
      'bucketRank' : _bucketRank,
      'bucketPoints' : _bucketPoints,
      'top360' : '',
      'seasonRank' : _seasonRank,
      'seasonPoints' : _seasonPoints,
      'lastRound' : _lastRound,
      'accountType' : _accountType,
      'premiumUntil' : _premiumUntil,
      'bucketID' : _bucketID
    };

    return userMap;
  }

  _render(Map data){
    var divBucketID = div({'className' : 'widget-column col-1-2'},[
                        div({'className' : 'text-subtitle'}, iBUCKET),
                        span({'className' : 'team-zone-hexa'}, data['bucketID'])
                      ]);

    var divRow1 = div({'className' : 'widget-row'},
                    div({'className' : 'widget-column col-1-1'},
                      span({'className' : 'text-xl text-upcase text-bold'}, data['teamName'])
                    )
                  );

    var divRow2 = div({'className' : 'widget-row'},
                    div({'className' : 'widget-column col-1-1'},
                      div({'className' : 'widget-table'}, [
                        div({'className' : 'table-row'}, [
                          span({}, iBUCKET),
                          span({}, '${data['bucketRank']}'
                                   '$iRANK (${data['bucketPoints']}$iPOINT_UNIT)'),
                          i({'className' : 'icon-down'}) // or icon-up
                        ]),
                        div({'className' : 'table-row  table-dark-row'}, [
                          span({}, iTOP_360),
                          span({}, iTOP_360_NOT_QUALIFIED), // for now it is hardscripted
                        ]),
                        div({'className' : 'table-row'}, [
                          span({}, iSEASON),
                          span({}, '${data['seasonRank']}'
                                   '$iRANK (${data['seasonPoints']}$iPOINT_UNIT)'),
                          i({'className' : 'icon-up'}) // or icon-down
                        ]),
                        div({'className' : 'table-row'}, [
                          span({}, iLAST_ROUND),
                          span({}, '${data['lastRound']}$iPOINT_UNIT')
                        ])
                      ])
                    )
                  );

    var spanPremium = span({'className' : 'account-type account-type-ultimate'});
    var spanPremiumUntil = span({'className' : 'text-darker text-s text-block'},
                                 '$iACCOUNT_PREMIUM_UNTIL ${data['premiumUntil']}');

    var premiumPart = ['$iACCOUNT_PREMIUM ', spanPremium, spanPremiumUntil];
    var basicPart = '$iACCOUNT_BASIC';
    var accountTypePart = (data['accountType'] == 'premium') ? premiumPart : basicPart;

    var divRow3 = div({'className' : 'widget-row'}, [
                    div({'className' : 'widget-column col-1-2'}, [
                      span({'className' : 'text-subtitle'}, iACCOUNT),
                      span({'className' : 'account-type-text'}, accountTypePart)
                    ]),
                    divBucketID
                  ]);

    var componentDiv = div({'className' : "widget-content"}, [divRow1, divRow2, divRow3]);

    var testingPackaging = div({'className' : 'widget widget-team-info'}, componentDiv);
    return div({'className' : 'column'}, testingPackaging);
  }

  render() {
    return _render(prepareOutput());
  }
}
