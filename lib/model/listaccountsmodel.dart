class ListAccountsModel {
  final List<ListAccounts> listAccounts;

  ListAccountsModel({
    this.listAccounts
  });

  factory ListAccountsModel.fromJson(List<dynamic> parsedJson) {

    List<ListAccounts> lisAccounts = new List<ListAccounts>();
    lisAccounts = parsedJson.map((i)=>ListAccounts.fromJson(i)).toList();

    return new ListAccountsModel(
        listAccounts: lisAccounts
    );
  }
}

class ListAccounts{
  final String name;
  final String address;

  ListAccounts({
    this.name,
    this.address
  }) ;

  factory ListAccounts.fromJson(Map<String, dynamic> json){

    return new ListAccounts(
        name: json['name'],
        address: json['address']
    );
  }
}