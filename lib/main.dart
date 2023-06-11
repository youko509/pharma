import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pharma1/login.dart';
import 'package:pharma1/manage.dart';
import 'package:pharma1/models/article.dart';
import 'package:pharma1/models/sale.dart';
import 'package:pharma1/models/stock.dart';
import 'models/user.dart';
import 'salepage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter<User>(UserAdapter());
  Hive.registerAdapter<Sale>(SaleAdapter());
  Hive.registerAdapter<Stock>(StockAdapter());
  Hive.registerAdapter<Article>(ArticleAdapter());
  await Hive.openBox<User>('users4');
  await Hive.openBox<Sale>('sales4');
  await Hive.openBox<Stock>('stocks6');
  await Hive.openBox<Article>('articles6');
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:   SalePage(),
      debugShowCheckedModeBanner: false,
    )
  );
}

