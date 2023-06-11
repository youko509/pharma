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
  DateTime createdAt = DateTime.now();

  User({required this.username,required this.email,required this.password, required this.isAdmin, required this.isActive});
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
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.username);
    writer.write(obj.email);
    writer.write(obj.password);
    writer.write(obj.isAdmin);
    writer.write(obj.isActive);
  }
}