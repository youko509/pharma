import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/article.dart';
import 'models/stock.dart';
import 'models/user.dart';

class ManagerPage extends StatefulWidget {
  ManagerPage({Key? key,required this.user}) : super(key: key);
  final User user;
  @override
  _ManagerPageState createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  final TextEditingController _articleNameController = TextEditingController();
  final TextEditingController _articlePriceController = TextEditingController();
  final TextEditingController _articleBigSalePriceController = TextEditingController();
  final TextEditingController _quantityPerBoxController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _stockPriceController = TextEditingController();
  final TextEditingController _stockSupplierController = TextEditingController();
  String? _selectedType;
  Box<Article> l = Hive.box<Article>('articles');
  Box<Stock> stockBox = Hive.box<Stock>('stocks');
  List<Article> _articles = [];
  List<Stock> _stocks = [];
  Article? _selectedArticle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> _deleteArticle(Article article) async {
    
    
    for (var stock in stockBox.values.toList()) {
      if(stock.articleKey == article.key){
        setState(() {
           stockBox.delete(stock.key);
           _loadstocks();
          
        });
       
      }
    }
    setState(() {
       l.delete(article.key);
           _loadarticle();
    });
    
  }

  Future<List<Article>> _loadData() async {
    final articleBox = Hive.box<Article>('articles');
    final stockBox = Hive.box<Stock>('stocks');
    _articles = [];
    setState(() {
      
      for (var article in articleBox.values.toList()) {
      if (article.orgid == widget.user.orgId) {
        setState(() {
        _articles.add(article);
      
      });
      }}
       for (var stock in stockBox.values.toList()) {
      if (stock.orgid == widget.user.orgId) {
        setState(() {
        _stocks.add(stock);
      
      });
      }}
      
    });
    return _articles;
  }
  Future<List<Article>> _loadarticle() async {
    final articleBox = Hive.box<Article>('articles');
  _articles = [];
      for (var article in articleBox.values.toList()) {
      if (article.orgid == widget.user.orgId) {
        setState(() {
        _articles.add(article);
      
      });
      }}
     
    return _articles;
  }

  Future<List<Stock>> _loadstocks() async {
    final stockBox = Hive.box<Stock>('stocks');
    _stocks=[];
       for (var stock in stockBox.values.toList()) {
      if (stock.orgid == widget.user.orgId) {
        setState(() {
        _stocks.add(stock);
      
      });
      }}
    
    return _stocks;
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
    final int quantityPerBox = int.tryParse(_quantityPerBoxController.text) ?? 1;
    final double price = double.tryParse(_stockPriceController.text) ?? 0.0;
    final String supplier = _stockSupplierController.text;

    if (quantity > 0 && price > 0 && supplier.isNotEmpty && _selectedArticle != null) {
      final Stock stock = Stock(
        quantity: quantity,
        price: price,
        balance: quantity,
        supplier: supplier,
        description: '',
        quantityPerBox: quantityPerBox,
        buyDate: DateTime.now(),
        createdAt: DateTime.now(),
        articleKey: _selectedArticle!.key,
        orgid:widget.user.orgId,
      );

      stockBox.add(stock);
      List<Stock> selectedStockList = [];
      selectedStockList.add(stock);
      _selectedArticle?.stock.addAll(selectedStockList);
      _selectedArticle?.save();
      l.putAt(_selectedArticle!.key, _selectedArticle!);

      setState(() {
        _stocks.add(stock);
      });
      _stockQuantityController.clear();
      _quantityPerBoxController.clear();
      _stockPriceController.clear();
      _stockSupplierController.clear();
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
                    labelText: 'Sale Price',
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
                  items: _articles.map((article) {
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
                    labelText: 'Buy Price',
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: _stockSupplierController,
                  decoration: InputDecoration(
                    labelText: 'Supplier',
                  ),
                ),
                TextField(
                  controller: _quantityPerBoxController,
                  decoration: InputDecoration(
                    labelText: 'Quantity per box',
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
    final double bigSale = double.tryParse(_articleBigSalePriceController.text) ?? 0.0;
    if (name.isNotEmpty && type!.isNotEmpty && price > 0) {
      final Article article = Article(
        name: name,
        type: type,
        price: price,
        bigSalePrice: bigSale,
        stock: HiveList(Hive.box<Stock>('stocks')),
        createdAt: DateTime.now(),
       orgid:widget.user.orgId,
      );

      final articleBox = Hive.box<Article>('articles');
      articleBox.add(article);

      setState(() {
        _articles.add(article);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article added successfully.'),
        ),
      );
      _articleNameController.clear();
      _articlePriceController.clear();
      _articleBigSalePriceController.clear();
    }
  }

  void _editStock(Stock stock) {
    final TextEditingController _editQuantityController = TextEditingController();
    final TextEditingController _editPriceController = TextEditingController();
    final TextEditingController _editSupplierController = TextEditingController();
    final TextEditingController _editQuantityPerBoxController = TextEditingController();

    _editQuantityController.text = stock.quantity.toString();
    _editPriceController.text = stock.price.toString();
    _editSupplierController.text = stock.supplier;
    _editQuantityPerBoxController.text = stock.quantityPerBox.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Stock'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _editQuantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _editPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Buy Price',
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _editSupplierController,
                  decoration: InputDecoration(
                    labelText: 'Supplier',
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _editQuantityPerBoxController,
                  decoration: InputDecoration(
                    labelText: 'Quantity per box',
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
                _saveEditedStock(stock, _editQuantityController.text, _editPriceController.text, _editSupplierController.text, _editQuantityPerBoxController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveEditedStock(Stock stock, String editedQuantity, String editedPrice, String editedSupplier, String editedQuantityPerBox) {
    final int quantity = int.tryParse(editedQuantity) ?? 0;
    final double price = double.tryParse(editedPrice) ?? 0.0;
    final String supplier = editedSupplier;
    final int quantityPerBox = int.tryParse(editedQuantityPerBox) ?? 1;

    if (quantity > 0 && price > 0 && supplier.isNotEmpty && quantityPerBox > 0) {
      stock.quantity = quantity;
      stock.price = price;
      stock.supplier = supplier;
      stock.quantityPerBox = quantityPerBox;
      stock.save();
      
      setState(() {
       _articles;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock updated successfully.'),
        ),
      );
    }
  }

  void _saveEditedArticle(Article article, String editname, String editType, double editedPrice, double editbigSale) {
   
 
      article.bigSalePrice=editbigSale;
      article.name=editname;
      article.price=editedPrice;
      article.type =editType;
      article.save();
      
      setState(() {
        _stocks = stockBox.values.toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Article updated successfully.'),
        ),
      );
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
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Articles',
                        style: TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        onPressed: _openAddArticleModal,
                        child: Text('Add Article'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  FutureBuilder<List<Article>>(
                    future: _loadarticle(),
                    builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No articles found.');
                      } else {
                        List<Article> articles = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: articles.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Article article = articles[index];
                            return ListTile(
                              title: Text('Name:${article.name}',),
                              subtitle: Text('Type:${article.type}, Sale Price:\$${article.price}, Big Sale Price:\$${article.bigSalePrice}'),
                              trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    ElevatedButton(
      onPressed: () {
        final TextEditingController _editnameController = TextEditingController();
        final TextEditingController _edittypeController = TextEditingController();
        final TextEditingController _editpriceController = TextEditingController();
        final TextEditingController _editbigSaleController = TextEditingController();
        _editnameController.text = article.name;
        _edittypeController.text = article.type;
        _editpriceController.text = article.price.toString();
        _editbigSaleController.text = article.bigSalePrice.toString();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Edit Article'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _editnameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    SizedBox(height: 10.0),
                    DropdownButtonFormField<String>(
                      value: _edittypeController.text,
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
                          article.type = value!;
                          article.save();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Type',
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: _editpriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sale Price',
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: _editbigSaleController,
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
                    _saveEditedArticle(
                      article,
                      _editnameController.text,
                      _edittypeController.text,
                      double.parse(_editpriceController.text),
                      double.parse(_editbigSaleController.text),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
      child: Text('Edit'),
    ),
    SizedBox(width: 10.0), // Add spacing between the buttons
    ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Article'),
              content: Text('Are you sure you want to delete this article?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _deleteArticle(article); // Call a function to delete the article
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Customize button color
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
      child: Text('Delete'),
      style: ElevatedButton.styleFrom(
        primary: Colors.red, // Customize button color
      ),
    ),
  ],
),

                              
                            );
                          },
                        );
                      }
                    },
                  )

                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stocks',
                        style: TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        onPressed: _openAddStockModal,
                        child: Text('Add Stock'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  FutureBuilder<List<Stock>>(
                    future: _loadstocks(),
                    builder: (BuildContext context, AsyncSnapshot<List<Stock>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No stocks found.');
                      } else {
                        List<Stock> stocks = snapshot.data!;
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: stocks.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Stock stock = stocks[index];
                            final Article? art = l.get(stock.articleKey);
                            return ListTile(
                              title: Text('Stock Name: ${art!.name}'),
                              subtitle: Text('Stock Price:\$${stock.price}, quantity:${stock.quantity}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  _editStock(stock);
                                },
                                child: Text('Edit'),
                              ),
                            );
                          },
                        );
                      }
                    },
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
