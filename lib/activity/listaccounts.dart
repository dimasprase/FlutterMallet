import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:iele_testnet/model/listaccountsmodel.dart';
import 'package:iele_testnet/model/detailaccount.dart';
import 'package:iele_testnet/util/separators.dart';
import 'package:iele_testnet/util/constants.dart';
import 'package:flutter/services.dart';

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

class SecondPage extends StatefulWidget {
  final data;
  final bool horizontal;

  SecondPage(this.data, {this.horizontal = true});

  SecondPage.vertical(this.data): horizontal = false;

  SecondPageState createState() => new SecondPageState(data);
}

class SecondPageState extends State<SecondPage> {

  ListAccountsModels datass;

  final data;
  final bool horizontal;
  bool downloading = false;

  SecondPageState(this.data, {this.horizontal = true});

  SecondPageState.vertical(this.data): horizontal = false;

  final key = new GlobalKey<ScaffoldState>();

  Future<List<Users>> fetchUsersFromGitHub() async {
    final response = await http.post('http://52.221.142.167:5000/detailAccount', body: {'address': data.address.toString()});
    print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<Users> userList = createUserList(responseJson);
    return userList;
  }

  List<Users> createUserList(List data){
    List<Users> list = new List();
    for (int i = 0; i < data.length; i++) {
      String title = data[i]["address"];
      String id = data[i]["balance"];
      Users user = new Users(
          name: title,id: id);
      list.add(user);
    }
    return list;
  }

  @override
  initState() {
    this.fetchUsersFromGitHub();
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
        padding: EdgeInsets.symmetric(vertical: 5.0),
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
              child: new FutureBuilder<List<Users>>(
                future: fetchUsersFromGitHub(),
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
                                        new Text("Address", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
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
                                        new Text("Saldo", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                    new Container(height: 10.0),
                                    new Row(
                                      children: <Widget>[
                                        Expanded (
                                          child: new Text(snapshot.data[0].id, style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w400))
                                        )
                                      ],
                                    ),
                                    new Container(height: 10.0),
                                    submit,
                                    new Container(height: 10.0)
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

class Users {
  String name;
  String id;
  Users({this.name,this.id});
}