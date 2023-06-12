import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/article.dart';
import 'models/stock.dart';


class ManagerPage extends StatefulWidget {
  @override
  _ManagerPageState createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
 final TextEditingController _articleNameController = TextEditingController();
  final TextEditingController _articlePriceController = TextEditingController();
  final TextEditingController _articleBigSalePriceController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _stockPriceController = TextEditingController();
  final TextEditingController _stockSupplierController = TextEditingController();
  String? _selectedType;
  Box l = Hive.box<Article>('articles7');
  Box<Stock> stockBox = Hive.box<Stock>('stocks7');
  List<Article> _articles7 = [];
  List<Stock> _stocks = [];
  Article? _selectedArticle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final articleBox =  Hive.box<Article>('articles7');
    final  stockBox =  Hive.box<Stock>('stocks7');

    setState(() {
      _articles7 = articleBox.values.toList();
      _articles7.forEach((element) {print(element.stock.length);});
      _stocks = stockBox.values.toList();
    });
  }

  @override
  void dispose() {
    _stockQuantityController.dispose();
    _stockPriceController.dispose();
    _stockSupplierController.dispose();
    super.dispose();
  }

  void _addStock() {
    final int quantity = int.tryParse(_stockQuantityController.text) ?? 0;
    final double price = double.tryParse(_stockPriceController.text) ?? 0.0;
    final String supplier = _stockSupplierController.text;
  
    if (quantity > 0 && price > 0 && supplier.isNotEmpty && _selectedArticle != null) {
      final Stock stock = Stock(
        quantity: quantity,
        price: price,
        balance: quantity,
        supplier: supplier,
        description: '',
        quantityPerBox: 1,
        buyDate: DateTime.now(),
      );
     
      stockBox.add(stock);
      List<Stock> selectedStockList=[];
      selectedStockList.add(stock);
      _selectedArticle?.stock.addAll(selectedStockList);
      _selectedArticle?.save();
      l.putAt(_selectedArticle?.key,_selectedArticle);
     
      
     
      setState(() {
        _stocks.add(stock);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock added successfully.'),
        ),
      );
    }
  }

  void _openAddArticleModal() {

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Article'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _articleNameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: [
                  DropdownMenuItem(
                    value: 'Pharmaceutical',
                    child: Text('Pharmaceutical'),
                  ),
                  DropdownMenuItem(
                    value: 'Medical Supply',
                    child: Text('Medical Supply'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    
                    print(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Type',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _articlePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _articleBigSalePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Big Sale Price',
                ),
              ),
            ],
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
              _addArticle();
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}
void _openAddStockModal() {
  String? _articleName;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Stock'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _articleName,
                items: l.values.map((article) {
                 
                  return DropdownMenuItem<String>(
                    value: '${article.key!}',
                    child: Text(article.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    
                    _selectedArticle = l.getAt(int.parse(value ?? ""));
                    
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Article',
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(height: 10.0),
              TextFormField(
                validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field is required.';
                            }
                            return null;
                          },
                controller: _stockQuantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _stockPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _stockSupplierController,
                decoration: InputDecoration(
                  labelText: 'Supplier',
                ),
              )
            ],
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
              
              _addStock();
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

  void _addArticle() {
    final String name = _articleNameController.text;
    final String? type = _selectedType;
    final double price = double.tryParse(_articlePriceController.text) ?? 0.0;

    print(type);
     print(name);
    print("run the function");
    if (name.isNotEmpty && type!.isNotEmpty && price > 0 ) {
      print("get there");
      final Article article = Article(
        name: name,
        type: type,
        price: price,
        stock: HiveList(Hive.box<Stock>('stocks7')),
      );
      print(article);
      final  articleBox = Hive.box<Article>('articles7');
      articleBox.add(article);

      setState(() {
        _articles7.add(article);
        
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article added successfully.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Page'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                    'Articles',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ), ElevatedButton(
                    onPressed: _openAddArticleModal,
                    child: Text('Add Article'),
                  ),
                  ],),
                  
                  SizedBox(height: 10.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _articles7.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Article article = _articles7[index];
                      final List stock = _articles7[index].stock.toList();
                      return Column(
                        
                        children: [
                           ListTile(
                              title: Text(article.name),
                              subtitle: Text('Price: \$${article.price}'),
                            ),
                            Divider(),
                          ListView.builder(
                          shrinkWrap: true,
                          itemCount: stock.length,
                          itemBuilder: (BuildContext context, int i) {
                            return ListTile(
                              title: Text('${stock[i].quantity}'),
                              subtitle: Text('Price: \$${article.name}'),
                            );
                          },
                        ),
                        Divider(),
                        ],
                        );
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                    'Stocks',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  )
                  , ElevatedButton(
                    onPressed: _openAddStockModal,
                    child: Text('Add Stock'),
                  ),
                  ],),
                  
                  SizedBox(height: 10.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _stocks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Stock stock = _stocks[index];
                      return ListTile(
                        title: Text('Quantity: ${stock.quantity.toString()}'),

                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
