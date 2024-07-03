import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price List',
      theme: ThemeData(primaryColor: Colors.white),
      home: const CryptoList(),
    );
  }
}

class CryptoList extends StatefulWidget {
  const CryptoList({super.key});

  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State<CryptoList> {
  List _cryptoList = [];
  final _saved = <Map>{};
  final _boldStyle = const TextStyle(fontWeight: FontWeight.bold);
  bool _loading = false;
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];

  Future<void> getCryptoPrices() async {
    String apiURL = "https://api.coinlore.net/api/tickers/";
    setState(() {
      _loading = true;
    });

    try {
      Uri uri = Uri.parse(apiURL);
      http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          _cryptoList = jsonDecode(response.body)['data'];
          _loading = false;

        });
      } else {
        throw Exception('Failed to load crypto prices: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _loading = false;
      });

    }
  }

  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals).toInt();
    double d = double.parse(crypto['price_usd']);
    return "\$${d = (d * fac).round() / fac}";
  }

  CircleAvatar _getLeadingWidget(String name, MaterialColor color) {
    return CircleAvatar(
      backgroundColor: color,
      child: Text(name[0]),
    );
  }

  _getMainBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return RefreshIndicator(
        onRefresh: getCryptoPrices,
        child: _buildCryptoList(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCryptoPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belajar Membuat Crypto List Menggunakan REST API -> https://api.coinlore.net/api/tickers/'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _getMainBody(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
                (crypto) {
              return ListTile(
                leading: _getLeadingWidget(crypto['name'], Colors.blue),
                title: Text(crypto['name']),
                subtitle: Text(
                  cryptoPrice(crypto),
                  style: _boldStyle,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Cryptos'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
      itemCount: _cryptoList.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        final index = i;
        final MaterialColor color = _colors[index % _colors.length];
        return _buildRow(_cryptoList[index], color);
      },
    );
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    final bool favourited = _saved.contains(crypto);

    void fav() {
      setState(() {
        if (favourited) {
          _saved.remove(crypto);
        } else {
          _saved.add(crypto);
        }
      });
    }

    return ListTile(
      leading: _getLeadingWidget(crypto['name'], color),
      title: Text(crypto['name']),
      subtitle: Text(
        cryptoPrice(crypto),
        style: _boldStyle,
      ),
      trailing: IconButton(
        icon: Icon(favourited ? Icons.favorite : Icons.favorite_border),
        color: favourited ? Colors.red : null,
        onPressed: fav,
      ),
    );
  }
}
