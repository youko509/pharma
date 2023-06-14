import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharma1/manage.dart';
import 'package:pharma1/models/stock.dart';
import 'package:pharma1/reportpage.dart';
import '../models/article.dart';
import '../models/sale.dart';

Future<List<Sale>> fetchSales() async {
    final saleBox = Hive.box<Sale>('sales');
    List<Sale> sales = saleBox.values.toList();
      return sales;
  }

 Future<List<Article>> loadArticles() async {
    final articleBox = Hive.box<Article>('articles');
    List<Article> articles = [];
      articles = articleBox.values.toList();
  return articles;
  }

  Future<void> removeItemFromCart(int index) async {
     final saleBox = Hive.box<Sale>('sales');
   saleBox.delete(index);
   loadArticles();
  }