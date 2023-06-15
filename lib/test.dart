import 'package:flutter/material.dart';

/// Flutter code sample for [Table].

void main() => runApp(const TableExampleApp());

class TableExampleApp extends StatelessWidget {
  const TableExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Table Sample')),
        body:  TableExample(),
      ),
    );
  }
}
class TableExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table Example'),
      ),
      body: Center(
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Age',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: const <DataRow>[
            DataRow(
              cells: <DataCell>[
                DataCell(Text('John')),
                DataCell(Text('25')),
                DataCell(Text('New York')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Jane')),
                DataCell(Text('30')),
                DataCell(Text('London')),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                DataCell(Text('Mike')),
                DataCell(Text('40')),
                DataCell(Text('Paris')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}