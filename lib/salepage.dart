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
  double total = 0;
  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadArticles() async {
   
    setState(() {
      _articles = articleBox.values.toList();
     
    });
  }
  Future<List<Sale>> fetchSales() async {
    final box = Hive.box<Sale>('sales');
    List<Sale> sales=[];
    for(int i=0; i<box.values.toList().length; i++){
       Sale sale = saleBox.values.toList()[i];
     if (!sale.isSale){
          sales.add(sale);
        }
    }
      return sales;
  }
  Future<List<Sale>> confirmSale() async {
    final box = Hive.box<Sale>('sales');
    List<Sale> sales=[];
    for(int i=0; i<box.values.toList().length; i++){
       Sale sale = saleBox.values.toList()[i];
     if (!sale.isSale){
        sale.isSale = true;
        sale.save();
          sales.add(sale);
           _loadSales();
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale Confirm successfully'),
          ),
        );
        }
    }
      return sales;
  }
  Future<void> removeItemFromCart(int index) async {
   saleBox.delete(index);
   _loadSales();
  }
  
   Future<void> _loadSales() async {

    setState(() {
      total=0;
      _sales=[];
      for(int i=0; i<saleBox.values.toList().length; i++){
        Sale sale = saleBox.values.toList()[i];
        if (!sale.isSale){
          _sales.add(sale);
        }
        
      }
      _sales.forEach((element) { total+= element.quantity * element.price;});
      
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
       _articles =<Article>[];
      } else {
        _loadArticles();
        _articles = _articles
            .where((article) =>
                article.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _saveSale(Article article, int quantity) {
    List selectedStockList=[];
   
    List<Stock> stocks =[];
    
    selectedStockList=article.stock.toList();
    List nonEmptyStocks = selectedStockList.where((stock) {
          return !stock.isEmpty();
        }).toList();
    
    
    if ( nonEmptyStocks.isEmpty){
      
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The quantity is more than the stock or'),
      ),
      );
      
    } else if (quantity > 0){
      Stock stock = nonEmptyStocks[0];
    final Sale sale = Sale(stock: HiveList(Hive.box<Stock>('stocks')), price: article.price, quantity: quantity, createdAt: DateTime.now(), articleKey: article.key, isSale: false);
    print("yes");
    saleBox.add(sale);
    stock.quantity-=sale.quantity;
    stocks.add(stock);
    sale.stock.addAll(stocks);
    
    sale.save();
    print("get there ${sale.key}");
    saleBox.put(sale.key,sale);
     _loadSales();
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sale saved successfully.'),
      ),
    );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enter a valid quantity.'),
      ),
    );
    }
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
                Stock stock;
                num q=0;
                 article.stock.forEach((element) {stock = element as Stock; q+=stock.quantity;});
                return ListTile(
                  title: Text(article.name),
                  subtitle: Text('Price: \$${article.price}'),
                  trailing: Text('Stock: ${q}'),
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
                                    Navigator.of(context).pop();
                                _saveSale(article, quantity);
                               _quantityController.text=' ';
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
         SizedBox(height: 2.0),
         if (_sales.isNotEmpty)
          Text(
            'Cart',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
         FutureBuilder<List<Sale>>(
            future: fetchSales(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final _sales = snapshot.data!;
                if (_sales.isEmpty) {
                  // Display a message when no sales exist
                  return Text('');
                }
                return Expanded(
                      child: ListView.builder(
                        itemCount: _sales.length,
                        itemBuilder: (context, index) {
                          final sale = _sales[index];
                          final article = articleBox.getAt(sale.articleKey);
                          return ListTile(
                            title: Text('${article!.name} '),
                            subtitle: Text('Price:\$${sale.price}, Quantity: ${sale.quantity}, Total: \$${sale.price * sale.quantity}'),
                            trailing:  ElevatedButton(
                              onPressed: () {
                                setState(() {();});
                              },
                              child:  
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      removeItemFromCart(sale.key);
                                      });
                                    }),
                            ),
                          );
                        }
                      )
         );} else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            } 
          ),
          if (_sales.isNotEmpty)
          Text('Total :${total}'),
          if (_sales.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              confirmSale();
            },
            child: Text('Confirm sale'),
          ),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }
}
