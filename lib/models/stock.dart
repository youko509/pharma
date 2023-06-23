import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class Stock extends HiveObject {


  @HiveField(0)
  int quantity;

  @HiveField(1)
  double price;   

  @HiveField(2)  
  int balance;  

  @HiveField(3)  
  String supplier ;  

  @HiveField(4) 
  int quantityPerBox = 1;

  @HiveField(5) 
  String description;

  @HiveField(6) 
  String notes='';

  @HiveField(7) 
  DateTime buyDate = DateTime.now();  

  @HiveField(8) 
  DateTime createdAt;

  @HiveField(9) 
  int articleKey;
  
  @HiveField(10) 
  int orgid;

  Stock({required this.quantity,required this.balance,required this.price,required this.supplier,required this.quantityPerBox,required this.description,required this.buyDate, this.notes='', required this.createdAt, required this.articleKey, required this.orgid});

  bool isEmpty(){
    if (quantity==0){
      return true;
    }
    return false;
  }
}

class StockAdapter extends TypeAdapter<Stock> {
  @override
  final int typeId = 4;

 
  @override
  Stock read(BinaryReader reader) {
    var numberOfFields = reader.readByte();
    var fields = <int, dynamic>{};

    for (var i = 0; i < numberOfFields; i++) {
      var fieldIndex = reader.readByte();
      var fieldValue = reader.read();

      fields[fieldIndex] = fieldValue;
    }

    return Stock(
      quantity: fields[0] as int,
      price: fields[1] as double,
      balance: fields[2] as int,
      supplier: fields[3] as String,
      quantityPerBox: fields[4] as int,
      description: fields[5] as String,
      notes: fields[6] as String,
      buyDate: fields[7] as DateTime,
      createdAt: fields[8] as DateTime,
      articleKey: fields[9] as int,
      orgid: fields[10] as int,
    );
  }
  @override
  void write(BinaryWriter writer, Stock obj) {
    writer.writeByte(11); // Number of fields in the Stock class

    writer.writeByte(0); // Field index of quantity
    writer.write(obj.quantity);

    writer.writeByte(1); // Field index of price
    writer.write(obj.price);

    writer.writeByte(2); // Field index of balance
    writer.write(obj.balance);

    writer.writeByte(3); // Field index of supplier
    writer.write(obj.supplier);

    writer.writeByte(4); // Field index of quantityPerBox
    writer.write(obj.quantityPerBox);

    writer.writeByte(5); // Field index of description
    writer.write(obj.description);

    writer.writeByte(6); // Field index of notes
    writer.write(obj.notes);

    writer.writeByte(7); // Field index of buyDate
    writer.write(obj.buyDate);

    writer.writeByte(8); // Field index of createdAt
    writer.write(obj.createdAt);

    writer.writeByte(9); // Field index of createdAt
    writer.write(obj.articleKey);

    writer.writeByte(10); // Field index of createdAt
    writer.write(obj.orgid);
  }
}