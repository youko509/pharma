
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharma1/models/sale.dart';

import 'models/article.dart';
import 'models/stock.dart';

// import 'models/stock.dart';


class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

 

  @override
  State<ReportPage> createState() => _ReportPageState();
}



class _ReportPageState extends State<ReportPage> {
  DateTime? fromDate;
  DateTime? toDate;
  final articleBox = Hive.box<Article>('articles');
  final stockBox = Hive.box<Stock>('stocks');
  Future<List<Sale>> fetchSales() async {
    final box = Hive.box<Sale>('sales');
    List<Sale> sales = box.values.toList();
    
    if (fromDate != null && toDate != null) {
     
      sales = sales.where((sale) {
        return sale.createdAt.isAfter(fromDate!) &&
            sale.createdAt.isBefore(toDate!) && sale.isSale;
      }).toList();
      for(int i= 0; i<sales.length; i++){
          print(sales[i].quantity);
      }
      
      return sales;
    } else{
      sales =<Sale>[];
      return sales;
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Page'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('From Date'),
            subtitle: Text(fromDate?.toString() ?? 'Select a date'),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              setState(() {
                fromDate = selectedDate;
              });
            },
          ),
          ListTile(
            title: Text('To Date'),
            subtitle: Text(toDate?.toString() ?? 'Select a date'),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(hours: 22)),
              );

              setState(() {
                toDate = selectedDate;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {fetchSales();});
            },
            child: Text('Generate Report'),
          ),
          
FutureBuilder<List<Sale>>(
  future: fetchSales(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final sales = snapshot.data!;
      
      if (sales.isEmpty) {
        // Display a message when no sales exist
        return Text('No sales found');
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Product',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Sale Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Buy Price',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Benefice',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: sales.map((sale) {
            final article = articleBox.get(sale.articleKey);
            final stock = stockBox.get(sale.stockKey);
            return DataRow(
              cells: <DataCell>[
                DataCell(Text(article!.name)),
                DataCell(Text('${sale.quantity}')),
                DataCell(Text('${sale.price}')),
                DataCell(Text('${stock!.price}')),
                DataCell(Text('${sale.quantity*sale.price - sale.quantity*stock.price}',
                style: TextStyle(
                  color: sale.quantity * sale.price - sale.quantity * stock.price < 0
                      ? Colors.red
                      : Colors.green,
                ),
                ),),
                DataCell(Text('${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}')),
              ],
            );
          }).toList(),
          
        ),
      );
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return CircularProgressIndicator();
    }
  },
),

        ],
      ),
    );
  }
}
