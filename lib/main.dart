import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


import 'package:pharma/models/article.dart';
import 'package:pharma/models/sale.dart';
import 'package:pharma/models/stock.dart';
import 'package:pharma/register.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter<User>(UserAdapter());
  Hive.registerAdapter<Sale>(SaleAdapter());
  Hive.registerAdapter<Stock>(StockAdapter());
  Hive.registerAdapter<Article>(ArticleAdapter());
  await Hive.openBox<User>('users');
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<Stock>('stocks');
  await Hive.openBox<Article>('articles');
  
  runApp(
    MaterialApp(
      title: 'Pharma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:   const  RegisterPage(),
      debugShowCheckedModeBanner: false,
    )
  );
}

