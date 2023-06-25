import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pharma/models/sale.dart';

import 'models/article.dart';
import 'models/stock.dart';
import 'models/user.dart';

class ReportPage extends StatefulWidget {
  ReportPage({Key? key,required this.user}) : super(key: key);
  final User user;
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? fromDate;
  DateTime? toDate;
  final articleBox = Hive.box<Article>('articles');
  final stockBox = Hive.box<Stock>('stocks');
  double totalQuantity = 0;
  double totalSalePrice = 0;
  double totalBuyPrice = 0;
  double totalBenefit = 0;

  Future<List<Sale>> fetchSales() async {
    final box = Hive.box<Sale>('sales');
    List<Sale> sales = [];
    for(int i=0; i<box.values.toList().length; i++){
       Sale sale = box.values.toList()[i];
     if (sale.isSale && sale.orgid==widget.user.orgId){
          sales.add(sale);
          
        }
    }
    if (fromDate != null && toDate != null) {
      sales = sales.where((sale) {
        return sale.createdAt.isAfter(fromDate!) &&
            sale.createdAt.isBefore(toDate!.add(const Duration(hours: 23, minutes:59, milliseconds: 59,microseconds: 59 ))) &&
            sale.isSale;
      }).toList();

      totalQuantity = 0;
      totalSalePrice = 0;
      totalBuyPrice = 0;
      totalBenefit = 0;

      sales.forEach((sale) {
        
        final stock = stockBox.get(sale.stockKey);

        totalQuantity += sale.quantity;
        totalSalePrice += sale.price;
        totalBuyPrice += stock!.price;
        totalBenefit += sale.quantity * sale.price - sale.quantity * stock.price;
      });

      return sales;
    } else {
      sales = <Sale>[];
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
                lastDate: DateTime.now(),
              );

              setState(() {
                toDate = selectedDate;
              });
            },
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     setState(() {
          //       fetchSales();
          //     });
          //   },
          //   child: Text('Generate Report'),
          // ),
          SizedBox(height: 50,),
          FutureBuilder<List<Sale>>(
            future: fetchSales(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final sales = snapshot.data!;

                if (sales.isEmpty) {
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
                    rows: [
                      ...sales.map((sale) {
                        final article = articleBox.get(sale.articleKey);
                        final stock = stockBox.get(sale.stockKey);
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(article!.name)),
                            DataCell(Text('${sale.quantity}')),
                            DataCell(Text('${sale.price}')),
                            DataCell(Text('${stock!.price}')),
                            DataCell(
                              Text(
                                '${sale.quantity * sale.price - sale.quantity * stock.price}',
                                style: TextStyle(
                                  color: sale.quantity * sale.price - sale.quantity * stock.price < 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ),
                            DataCell(Text(
                                '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}')),
                          ],
                        );
                      }).toList(),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(totalQuantity.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(totalSalePrice.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(totalBuyPrice.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(
                            Text(totalBenefit.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: totalBenefit < 0 ? Colors.red : Colors.green)),
                          ),
                          DataCell(Text('')),
                        ],
                      ),
                    ],
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
