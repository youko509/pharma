import 'package:hive/hive.dart';
import 'package:pharma1/models/stock.dart';

@HiveType(typeId: 3)
enum ArticleType {
  @HiveField(0, defaultValue: 'pharmaceutical' )
  pharmaceutical,

  @HiveField(1, defaultValue: 'cosmetic')
  cosmetic,

  @HiveField(2,defaultValue: 'medicalSupply')
  medicalSupply,
}

@HiveType(typeId: 2)
class Article extends HiveObject {
  
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  double price;


  @HiveField(3)
  HiveList stock;

  @HiveField(4)
  DateTime createdAt= DateTime.now();

  Article({ required this.name, required this.type,required this.price, required this.stock});

  Map<String, dynamic> toMap() {
  return { 
  'name': name,
  'type': type,
  'price': price,
  'stock':stock,
  };
  }
factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      name:json['name'],
      type: json['userId'],
      price: json['price'],
      stock:HiveList(json['stock']),
    );
}
}

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 2;

  @override
  Article read(BinaryReader reader) {
    var numberOfFields = reader.readByte();
    var fields = <int, dynamic>{};

    for (var i = 0; i < numberOfFields; i++) {
      var fieldIndex = reader.readByte();
      var fieldValue = reader.read();

      fields[fieldIndex] = fieldValue;
    }

    return Article(
      name: fields[0] as String,
      type: fields[1] as String,
      price: fields[2] as double,
      stock: fields[3] as HiveList,
    );
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer.writeByte(4); // Number of fields in the Article class

    writer.writeByte(0); // Field index of name
    writer.write(obj.name);

    writer.writeByte(1); // Field index of type
    writer.write(obj.type);

    writer.writeByte(2); // Field index of price
    writer.write(obj.price);

    writer.writeByte(3); // Field index of stock
    writer.write(obj.stock);
  }
}
