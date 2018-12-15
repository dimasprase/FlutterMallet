class ListAccountsModels {
  final List<ListAccountss> listAccountss;

  ListAccountsModels({
    this.listAccountss
  });

  factory ListAccountsModels.fromJson(List<dynamic> parsedJson) {

    List<ListAccountss> lisAccountss = new List<ListAccountss>();
    lisAccountss = parsedJson.map((i)=>ListAccountss.fromJson(i)).toList();

    return new ListAccountsModels(
        listAccountss: lisAccountss
    );
  }
}

class ListAccountss{
  final String balance;
  final String address;

  ListAccountss({
    this.balance,
    this.address
  }) ;

  factory ListAccountss.fromJson(Map<String, dynamic> json){

    return new ListAccountss(
        balance: json['balance'],
        address: json['address']
    );
  }
}