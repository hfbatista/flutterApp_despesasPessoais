import 'dart:io';
import 'dart:math';
import 'package:expenses/components/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:expenses/components/transaction_form.dart';
import 'package:expenses/models/transaction.dart';
import 'package:expenses/components/transaction_list.dart';

void main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              title: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              button:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showChart = false;
  final List<Transaction> _transactions = [
    Transaction(
      id: 't0',
      title: 'Novo tênis de Corrida',
      value: 930.76,
      date: DateTime.now().subtract(Duration(days: 3)),
    ),
    Transaction(
      id: 't2',
      title: 'Conta de Luz',
      value: 117.76,
      date: DateTime.now().subtract(Duration(days: 4)),
    ),
    Transaction(
      id: 't3',
      title: 'Conta de Antiga',
      value: 800.76,
      date: DateTime.now().subtract(Duration(days: 6)),
    ),
    Transaction(
      id: 't4',
      title: 'Cartão de Credito',
      value: 2320.76,
      date: DateTime.now(),
    ),
    Transaction(
      id: 't5',
      title: 'Franquia Seguro',
      value: 700.76,
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
    Transaction(
      id: 't6',
      title: 'Conta de Água',
      value: 94.76,
      date: DateTime.now().subtract(Duration(days: 6)),
    ),
    Transaction(
      id: 't7',
      title: 'Conta de Celular',
      value: 130.76,
      date: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  Widget _getIconButton(IconData icon, Function fn) {
    return Platform.isIOS
        ? Padding(
          padding: const EdgeInsets.only(left:20),
          child: GestureDetector(
              onTap: fn,
              child: Icon(
                icon,
                color: Colors.white,
              )),
        )
        : Padding(
          padding: const EdgeInsets.only(left:20),
          child: IconButton(
              icon: Icon(icon),
              onPressed: fn,
            ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final _mediaContext = MediaQuery.of(context);
    bool isLandscape = _mediaContext.orientation == Orientation.landscape;

    final _actions = <Widget>[
      if (isLandscape)
        _getIconButton(
          _showChart ? Icons.list : Icons.insert_chart,
          () {
            setState(() {
              _showChart = !_showChart;
            });
          },
        ),
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add_circled : Icons.add_circle_outline,
        () => _openTransactionFormModal(context),
      ),
    ];

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Despesas Pessoais',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: _actions,
            ),
            backgroundColor: Theme.of(context).primaryColor,
          )
        : AppBar(
            title: Text('Despesas Pessoais'),
            actions: _actions,
          );

    final availableHeight = _mediaContext.size.height -
        appBar.preferredSize.height -
        _mediaContext.padding.top;

    final _bodyPage = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_showChart || !isLandscape)
              Container(
                height: availableHeight * (isLandscape ? 0.9 : 0.25),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !isLandscape)
              Container(
                height: availableHeight * (isLandscape ? 0.9 : 0.7),
                child: TransactionList(_transactions, _removeTransaction),
              ),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: _bodyPage,
          )
        : Scaffold(
            appBar: appBar,
            body: _bodyPage,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _openTransactionFormModal(context),
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat);
  }
}
