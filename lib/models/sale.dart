import 'package:hive/hive.dart';



@HiveType(typeId: 5)
class Sale extends HiveObject {
  @HiveField(0)
  int stockKey;
  
  @HiveField(1)
  double price;
  
  @HiveField(2)
  int quantity;

  @HiveField(3) 
  DateTime createdAt;

  @HiveField(4) 
  int articleKey;

  @HiveField(5)
  bool isSale;

  Sale({required this.stockKey, required this.price, required this.quantity, required this.createdAt, required this.articleKey,required this.isSale});
}

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 5;

  @override
  Sale read(BinaryReader reader) {
     var numberOfFields = reader.readByte();
    var fields = <int, dynamic>{};

    for (var i = 0; i < numberOfFields; i++) {
      var fieldIndex = reader.readByte();
      var fieldValue = reader.read();

      fields[fieldIndex] = fieldValue;
    }
    return Sale(
      stockKey: fields[0] as int,
      price: fields[1] as double,
      quantity: fields[2] as int,
      createdAt: fields[3] as DateTime,
      articleKey:fields[4] as int,
      isSale: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer.writeByte(6); // Number of fields in the Sale class

    writer.writeByte(0); // Field index of stock
    writer.write(obj.stockKey);

    writer.writeByte(1); // Field index of price
    writer.write(obj.price);

    writer.writeByte(2); // Field index of quantity
    writer.write(obj.quantity);

    writer.writeByte(3); // Field index of createdAt
    writer.write(obj.createdAt);

    writer.writeByte(4); // Field index of articleKey
    writer.write(obj.articleKey);

     writer.writeByte(5); // Field index of isSale
    writer.write(obj.isSale);
  }
}
