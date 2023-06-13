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
  final saleBox = Hive.box<Sale>('sales6');
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
    int val =0;
    
   
    List <Sale> sales2=saleBox.values.toList();
    for (var i = 0; i < sales2.length; i++) {
      val =val+ sales2[i].quantity;
    }
  }

  Future<void> _loadArticles() async {
    final articleBox = Hive.box<Article>('articles7');
    setState(() {
      _articles = articleBox.values.toList();
      print(_articles);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _searchArticle(String query) {
    setState(() {
      if (query.isEmpty) {
        _loadArticles();
      } else {
        _articles = _articles
            .where((article) =>
                article.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _saveSale(Article article, int quantity) {
    
    
    final Sale sale = Sale(stock: HiveList(Hive.box<Stock>('stocks7')), price: article.price, quantity: quantity);

    
    List selectedStockList=[];
    List<Stock> stocks =[];
    selectedStockList=article.stock.toList();
  
    Stock stock = selectedStockList[0];
   
    saleBox.add(sale); 
    stock.quantity=stock.quantity-sale.quantity;
    
    stocks.add(stock);
    sale.stock.addAll(stocks);
    print(sale.stock);
    sale.save();
    saleBox.putAt(sale.key,sale);
    
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sale saved successfully.'),
      ),
    );
  }

  void _navigateToPage(String pageName) {
    // Perform navigation based on the selected page
    switch (pageName) {
      case 'Report':
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>  const  ReportPage() ,
          ),
        );
        break;
      case 'Sale':
        // Navigate to the sale page
        break;
      case 'Manage':
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>  ManagerPage(),
            
          ),
        );
        break;
      default:
        break;
    }
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
        ],
      ),
    );
  }
}
