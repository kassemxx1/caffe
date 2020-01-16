import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class TableScreen extends StatefulWidget {
  static const String id = 'Table_Screen';
  static var AllItems = [];
  static String TableName = '';
  static var ListOfCategories = [];

  static var ListOfSubCategories = [];
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  double heightofAppbar = 80.0;
  bool _saving = false;
  var Listcat = [];
  var subcat = [
    {
      'cat': 'Juice',
      'name': 'Orange',
      'price': 4000,
    }
  ];

  void getsub(String cat) async {
    var url =
        'https://firestore.googleapis.com/v1/projects/caffe-38150/databases/(default)/documents:runQuery';
    var body = jsonEncode({
      "structuredQuery": {
        "from": [
          {"collectionId": "sub"}
        ],
        "where": {
          "fieldFilter": {
            "field": {"fieldPath": "sub"},
            "op": "EQUAL",
            "value": {"stringValue": cat}
          }
        }
      },
    });

    var response = await http.post(url, body: body);

    var data = json.decode(response.body);
    TableScreen.ListOfSubCategories.clear();
    try {
      for (var msg in data) {
        final name = msg['document']['fields']['name']["stringValue"];
        final price = msg['document']['fields']['price']["integerValue"];
        setState(() {
          TableScreen.ListOfSubCategories.add({
            'name': name,
            'price': price,
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }
  void adddocument()async{
    var posturl='https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/categories';
    var bodypost=jsonEncode({
      "fields": {
        "name": {
          "stringValue": "caffe"
        },
      }
    });
     await http.post(posturl, body: bodypost);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    getcat();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(heightofAppbar),
          child: AppBar(
            title: Text(TableScreen.TableName),
          )),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: data.size.width * 2 / 3.01,
                height: (data.size.height - heightofAppbar) / 2.1,
                color: Colors.blue,
              ),
              ModalProgressHUD(
                inAsyncCall: _saving,
                child: Container(
                  width: data.size.width * 2 / 3,
                  height: (data.size.height - heightofAppbar) / 2.1,
                  color: Colors.green,
                  child: ListView.builder(
                    itemBuilder: ((BuildContext, index) {
                      return GestureDetector(
                        child: ListTile(
                          enabled: true,
                          title: Row(
                            children: <Widget>[
                              Text(
                                  '${TableScreen.ListOfSubCategories[index]['name']}'),
                              Container(
                                width: 50,
                              ),
                              Text(
                                  '${TableScreen.ListOfSubCategories[index]['price']}L.L'),
                            ],
                          ),
                        ),
                        onTap: () {},
                      );
                    }),
                    itemCount: TableScreen.ListOfSubCategories.length,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: data.size.width / 3.01,
            child: ListView.builder(
              itemBuilder: ((BuildContext, index) {
                return GestureDetector(
                  child: ListTile(
                    title: Text('${TableScreen.AllItems[index]['name']}'),
                  ),
                  onTap: () {
                    TableScreen.ListOfSubCategories.clear();
                    getsub(TableScreen.AllItems[index]['name']);
                    adddocument();
                  },
                );
              }),
              itemCount: TableScreen.AllItems.length,
            ),
          ),
        ],
      ),
    );
  }
}
