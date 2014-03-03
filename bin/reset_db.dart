import 'package:clean_sync/server.dart';
import 'package:clean_backend/clean_backend.dart';
import 'dart:async';
import 'package:clean_ajax/server.dart';
import 'package:crypto/crypto.dart';
import 'package:clean_router/common.dart';
import 'package:logging/logging.dart';

MongoDatabase mongodb;

main(){
  mongodb = new MongoDatabase('mongodb://127.0.0.1:27017/clean');
  Future.wait(mongodb.init).then((_){
    mongodb.dropCollection('item');
    mongodb.dropCollection('__clean_item_history');
    mongodb.dropCollection('order');
    mongodb.dropCollection('__clean_order_history');
    return new Future.delayed(new Duration(seconds: 1), (){
      mongodb.close();
    });
  });
}