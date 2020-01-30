import 'dart:convert';
import 'package:caffe/Main_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:database/database.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';





var now = new DateTime.now();
int day = now.day;
int year = now.year;
int month = now.month;
final database = MemoryDatabase();
List<trans> tableitems = [];
class TableScreen extends StatefulWidget {
  static const String id = 'Table_Screen';
  static var AllItems = [];
  static String TableName = '';
  static var ListOfCategories = [];
  static var ListOfSubCategories = [];
  static var indexx;
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {

  double heightofAppbar = 80.0;
  var total = 0.0;
  final pdf.Document doc = pdf.Document();
  bool _saving = false;
  var Listcat = [];
  var subcat = [
    {
      'cat': 'Juice',
      'name': 'Orange',
      'price': 4000,
    }
  ];
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
    Navigator.of(context).pop();

  }
  void getwaiting(String tablename) async {
    tableitems.clear();
    final response = await database.collection(TableScreen.TableName).search(
          query: Query.parse(
            "get:(yes)",
          ),
        );

    for (var msg in response.snapshots) {
      final name = msg.data['name'];
      final price = msg.data['price'];
      final qtt = msg.data['qtt'];
      print(name);
      setState(() {
        tableitems.add(trans(name, price, qtt, price));
      });
      msg.document.delete();
    }
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
      final price = i.totalprice * i.qtt;
      setState(() {
        qtts.add(price);
      });
    }
    var result = qtts.reduce((sum, element) => sum + element);
    setState(() {
      total = result;
    });
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
    super.initState();
    getwaiting(TableScreen.TableName);
//    getcat();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
            title: Text(TableScreen.TableName),
            automaticallyImplyLeading: false,
        backgroundColor: Colors.grey,
          ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[


              ///////////////////////items li a5adon
              Container(
                  width: data.size.width * 2 / 3.01,
                  height: (data.size.height - heightofAppbar) * 1.4 / 3,

                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: [
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
                      rows: tableitems
                          .map((trans) => DataRow(cells: [
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
                                    onChanged: (value) {
                                      // get the latest value from here
                                      setState(() {
                                        trans.qtt = value;
                                      });
                                    },
                                  ),
                                ),
                                DataCell(Text(
                                  '${trans.totalprice * trans.qtt}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataCell(IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                Text('Are You Sure to Delete?'),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              MaterialButton(
                                                  child: Text('Yes'),
                                                  onPressed: ()  {
                                                    for (var i in tableitems){
                                                      if (trans.description==i.description){
                                                        setState(() {
                                                          tableitems.remove(i);
                                                        });
                                                        Navigator.of(context).pop();
                                                      }
                                                    }

                                                  }),
                                            ],
                                          );
                                        });
                                  },
                                )),
                              ]))
                          .toList(),
                    ),
                  )
                  ),


              /////////////////////////////////////////////////////// totalllllll
              Container(
                  width: data.size.width * 2 / 3.01,
                  height: (data.size.height - heightofAppbar) * 0.2 / 3,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)
                  ),
                  child: FutureBuilder(
                    builder:
                        (BuildContext context, AsyncSnapshot<double> qttnumbr) {
                      return Center(
                        child: Text(
                          'Total : ${qttnumbr.data}',
                          style: TextStyle(color: Colors.black,fontSize: 25),
                        ),
                      );
                    },
                    initialData: 0.0,
                    future: sumtotal(),
                  )),

              //////////////items li mne5taron
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
                        onTap: () async {
                          setState(() {
                            tableitems.add(trans(
                                TableScreen.ListOfSubCategories[index]['name'],
                                double.parse(TableScreen
                                    .ListOfSubCategories[index]['price']),
                                1.0,
                                double.parse(TableScreen
                                    .ListOfSubCategories[index]['price'])));
                          });

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

              /////////////////////contnar l categori
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
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[


                          ///////////////waitin button
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              minWidth: data.size.width / 9.2,
                              color: Colors.blue,
                              onPressed: () async {
                                for (var msg in tableitems) {
                                  await database
                                      .collection(TableScreen.TableName)
                                      .insert(
                                    data: {
                                      'name': msg.description,
                                      'price': msg.Price,
                                      'qtt': msg.qtt,
                                      'get': 'yes',
                                    },
                                  );
                                }
                                MainScreen.ListOfTable[TableScreen.indexx]
                                    ['iswaiting'] = true;
                                tableitems.clear();
                                Navigator.of(context).pop();
                              },
                              child: Text('Waiting'),
                            ),
                          ),
                          /////// submut button
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              minWidth: data.size.width / 9.2,
                              color: Colors.blue,
                              onPressed: () async {
                                print(MainScreen.ListOfTable);
                                for (var i in MainScreen.ListOfTable) {
                                  if ('Table ${i['numb']}' ==
                                      TableScreen.TableName) {
                                    print(i['iswaiting']);
                                    setState(() {
                                      i['iswaiting'] = false;
                                    });
                                  }
                                }
                                print(MainScreen.ListOfTable);
                                var posturl =
                                    'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/transaction';
                                var postlist = [];
                                for (var i in tableitems) {
                                  setState(() {
                                    postlist.add({
                                      "mapValue": {
                                        "fields": {
                                          "qtt": {"doubleValue": "${i.qtt}"},
                                          "price": {"doubleValue": "${i.Price}"},
                                          "name": {
                                            "stringValue": "${i.description}"
                                          },
                                          "totalprice": {
                                            "doubleValue": "${i.qtt * i.Price}"
                                          }
                                        }
                                      }
                                    });
                                  });
                                }

                                var bodypost = jsonEncode({
                                  "fields": {
                                    "billnum": {"stringValue": "${MainScreen.alltrans.length + 1}"},
                                    "tablename": {"stringValue": "1"},
                                    "total": {"doubleValue": total},
                                    "items": {
                                      "arrayValue": {"values": postlist}
                                    }
                                  }
                                });
                                await http.post(posturl, body: bodypost);
                                getalltransaction();
                                 await  Printing.layoutPdf(onLayout: buildPdf);


                              },
                              child: Text('Submit'),
                            ),
                          ),

                        ],
                      ),
                      Row(crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //////////////waiting button
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              minWidth: data.size.width / 9.2,
                              color: Colors.blue,
                              onPressed: () async {
                                for (var i in MainScreen.ListOfTable) {
                                  setState(() {
                                    tableitems.clear();
                                  });
                                  if ('Table ${i['numb']}' ==
                                      TableScreen.TableName) {
                                    print(i['iswaiting']);
                                    setState(() {
                                      i['iswaiting'] = false;
                                    });
                                  }
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel Table'),
                            ),
                          ),
                          ////print button
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              minWidth: data.size.width / 9.2,
                              color: Colors.blue,
                              onPressed: () async {
                                Printing.layoutPdf(onLayout: buildPdf);


                              },
                              child: Text('Print'),
                            ),
                          )
                        ],
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
  trans(this.description, this.Price, this.qtt, this.totalprice);
}
List<int> buildPdf(PdfPageFormat format) {
  final pdf.Document doc = pdf.Document();

  doc.addPage(
    pdf.Page(
      pageFormat:PdfPageFormat(50* PDFPageFormat.MM,100.0 * PDFPageFormat.MM),
      build: (pdf.Context context) {
        return pdf.ConstrainedBox(
          constraints: const pdf.BoxConstraints.expand(),
          child: pdf.FittedBox(
            child:pdf.Center(
                child: pdf.Column(
              children: [
                pdf.Text('caffe'),
                pdf.Text('phone number'),
                pdf.Text('adress: Nabatieh '),
                pdf.SizedBox(
                    height:30
                ),
                  pdf.ListView.builder(itemBuilder: (context,index){
                    return pdf.Row(
                        children: [
                          pdf.Text(tableitems[index].description),
                          pdf.SizedBox(
                              width:10
                          ),
                          pdf.Text('${tableitems[index].Price}'),
                          pdf.SizedBox(
                              width: 10
                          ),
                          pdf.Text('${tableitems[index].qtt}'),
                          pdf.SizedBox(
                              width: 10
                          ),
                          pdf.Text('${tableitems[index].totalprice}'),
                        ]
                    );
                  },


                      itemCount: tableitems.length),



              ]
            ),


        ),

          ),
        );

      },

    ),
  );

  return doc.save();

}
