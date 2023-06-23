import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  bool isAdmin = false;

  @HiveField(4)
  bool isActive = true;

  @HiveField(5) 
  DateTime createdAt;

  @HiveField(6)
  int orgId;

  User({required this.username,required this.email,required this.password, required this.isAdmin, required this.isActive, required this.orgId, required this.createdAt});
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 1;

  @override
  User read(BinaryReader reader) {
    var numberOfFields = reader.readByte();
    var fields = <int, dynamic>{};

    for (var i = 0; i < numberOfFields; i++) {
      var fieldIndex = reader.readByte();
      var fieldValue = reader.read();

      fields[fieldIndex] = fieldValue;
    }
    return User(
      username: fields[0] as String,
      email: fields[1] as String,
      password: fields[2] as String,
      isAdmin: fields[3] as bool,
      isActive: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      orgId: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeByte(7);

    writer.writeByte(0);
    writer.write(obj.username);
    writer.writeByte(1);
    writer.write(obj.email);
    writer.writeByte(2);
    writer.write(obj.password);
    writer.writeByte(3);
    writer.write(obj.isAdmin);
    writer.writeByte(4);
    writer.write(obj.isActive);
    writer.writeByte(5);
    writer.write(obj.createdAt);
    writer.writeByte(6);
    writer.write(obj.orgId);
  }
}