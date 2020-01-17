import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:database/database.dart';
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
  List<trans> tableitems = [];
  double heightofAppbar = 80.0;
  final database = MemoryDatabase();
  bool _saving = false;
  var Listcat = [];
  var subcat = [
    {
      'cat': 'Juice',
      'name': 'Orange',
      'price': 4000,
    }
  ];
void getwaiting(String tablename)async{

}
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

  Future<double> sumtotal() async {
    var qtts = [0.0];
    for (var i in tableitems) {
      final price = i.totalprice*i.qtt;
      setState(() {
        qtts.add(price);
      });
    }
    var result = qtts.reduce((sum, element) => sum + element);
    return new Future(() => result);
  }

  void adddocument() async {
    var posturl =
        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/categories';
    var bodypost = jsonEncode({
      "fields": {
        "name": {"stringValue": "caffe"},
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
                  height: (data.size.height - heightofAppbar) * 1.4 / 3,
                  color: Colors.blue,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(columns: [
                      DataColumn(
                        label: Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                          label: Text(
                        'Price',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'Qtt',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        'total',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                            '#',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          )),
                    ],
                      rows: tableitems.map((trans) =>DataRow(
                          cells: [
                            DataCell(Text(
                              '${trans.description}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              '${trans.Price}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(
                              Counter(
                                initialValue: trans.qtt,
                                minValue: 1.0,
                                maxValue: 100.0,
                                step: 1.0,
                                decimalPlaces: 0,
                                onChanged: (value) { // get the latest value from here
                                  setState(() {
                                    trans.qtt = value;
                                  });
                                },
                              ),
                            ),
                            DataCell(Text(
                              '${trans.totalprice*trans.qtt}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(
                                IconButton(icon: Icon(Icons.delete,color: Colors.red,),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Are You Sure to Delete?'),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              MaterialButton(
                                                  child: Text('Yes'),
                                                  onPressed: () async {

                                                  }),
                                            ],
                                          );
                                        });
                                  },
                                )),





                          ]
                      )).toList(),






                    ),
                  )

//                ListView.builder(
//                  itemBuilder: ((BuildContext, index) {
//                    return GestureDetector(
//                      child: ListTile(
//                        enabled: true,
//                        title: Row(
//                          children: <Widget>[
//                            Text(
//                                '${index+1}'),
//                            Text(
//                                '${tableitems[index]['name']}'),
//                            Container(
//                              width: 50,
//                            ),
//                            Text(
//                                '${tableitems[index]['price']}L.L'),
//                          ],
//                        ),
//                      ),
//                      onTap: () {
//                      },
//                    );
//                  }),
//                  itemCount: tableitems.length,
//                ),
                  ),
              Container(
                  width: data.size.width * 2 / 3.01,
                  height: (data.size.height - heightofAppbar) * 0.2 / 3,
                  child: FutureBuilder(
                    builder:
                        (BuildContext context, AsyncSnapshot<double> qttnumbr) {
                      return Center(
                        child: Text(
                          'Total : ${qttnumbr.data}',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    },
                    initialData: 0.0,
                    future: sumtotal(),
                  )),
              ModalProgressHUD(
                inAsyncCall: _saving,
                child: Container(
                  width: data.size.width * 2 / 3,
                  height: (data.size.height - heightofAppbar) * 1.4 / 3,
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
                        onTap: () async{
                          setState(() {
                            tableitems.add(trans(TableScreen.ListOfSubCategories[index]['name'],
                                double.parse(TableScreen.ListOfSubCategories[index]['price']),
                                1.0,
                                double.parse(TableScreen.ListOfSubCategories[index]['price'])));


                          });


                          await database.collection(TableScreen.TableName).insert(
                              data: {
                                'name':TableScreen.ListOfSubCategories[index]['name'],
                                'price':TableScreen.ListOfSubCategories[index]['price'],
                                'qtt':1.0,


                              }

                          );
//                          setState(() {
//                            var count = tableitems.length;
//                            tableitems.add({
//                              'name': TableScreen.ListOfSubCategories[index]['name'],
//                              'price': double.parse(TableScreen.ListOfSubCategories[index]['price']),
//                            });
//                          });
                          sumtotal();
                        },
                      );
                    }),
                    itemCount: TableScreen.ListOfSubCategories.length,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                width: data.size.width / 3.2,
                height: data.size.height * 2 / 3.5,
                child: ListView.builder(
                  itemBuilder: ((BuildContext, index) {
                    return GestureDetector(
                      child: ListTile(
                        title: Text('${TableScreen.AllItems[index]['name']}'),
                      ),
                      onTap: () {
                        TableScreen.ListOfSubCategories.clear();
                        getsub(TableScreen.AllItems[index]['name']);
                      },
                    );
                  }),
                  itemCount: TableScreen.AllItems.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: Colors.yellow,
                  width: data.size.width / 3.2,
                  height: data.size.height / 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: MaterialButton(
                          minWidth: data.size.width / 9.2,
                          color: Colors.blue,
                          onPressed: () {},
                          child: Text('Waiting'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: MaterialButton(
                          minWidth: data.size.width / 9.2,
                          color: Colors.blue,
                          onPressed: () {},
                          child: Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class trans {
  String description;
  double Price;
  double qtt;
  double totalprice;
  trans(this.description,this.Price, this.qtt, this.totalprice);
}