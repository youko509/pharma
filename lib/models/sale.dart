import 'package:hive/hive.dart';
import 'package:pharma1/models/stock.dart';


@HiveType(typeId: 5)
class Sale extends HiveObject {
  @HiveField(0)
  HiveList stock;
  
  @HiveField(1)
  double price;
  
  @HiveField(2)
  int quantity;

  @HiveField(3) 
  DateTime createdAt = DateTime.now();

  Sale({required this.stock, required this.price, required this.quantity});
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
      stock: fields[0] as HiveList,
      price: fields[1] as double,
      quantity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer.writeByte(3); // Number of fields in the Sale class

    writer.writeByte(0); // Field index of stock
    writer.write(obj.stock);

    writer.writeByte(1); // Field index of price
    writer.write(obj.price);

    writer.writeByte(2); // Field index of quantity
    writer.write(obj.quantity);
  }
}
