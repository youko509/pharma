// import 'package:hive/hive.dart';



// @HiveType(typeId: 12)
// class Pharma extends HiveObject {
//   @HiveField(0)
//   HiveList Name;
  
//   @HiveField(1)
//   double price;
  
//   @HiveField(2)
//   int quantity;

//   @HiveField(3) 
//   DateTime createdAt;

//   Pharma({required this.stock, required this.price, required this.quantity, required this.createdAt});
// }

// class SaleAdapter extends TypeAdapter<Pharma> {
//   @override
//   final int typeId = 8;

//   @override
//   Pharma read(BinaryReader reader) {
//      var numberOfFields = reader.readByte();
//     var fields = <int, dynamic>{};

//     for (var i = 0; i < numberOfFields; i++) {
//       var fieldIndex = reader.readByte();
//       var fieldValue = reader.read();

//       fields[fieldIndex] = fieldValue;
//     }
//     return SaleLine(
//       stock: fields[0] as HiveList,
//       price: fields[1] as double,
//       quantity: fields[2] as int,
//       createdAt: fields[3] as DateTime,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, Pharma obj) {
//     writer.writeByte(4); // Number of fields in the Sale class

//     writer.writeByte(0); // Field index of stock
//     writer.write(obj.stock);

//     writer.writeByte(1); // Field index of price
//     writer.write(obj.price);

//     writer.writeByte(2); // Field index of quantity
//     writer.write(obj.quantity);

//     writer.writeByte(3); // Field index of quantity
//     writer.write(obj.createdAt);
//   }
// }
