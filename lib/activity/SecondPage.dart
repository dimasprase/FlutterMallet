import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:iele_testnet/model/detailaccount.dart';
import 'package:iele_testnet/util/separators.dart';
import 'package:iele_testnet/util/constants.dart';
import 'package:flutter/services.dart';
import 'package:iele_testnet/activity/TransferMoney.dart';

class SecondPage extends StatefulWidget {
  final data;
  final bool horizontal;

  SecondPage(this.data, {this.horizontal = true});

  SecondPage.vertical(this.data): horizontal = false;

  SecondPageState createState() => new SecondPageState(data);
}

class SecondPageState extends State<SecondPage> {

  final data;
  final bool horizontal;
  bool downloading = false;

  SecondPageState(this.data, {this.horizontal = true});

  SecondPageState.vertical(this.data): horizontal = false;

  final key = new GlobalKey<ScaffoldState>();

  Future<List<DetailAccount>> fetchDetailAccount() async {
    final response = await http.post('http://52.221.142.167:5000/detailAccount', body: {'address': data.address.toString()});
    print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<DetailAccount> detailList = createDetailList(responseJson);
    return detailList;
  }

  List<DetailAccount> createDetailList(List data){
    List<DetailAccount> list = new List();
    for (int i = 0; i < data.length; i++) {
      String address = data[i]["address"];
      String balance = data[i]["balance"];
      int txCount = data[i]["transactionCount"];
      DetailAccount user = new DetailAccount(
          address: address,balance: balance, txCount: txCount);
      list.add(user);
    }
    return list;
  }

  @override
  initState() {
    this.fetchDetailAccount();
  }


  @override
  Widget build(BuildContext context) {

    final pThumbnail =
    new Container(
      margin: new EdgeInsets.symmetric(
          vertical: 16.0
      ),
      alignment: horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: new Hero(
        tag: "HK",
        child: new Image(
          image: new AssetImage("assets/logo.png"),
          height: 72.0,
          width: 72.0,
        ),
      ),
    );

    final pCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(horizontal ? 76.0 : 16.0, horizontal ? 16.0 : 42.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          new Container(height: 4.0),
          new Text("Acount", style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600)),
          new Container(height: 12.0),
          new Text(data.name, style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w400)),
          new Separator(),
        ],
      ),
    );

    final pCard = new Container(
      child: pCardContent,
      height: horizontal ? 124.0 : 154.0,
      margin: horizontal
          ? new EdgeInsets.only(left: 46.0)
          : new EdgeInsets.only(top: 72.0),
      decoration: new BoxDecoration(
        color: new Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    final gesture = new GestureDetector(
        onTap: horizontal ? () => Navigator.of(context).push(new PageRouteBuilder(
          pageBuilder: (_, __, ___) => new SecondPage(data),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          new FadeTransition(opacity: animation, child: child),
        ) ,
        ) : null,
        child: new Container(
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          child: new Stack(
            children: <Widget>[
              pCard,
              pThumbnail,
            ],
          ),
        )
    );

    Container _getGradient() {
      return new Container(
        margin: new EdgeInsets.only(top: 190.0),
        height: 110.0,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: <Color>[
              new Color(0xFFFFFFFF),
              new Color(0xFFFFFFFF)
            ],
            stops: [0.0, 0.9],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
          ),
        ),
      );
    }

    final submit =
    Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.0),
          child: MaterialButton(
            onPressed: () {
              //Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
              getBalance();
            },
            color: new Color(0xFF003366),
            child: Text('Get Balance', style: TextStyle(color: Colors.white)),
          ),
        )
    );

    String _copy = data.address;

    return new Scaffold(
      key: key,
      appBar: AppBar(
        title: Text("Detail Account"),
      ),
      body: new Container(
        constraints: new BoxConstraints.expand(),
        color: Colors.white,
        child: new Stack (
          children: <Widget>[
            _getGradient(),
            new Container(
              child: new FutureBuilder<List<DetailAccount>>(
                future: fetchDetailAccount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: new ListView(
                        padding: new EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 32.0),
                        children: <Widget>[
                          gesture,
                          new Container(
                            padding: new EdgeInsets.symmetric(horizontal: 32.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    new Text("Detail Account", style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w400)),
                                    Padding(
                                        padding: new EdgeInsets.only(left: 10.0),
                                        child: new Icon(Icons.contact_mail, color: Colors.black, size: 16.0)
                                    )
                                  ],
                                ),
                                new Separator(),
                                new Column(
                                  children: <Widget>[
                                    new Row (
                                      children: <Widget>[
                                        new Text("Address :", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                    new Container(height: 10.0),
                                    new Row(
                                      children: <Widget>[
                                        Expanded (
                                            child: new GestureDetector(
                                              child: new Text(_copy),
                                              onLongPress: () {
                                                Clipboard.setData(new ClipboardData(text: _copy));
                                                key.currentState.showSnackBar(
                                                    new SnackBar(content: new Text("Copied to Clipboard"),));
                                              },
                                            )

                                        )
                                      ],
                                    ),
                                    new Row(
                                      children: <Widget>[
                                        new Separator()
                                      ],
                                    ),
                                    new Row (
                                      children: <Widget>[
                                        new Text("Transaction Count :", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                    new Container(height: 10.0),
                                    new Row(
                                      children: <Widget>[
                                        Expanded (
                                            child: new Text(snapshot.data[0].txCount.toString(), style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                new Container(height: 10.0),
                                new Separators(),
                                new Container(height: 10.0),
                                Row(
                                  children: <Widget>[
                                    new Text("Balance", style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w400)),
                                    Padding(
                                        padding: new EdgeInsets.only(left: 10.0),
                                        child: new Icon(Icons.monetization_on, color: Colors.black, size: 16.0)
                                    )
                                  ],
                                ),
                                new Separator(),
                                new Column(
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new Text("Your Balance :", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                    new Container(height: 10.0),
                                    new Row(
                                      children: <Widget>[
                                        Expanded (
                                            child: new Text(snapshot.data[0].balance, style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                        )
                                      ],
                                    ),
                                    new Container(height: 5.0),
                                    submit,
                                    new Container(height: 2.0),
                                    Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 1.0),
                                          child: MaterialButton(
                                            onPressed: () {
                                              Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new TransferMoney(snapshot.data[0].address)));
                                            },
                                            color: new Color(0xFF003366),
                                            child: Text('Transfer Money', style: TextStyle(color: Colors.white)),
                                          ),
                                        )
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return new Text("${snapshot.error}");
                  }
                  return new Center(
                    child: new Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: new SizedBox(
                          child: CircularProgressIndicator(),
                          height: 20.0,
                          width: 20.0,
                        )
                    ),
                  );
                  // By default, show a loading spinner
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  getBalance() async {
    Map datas = {
      'address': data.address
    };

    var url = 'http://52.221.142.167:5000/getBalance';
    http.post(url, body: datas)
        .then((response) {
      final data = json.decode(response.body);
      String responses = data['response'];

      if (responses == "success") {
        print('response '+responses);
        Navigator.pop(context);
      } else {

      }
    });
  }

}