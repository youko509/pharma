import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharma1/manage.dart';
import 'package:pharma1/models/stock.dart';
import 'package:pharma1/reportpage.dart';
import 'models/article.dart';
import 'models/sale.dart';

class SalePage extends StatefulWidget {
  @override
  _SalePageState createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final saleBox = Hive.box<Sale>('sales');
  final articleBox = Hive.box<Article>('articles');
  List<Article> _articles = [];
  List<Sale> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadSales();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _articles = articleBox.values.toList();
    });
  }

  Future<void> _loadSales() async {
    setState(() {
      _sales = saleBox.values.toList();
    });
  }

  void _searchArticle(String query) {
    setState(() {
      if (query.isEmpty) {
        _articles = articleBox.values.toList();
      } else {
        _articles = articleBox.values
            .where((article) =>
                article.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _saveSale(Article article, int quantity) {
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a valid quantity.'),
        ),
      );
      return;
    }

    final selectedStock = article.stock.firstWhere(
      (stock) => stock.quantity >= quantity,
      orElse: () => null,
    );

    if (selectedStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The quantity is more than the stock.'),
        ),
      );
      return;
    }

    final sale = Sale(
      stock: HiveList<Stock>(Hive.box<Stock>('stocks')),
      price: article.price,
      quantity: quantity,
      createdAt: DateTime.now(),
    );
    saleBox.add(sale);

    selectedStock.quantity -= quantity;
    selectedStock.save();

    sale.stock.add(selectedStock);
    sale.save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sale saved successfully.'),
      ),
    );
  }

  void _navigateToPage(String pageName) {
    switch (pageName) {
      case 'Report':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReportPage(),
          ),
        );
        break;
      case 'Sale':
        break;
      case 'Manage':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ManagerPage(),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Page'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Report'),
              onTap: () {
                _navigateToPage('Report');
              },
            ),
            ListTile(
              title: Text('Sale'),
              onTap: () {
                _navigateToPage('Sale');
              },
            ),
            ListTile(
              title: Text('Manage'),
              onTap: () {
                _navigateToPage('Manage');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchArticle,
              decoration: InputDecoration(
                labelText: 'Search Article',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return ListTile(
                  title: Text(article.name),
                  subtitle: Text('Price: ${article.price}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Enter Quantity'),
                          content: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final int quantity =
                                    int.tryParse(_quantityController.text) ?? 0;
                                _saveSale(article, quantity);
                                _quantityController.text = '';
                                Navigator.of(context).pop();
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Saved Sales',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                final sale = _sales[index];
                final article = articleBox.getAt(sale.articleIndex);
                return ListTile(
                  title: Text(article?.name ?? ''),
                  subtitle: Text('Price: ${sale.price}, Quantity: ${sale.quantity}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
