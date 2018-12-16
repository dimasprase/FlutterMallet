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

class TransferMoney extends StatefulWidget {
  final data;
  final bool horizontal;

  TransferMoney(this.data, {this.horizontal = true});

  TransferMoney.vertical(this.data): horizontal = false;

  TransferMoneyState createState() => new TransferMoneyState(data);
}

class TransferMoneyState extends State<TransferMoney> {

  final dataAddress;
  final bool horizontal;

  TransferMoneyState(this.dataAddress, {this.horizontal = true});

  TransferMoneyState.vertical(this.dataAddress): horizontal = false;


  String url;
  ListAccountsModel dataList;

  final _passwordController = TextEditingController();
  final _gasController = TextEditingController();
  final _valueController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _mySelection;

  Future<List<ListAccountDropDown>> makeRequest() async {
    final response = await http.get('http://52.221.142.167:5000/getAccount');
    //print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<ListAccountDropDown> detailList = createDetailList(responseJson);
    return detailList;
  }

  List<ListAccountDropDown> createDetailList(List data){
    List<ListAccountDropDown> list = new List();
    for (int i = 0; i < data.length; i++) {
      String name = data[i]["name"];
      String address = data[i]["address"];

      if (address == dataAddress.toString()) {

      } else {
        ListAccountDropDown user = new ListAccountDropDown(
            name: name,address: address);
        list.add(user);
      }
    }
    return list;
  }

  @override
  void initState() {
    this.makeRequest();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Transfer Money"),
      ),
      body: new FutureBuilder<List<ListAccountDropDown>>(
        future: makeRequest(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                child: new Column(
                  children: <Widget>[
                    new ListTile(
                      leading: const Icon(Icons.monetization_on),
                      title: new TextField(
                        autofocus: false,
                        controller: _valueController,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          hintText: "Value",
                        ),
                      ),
                    ),
                    new ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: new TextField(
                        autofocus: false,
                        controller: _gasController,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          hintText: "Gas",
                        ),
                      ),
                    ),
                    new ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: new TextField(
                        autofocus: false,
                        controller: _passwordController,
                        obscureText: true,
                        decoration: new InputDecoration(
                          hintText: "Your Password",
                        ),
                      ),
                    ),
                    new ListTile(
                        leading: const Icon(Icons.email),
                        title: new DropdownButton(
                          isDense: true,
                          hint: new Text("Select Account"),
                          items: snapshot.data.map((item) {
                            return new DropdownMenuItem(
                              child: new Text(item.name),
                              value: item.address,
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              _mySelection = newVal;
                            });
                          },
                          value: _mySelection,
                        )
                    ),
                    Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: MaterialButton(
                            onPressed: () {
                              //Navigator.of(context).pushReplacementNamed(HOME_SCREEN);
                              if (_gasController.text == "") {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Gas Cannot empty"), duration: Duration(seconds: 3),));
                              } else if (_valueController.text == "") {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Value Cannot empty"), duration: Duration(seconds: 3),));
                              } else if (_passwordController.text == "") {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Password Cannot empty"), duration: Duration(seconds: 3),));
                              } else if (_mySelection == null) {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please select receiver address"), duration: Duration(seconds: 3),));
                              } else {
                                print("Select : " +_mySelection);
                                Map datas = {
                                  'address': dataAddress.toString(),
                                  'addressTo': _mySelection,
                                  'gas': _gasController.text,
                                  'value': _valueController.text,
                                  'password': _passwordController.text
                                };

                                var url = 'http://52.221.142.167:5000/simpleTransfer';
                                http.post(url, body: datas).then((response) {
                                  if (response.statusCode == 500) {
                                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Wrong Password"), duration: Duration(seconds: 3),));
                                  } else if (response.statusCode == 200) {
                                    final data = json.decode(response.body);
                                    String responses = data['response'];
                                    if (responses == "success") {
                                      print('response '+responses);
                                      _passwordController.clear();
                                      _gasController.clear();
                                      _valueController.clear();
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Unknown Error"), duration: Duration(seconds: 3),));
                                  }
                                });
                              }
                            },
                            color: new Color(0xFF003366),
                            child: Text('Send Money', style: TextStyle(color: Colors.white)),
                          ),
                        )
                    )
                  ],
                )
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
      )
    );
  }

}