import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharma1/login.dart';
import 'package:pharma1/manage.dart';
import 'package:pharma1/models/stock.dart';
import 'package:pharma1/models/user.dart';
import 'package:pharma1/reportpage.dart';
import 'models/article.dart';
import 'models/sale.dart';
class SalePage extends StatefulWidget {
   SalePage({Key? key, required this.user}) : super(key: key);
  final User user;
  
  @override
  _SalePageState createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
 
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final saleBox = Hive.box<Sale>('sales');
  final articleBox = Hive.box<Article>('articles');
  final stockBox = Hive.box<Stock>('stocks');
  final userBox = Hive.box<User>('users');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwor1dController = TextEditingController();
 
  void register() {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwor1dController.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      // Show an error message or handle empty fields
      return;
    }
    // Save user to Hive
    
    final user = User(
      username: username,
      email: email,
      password: password,
      isAdmin: false,
      isActive: true,
      createdAt: DateTime.now(),
      orgId: widget.user.orgId,
    );
    userBox.add(user);
    _usernameController.clear();
    _emailController.clear();
    _passwor1dController.clear();
   Navigator.of(context).pop();
  }
  List<Article> _articles = [];
  List<Sale> _sales = [];
  double total = 0;
  @override
  void initState() {
    
    super.initState();
    
  }

  Future<void> _loadArticles() async {
   final user = widget.user;
    for (var article in articleBox.values.toList()) {
    if (article.orgid == user.orgId) {
       setState(() {
      _articles.add(article);
     
    });
    }}
   
  }
  Future<List<Sale>> fetchSales() async {
    final box = Hive.box<Sale>('sales');
    
    List<Sale> sales=[];
    _sales=[];
    for(int i=0; i<box.values.toList().length; i++){
       Sale sale = saleBox.values.toList()[i];
     if (!sale.isSale && sale.orgid==widget.user.orgId){
          sales.add(sale);
          _sales.add(sale);
        }
    }
   
    setState(() {
      total=0;
      
       _sales.forEach((element) { total+= element.quantity * element.price;});
    });
      return sales;
  }
  Future<void> deleteUser(User user) async{
    setState(() {
      userBox.delete(user.key);
      Navigator.of(context).pop();
    });
    
  }

  Future<List<User>> fetchUsers() async {
    final box = Hive.box<User>('users');
    List<User> users=[];
    for(int i=0; i<box.values.toList().length; i++){
       User user = box.values.toList()[i];
     if (user.orgId==widget.user.orgId && !user.isAdmin){
     
          users.add(user);
        }
    }
      return users;
  }
  Future<List<Sale>> confirmSale() async {
    final box = Hive.box<Sale>('sales');
    List<Sale> sales=[];
    for(int i=0; i<box.values.toList().length; i++){
       Sale sale = saleBox.values.toList()[i];
     if (!sale.isSale){
        Stock? stock = stockBox.get(sale.stockKey);
        sale.isSale = true;
        sale.save();
        stock!.quantity-=sale.quantity;
        stock.save();
        stockBox.put(stock.key, stock);
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
  Future<void> removeItemFromCart(int index ,Sale sale) async {
   saleBox.delete(index);
   fetchSales();
  }
  
   Future<void> _loadSales() async {

    setState(() {
      total=0;
      _sales=[];
      for(int i=0; i<saleBox.values.toList().length; i++){
        Sale sale = saleBox.values.toList()[i];
        if (!sale.isSale && sale.orgid== widget.user.orgId){
          _sales.add(sale);
        }
        
      }
      _sales.forEach((element) { total+= element.quantity * element.price;});
      print(total);
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
  void openmodal(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwor1dController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    
                  },
                ),
                SizedBox(height: 10.0),
                
               
                SizedBox(height: 20.0),
               
                  
                 
                
               
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
                    onPressed: register,
                    child: Text('add User'),
                  ),
          ],
        );
      },
    );
  }

  void openUsermodal() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Users'),
        content: SingleChildScrollView(
          child: FutureBuilder<List<User>>(
            future: fetchUsers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final users = snapshot.data!;
                return Column(
                  children: users.map((user) => ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                          icon: const Icon(
                            
                            Icons.delete,
                            color: Colors.red,
                          ),
                        
                          onPressed: (){
                            setState(() {
                              deleteUser(user);
                              });
                            }),
                  )).toList(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
        actions: [
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                //   child: Text('Cancel'),
                // ),
                ElevatedButton(
                  onPressed: () {
                    
                    Navigator.of(context).pop();
                _navigateToPage('Add User');
                  },
                  child: Text('Add User'),
                ),
              ],
      );
    },
  );
}

  void _saveSale(Article article, int quantity) {
    List selectedStockList=[];
   
   
    
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
    final Sale sale = Sale(stockKey: stock.key, price: article.price, quantity: quantity, createdAt: DateTime.now(), articleKey: article.key, isSale: false,orgid:widget.user.orgId
    );
    
    saleBox.add(sale);
    
    
    sale.save();
   
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
        Navigator.of(context).pop();
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>   ReportPage(user: widget.user) ,
          ),
        );
        break;
      case 'Sale':
        // Navigate to the sale page
        break;
      case 'Manage':
      Navigator.of(context).pop();
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>  ManagerPage(user: widget.user),
            
          ),
        );
        break;
      case 'Add User':
      openmodal();
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
        
        actions: [
          if(widget.user.isAdmin)
          IconButton(
          icon: const Icon(
            Icons.person,
            color: Colors.grey,
          ),
         
          onPressed: (){
            setState(() {
              openUsermodal();
              });
            }),
        ],
        
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            if( widget.user.isAdmin)
              ListTile(
              title: const Text('Report'),
              onTap: () {
                _navigateToPage('Report');
              },
            ),
            if( widget.user.isAdmin)
            ListTile(
              title: const Text('Manage'),
              onTap: () {
                _navigateToPage('Manage');
              },
            ),
           if( widget.user.isAdmin)
             ListTile(
              title: const Text('Add User'),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToPage('Add User');
               
              },
            ),
             ListTile(
              title: const Text('Logout'),
              onTap: () {
               Navigator.of(context).pop();
               Navigator.of(context).push(
                 MaterialPageRoute(
            builder: (context) =>  const LoginPage(),
            
          ),
               );
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
                final newSales = snapshot.data!;
                if (newSales.isEmpty) {
                  // Display a message when no sales exist
                  return Text('');
                }
                return Expanded(
                      child: ListView.builder(
                        itemCount: newSales.length,
                        itemBuilder: (context, index) {
                          final sale = newSales[index];
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
                                      removeItemFromCart(sale.key, sale);
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
