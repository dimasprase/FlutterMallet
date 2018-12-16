import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:iele_testnet/model/listaccountsmodel.dart';
import 'package:iele_testnet/util/separators.dart';
import 'package:iele_testnet/util/constants.dart';
import 'package:flutter/services.dart';
import 'package:iele_testnet/activity/SecondPage.dart';

class ListAcountsRoute extends CupertinoPageRoute {
  ListAcountsRoute() : super(builder: (BuildContext context) => new ListAcounts());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new ListAcounts());
  }
}

class ListAcounts extends StatefulWidget {
  static const String routeName = "/ListAcounts";

  @override
  ListAcountsState createState() => ListAcountsState();

}

class ListAcountsState extends State<ListAcounts> with WidgetsBindingObserver {
  String url;
  ListAccountsModel data;

  bool downloading = false;

  final _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _mySelection;

  Future<String> makeRequest() async {
    downloading = true;

    url = "http://52.221.142.167:5000/getAccount";
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    setState(() {
      final extractdata = json.decode(response.body);
      data = ListAccountsModel.fromJson(extractdata);
    });

    downloading = false;
  }

  @override
  void initState() {
    this.makeRequest();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  didPopRoute() {

  }

  @override
  Widget build(BuildContext context) {

    final makeBody = Container(
        child:
        new Container(
            child: new Stack(
              children: <Widget>[
                new Center(
                  child: downloading ? Container(
                      child: new Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: new SizedBox(
                            child: CircularProgressIndicator(),
                            height: 20.0,
                            width: 20.0,
                          )
                      )
                  ): Text(""),
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: data == null ? 0 : data.listAccounts.length,
                  itemBuilder: (BuildContext context, int i) {
                    return new Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Container(
                          decoration: BoxDecoration(
                            // Box decoration takes a gradient
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.1, 0.5, 0.7, 0.9],
                                colors: [
                                  // Colors are easy thanks to Flutter's Colors class.
                                  new Color(0xFF0E0B17),
                                  new Color(0xE60E0B17),
                                  new Color(0xCC0E0B17),
                                  new Color(0x990E0B17),
                                ],
                              )),
                          child: new ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: new BoxDecoration(
                                      border: new Border(
                                          right: new BorderSide(width: 2.0, color: new Color(0xff00c6ff)))
                                  ),
                                  child: Text((i+1).toString(), style: TextStyle(color: Colors.red, fontSize: 18.0))
                              ),
                              title:
                              Column(
                                children: <Widget>[
                                  Text(data.listAccounts[i].name, style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14.0)),
                                  new Separators()
                                ],
                              ),
                              subtitle: Column(
                                  children: <Widget> [
                                    new Text(data.listAccounts[i].address, style: TextStyle(color: Colors.orangeAccent, fontSize: 12.0)),
                                  ]
                              ),
                              onTap: () {
                                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new SecondPage(data.listAccounts[i])));
                                //_persistentBottomSheet(data.suratMasuk[i]);
                              }
                          )
                      ),
                    );
                  },
                )
              ],
            )
        )
    );

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        automaticallyImplyLeading: false,
        title: Text("IELE"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              _modalBottomSheet();
            },
          )
        ],
      ),
      body: makeBody,
    );
  }

  void _modalBottomSheet(){

    final password = TextFormField(
      autofocus: false,
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Create Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final submit = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: MaterialButton(
        onPressed: () {
          //Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
          createAccount();
        },
        color: new Color(0xFF003366),
        child: Text('Submit', style: TextStyle(color: Colors.white)),
      ),
    );

    showModalBottomSheet(
        context: context,
        builder: (builder){
          return new Container(
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: new Center(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(left: 24.0, right: 24.0),
                      children: <Widget>[
                        new Center(
                          child: Text("New Account"),
                        ),
                        Container(
                          height: 10.0,
                        ),
                        password,
                        SizedBox(height: 24.0),
                        submit
                      ],
                    )
                )
            )
          );
        }
    );
  }

  createAccount() async {
    Map datas = {
      'password': _passwordController.text
    };

    var url = 'http://52.221.142.167:5000/newAccount';
    http.post(url, body: datas)
        .then((response) {
      final data = json.decode(response.body);
      String responses = data['response'];

      if (responses == "success") {
        print('response '+responses);
        _passwordController.clear();
        Navigator.pop(context);
        Navigator.of(context).pushReplacementNamed(LIST_ACCOUNT);
      } else {

      }
    });
  }
}