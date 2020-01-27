import 'dart:convert';
import 'package:caffe/Report_Screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


import 'Table_Screen.dart';
import 'constants.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'Main_Screen';
  static var ListOfTable = [];
  static var alltrans=[];
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var categoriesshared = [
    {'name': 'Juice'},
    {'name': 'Sandwish'},
    {'name': 'Caffe'},
    {'name': 'Argile'},
  ];

  TextEditingController _textEditingController1 = TextEditingController();
  var numbOfTablle = '';
  var nameofcategorie = '';

  var newitem = '';
  var newprice = 0;
  var allcat = [];
  void getalltransaction()async{
    var url =
        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/transaction';
    var response = await http.get(url);
    Map data = json.decode(response.body);
    MainScreen.alltrans.clear();
    for (var msg in data["documents"]) {
      final numb = msg["fields"]["billnum"]["stringValue"];
      final tablename=msg["fields"]["tablename"]["stringValue"];
      final total=msg["fields"]["total"]["doubleValue"].toDouble();
      final time = DateTime.parse(msg["createTime"]);
      final items= msg["fields"]["items"];

      setState(() {
        MainScreen.alltrans.add({
          'billnum':numb,
          'tablename':tablename,
          'total':total,
          'timestamp':time,
          'items':jsonEncode(items),
        });
      });


    }
//    MainScreen.alltrans.sort((a, b) {
//      return a['numb'].toLowerCase().compareTo(b['numb'].toLowerCase());
//    });
    print(MainScreen.alltrans);
  }

  void getallcat() async {
    var url1 =
        'https://firestore.googleapis.com/v1/projects/caffe-38150/databases/(default)/documents/categories';
    var response = await http.get(url1);

    Map data = json.decode(response.body);
    allcat.clear();
    for (var msg in data['documents']) {
      final numb = msg['fields']['name']["stringValue"];

      setState(() {
        allcat.add({
          'display': numb,
          'value': numb,
        });
      });
    }

  }
 

  void getTableNumber() async {
    MainScreen.ListOfTable.clear();
    var url1 =
        'https://firestore.googleapis.com/v1/projects/caffe-38150/databases/(default)/documents/tables';
    var response = await http.get(url1);

    Map data = json.decode(response.body);

    for (var msg in data['documents']) {
      final numb = msg['fields']['numb']["stringValue"];
      final iswaiting = msg['fields']['iswaiting']["booleanValue"];
      setState(() {
        MainScreen.ListOfTable.add({
          'numb': numb,
          'iswaiting': iswaiting,
        });
      });
      MainScreen.ListOfTable.sort((a, b) {
        return a['numb'].toLowerCase().compareTo(b['numb'].toLowerCase());
      });
    }
  }

  void getallItems() async {
    TableScreen.AllItems.clear();
    var url1 =
        'https://firestore.googleapis.com/v1/projects/caffe-38150/databases/(default)/documents/categories';
    var response = await http.get(url1);

    Map data = json.decode(response.body);

    for (var msg in data['documents']) {
      final name = msg['fields']['name']["stringValue"];
      setState(() {
        TableScreen.AllItems.add({
          'name': name,
        });
      });
    }
  }

  @override
  void initState() {
  
    super.initState();
    getTableNumber();
    getallItems();
    getallcat();
    getalltransaction();

  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
        body: Row(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Center(
                  child: Text(
                    'Caffe',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                backgroundColor: Colors.white,
              ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onDoubleTap: () {
                          TableScreen.TableName =
                              'Table ${MainScreen.ListOfTable[index]['numb']}';
                          TableScreen.indexx = index;
                          Navigator.pushNamed(context, TableScreen.id);
                        },
                        child: Card(
                          elevation: 20,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("assets/images/table.jpeg"),
                                  fit: BoxFit.cover),
                            ),
                            child: Center(
                                child: Column(
                              children: <Widget>[
                                Text(
                                  'Table ${MainScreen.ListOfTable[index]['numb']}',
                                  style: TextStyle(fontSize: 40),
                                ),
                                MainScreen.ListOfTable[index]['iswaiting']
                                    ? Text(
                                        'Waiting',
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Text(
                                        'Available',
                                        style: TextStyle(color: Colors.green),
                                      ),
                              ],
                            )),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: MainScreen.ListOfTable.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  ///no.of items in the horizontal axis
                  crossAxisCount: (data.size.width / 350.0).round(),
                ),
              )
            ],
          ),
        ),
        Container(
          width: data.size.width / 3,
          color: Colors.blue,
          child: Column(
            children: <Widget>[
              MaterialButton(
                child: Text('Add New Categoie'),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Card(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    child: TextField(
                                      controller: _textEditingController1,
                                      keyboardType: TextInputType.emailAddress,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          nameofcategorie = value;
                                        });
                                      },
                                      decoration:
                                          KTextFieldImputDecoration.copyWith(
                                              hintText:
                                                  'Enter Name of categori'),
                                    )),
                                MaterialButton(
                                  onPressed: () async {
                                    var posturl =
                                        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/categories';
                                    var bodypost = jsonEncode({
                                      "fields": {
                                        "name": {
                                          "stringValue": nameofcategorie
                                        },
                                      }
                                    });
                                    await http.post(posturl, body: bodypost);
                                    getallItems();
                                    _textEditingController1.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Send'),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
              MaterialButton(
                child: Text('Add New Item'),
                onPressed: () {
                  getallcat();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        var categorieValue = '';
                        return StatefulBuilder(
                          builder: (context ,setState){
                          return AlertDialog(
                            content: Card(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: DropDownFormField(
                                      titleText: 'Select Categorie',
                                      hintText: 'Please choose one',
                                      value: categorieValue,
                                      onSaved: (value) {
                                        setState(() {
                                          categorieValue = value;
                                        });
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          categorieValue = value;
                                        });
                                      },
                                      dataSource: allcat,
                                      textField: 'display',
                                      valueField: 'value',
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10),
                                      child: TextField(
                                        controller: _textEditingController1,
                                        keyboardType: TextInputType.emailAddress,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) {
                                          setState(() {
                                            newitem = value;
                                          });
                                        },
                                        decoration:
                                            KTextFieldImputDecoration.copyWith(
                                                hintText: 'Enter Name of Item'),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10, top: 10),
                                      child: TextField(

                                        keyboardType: TextInputType.emailAddress,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) {
                                          setState(() {
                                            newprice = int.parse(value);
                                          });
                                        },
                                        decoration:
                                            KTextFieldImputDecoration.copyWith(
                                                hintText: 'Enter the Price'),
                                      )),
                                  MaterialButton(
                                    onPressed: () async {
                                      var posturl =
                                          'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/sub';
                                      var bodypost = jsonEncode({
                                        "fields": {
                                          "name": {"stringValue": newitem},
                                          "price": {"integerValue": newprice},
                                          "sub": {
                                            "stringValue": "$categorieValue"
                                          },
                                        }
                                      });
                                      await http.post(posturl, body: bodypost);
                                      getallItems();
                                      _textEditingController1.clear();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Send'),
                                  ),
                                ],
                              ),
                            ),
                          );
                          },
                        );
                      });
                },
              ),
              MaterialButton(
                child: Text('Reports'),
                onPressed: () {

                  Navigator.pushNamed(context, ReportScreen.id);

                }
              ),
              MaterialButton(
                child: Text('Add new Table'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Card(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    child: TextField(
                                      keyboardType: TextInputType.emailAddress,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        setState(() {
                                          numbOfTablle = value;
                                        });
                                      },
                                      decoration:
                                          KTextFieldImputDecoration.copyWith(
                                              hintText:
                                                  'Enter Number of Table'),
                                    )),
                                MaterialButton(
                                  onPressed: () async {
                                    var posturl =
                                        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/tables';
                                    var bodypost = jsonEncode({
                                      "fields": {
                                        "numb": {"stringValue": numbOfTablle},
                                        "iswaiting": {"booleanValue": false},
                                      }
                                    });
                                    await http.post(posturl, body: bodypost);
                                    getTableNumber();
                                    _textEditingController1.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Send'),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        )
      ],
    ));
  }
}

//var url = 'https://firestore.googleapis.com/v1/projects/phonestore-cf23e/databases/(default)/documents:runQuery';
//var list=[];
//var body = jsonEncode({
//  "structuredQuery": {
//    "from": [
//      {
//        "collectionId": "tele"
//      }
//    ],
//    "where": {
//      "fieldFilter": {
//        "field": {
//          "fieldPath": "subcat"
//        },
//        "op": "EQUAL",
//        "value": {
//          "stringValue": "Samsung"
//        }
//      }
//    }
//  },
//});
