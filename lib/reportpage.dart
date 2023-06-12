
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharma1/models/sale.dart';


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

  Future<List<Sale>> fetchSales() async {
    final box = Hive.box<Sale>('sales5');
    List<Sale> sales = box.values.toList();
    print(fromDate);
    if (fromDate != null && toDate != null) {
      sales.forEach((element) {print(element.createdAt.isAfter(fromDate!)); print(element.createdAt.isBefore(toDate!));});
      sales = sales.where((sale) {
        return sale.createdAt.isAfter(fromDate!) &&
            sale.createdAt.isBefore(toDate!);
      }).toList();
      print("get the list");
      print(sales);
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
                return Expanded(
                  child: ListView.builder(
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return ListTile(
                        title: Text('Sale ${index + 1}'),
                        subtitle: Text('Created at: ${sale.createdAt}'),
                        trailing: Text('Price: \$${sale.price.toStringAsFixed(2)}'),
                        // Display other properties of your Sale object
                      );
                    },
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
