import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String username='';
  @HiveField(1)
  String email='';
  @HiveField(2)
  String password='';
  @HiveField(3,defaultValue: false)
  bool isAdmin=false;
  @HiveField(4,defaultValue: true)
  bool isActive=true;
}