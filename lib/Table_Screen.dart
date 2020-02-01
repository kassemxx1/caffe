import 'dart:convert';
import 'package:caffe/Main_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:database/database.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';
import 'package:random_color/random_color.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
var isPrinted = false;
var bill = 0;
var now = new DateTime.now();
int day = now.day;
int year = now.year;
int month = now.month;
final database = MemoryDatabase();
List<trans> tableitems = [];
var total = 0.0;

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
  RandomColor _randomColor = RandomColor();
  final pdf.Document doc = pdf.Document();
  bool _saving = false;
  var Listcat = [];
  void getalltransaction() async {
    var url =
        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/transaction';
    var response = await http.get(url);
    Map data = json.decode(response.body);
    MainScreen.alltrans.clear();
    for (var msg in data["documents"]) {
      final numb = msg["fields"]["billnum"]["stringValue"];
      final tablename = msg["fields"]["tablename"]["stringValue"];
      final total = msg["fields"]["total"]["doubleValue"].toDouble();
      final time = DateTime.parse(msg["createTime"]);
      final items = msg["fields"]["items"];

      setState(() {
        MainScreen.alltrans.add({
          'billnum': numb,
          'tablename': tablename,
          'total': total,
          'timestamp': time,
          'items': jsonEncode(items),
        });
      });
    }
//    MainScreen.alltrans.sort((a, b) {
//      return a['numb'].toLowerCase().compareTo(b['numb'].toLowerCase());
//    });
    Navigator.of(context).pop();
  }

  void ifPrinted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isPrinted =
          prefs.getBool('${TableScreen.TableName}') == null ? false : true;
    });
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
    ifPrinted();
    getwaiting(TableScreen.TableName);
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(TableScreen.TableName),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
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
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.brown)),
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
                                      if(isPrinted){
                                        Alert(context: context, title: "You  cannot Change", desc: "Printed Bill").show();
                                      }
                                      else{
                                        setState(() {
                                          trans.qtt = value;
                                        });
                                      }

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
                                                  onPressed: () {
                                                      if (isPrinted){
                                                        Alert(context: context, title: "You  cannot Delete", desc: "Printed Bill").show();
                                                    }
                                                      else{

                                                        for (var i
                                                        in tableitems) {
                                                          if (trans
                                                              .description ==
                                                              i.description) {
                                                            setState(() {
                                                              tableitems
                                                                  .remove(i);
                                                            });
                                                            Navigator.of(
                                                                context)
                                                                .pop();
                                                          }
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
                  )),

              /////////////////////////////////////////////////////// totalllllll
              Container(
                  width: data.size.width * 2 / 3.01,
                  height: (data.size.height - heightofAppbar) * 0.2 / 3,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.brown)),
                  child: FutureBuilder(
                    builder:
                        (BuildContext context, AsyncSnapshot<double> qttnumbr) {
                      return Center(
                        child: Text(
                          'Total : ${qttnumbr.data}',
                          style: TextStyle(color: Colors.black, fontSize: 25),
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
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.brown)),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Padding(
                                padding: EdgeInsets.all(5.0),
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tableitems.add(trans(
                                            TableScreen
                                                    .ListOfSubCategories[index]
                                                ['name'],
                                            double.parse(TableScreen
                                                    .ListOfSubCategories[index]
                                                ['price']),
                                            1.0,
                                            double.parse(TableScreen
                                                    .ListOfSubCategories[index]
                                                ['price'])));
                                      });
                                      sumtotal();
                                    },
                                    child: Card(
                                        elevation: 20.0,
                                        color: _randomColor.randomColor(
                                            colorHue: ColorHue.multiple(
                                                colorHues: [
                                              ColorHue.yellow,
                                              ColorHue.pink
                                            ])),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '${TableScreen.ListOfSubCategories[index]['name']}',
                                                style: TextStyle(
                                                    fontSize: MediaQuery.of(
                                                                context)
                                                            .textScaleFactor *
                                                        20,
                                                    color: Colors.brown[100]),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  '${TableScreen.ListOfSubCategories[index]['price']}L.L',
                                                  style: TextStyle(
                                                      fontSize: MediaQuery.of(
                                                                  context)
                                                              .textScaleFactor *
                                                          20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ))),
                              );
                            },
                            childCount: TableScreen.ListOfSubCategories.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            ///no.of items in the horizontal axis
                            crossAxisCount: (data.size.width / 250.0).round(),
                          ))
                    ],
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
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  TableScreen.ListOfSubCategories.clear();
                                  getsub(TableScreen.AllItems[index]['name']);
                                },
                                child: Card(
                                  color: _randomColor.randomColor(
                                      colorHue: ColorHue.multiple(colorHues: [
                                    ColorHue.red,
                                    ColorHue.blue
                                  ])),
                                  child: Center(
                                    child: Text(
                                      '${TableScreen.AllItems[index]['name']}',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .textScaleFactor *
                                              20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: TableScreen.AllItems.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          ///no.of items in the horizontal axis
                          crossAxisCount: (data.size.width / 600.0).round(),
                        ),
                      )
                    ],
                  )),

              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  width: data.size.width / 3.2,
                  height: data.size.height / 4,
                  child: ListView(
                    children: <Widget>[
                      ///////////////waitin button
                      Padding(
                        padding: const EdgeInsets.all(2.0),
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
                          child: Text(
                            'Waiting',
                            style: TextStyle(color: Colors.brown[100]),
                          ),
                        ),
                      ),
                      /////// submut button
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: MaterialButton(
                          minWidth: data.size.width / 9.2,
                          color: Colors.blue,
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            setState(() {
                              bill = (prefs.getInt('bill') ?? 0) + 1;
                            });
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
                                "billnum": {"stringValue": "$bill"},
                                "tablename": {
                                  "stringValue": "${TableScreen.TableName}"
                                },
                                "total": {"doubleValue": total},
                                "items": {
                                  "arrayValue": {"values": postlist}
                                }
                              }
                            });
                            await http.post(posturl, body: bodypost);
                            getalltransaction();
                            prefs.remove('${TableScreen.TableName}');
                            await Printing.layoutPdf(onLayout: buildPdf);
                            prefs.setInt('bill', bill);
                          },
                          child: Text('Submit',
                              style: TextStyle(color: Colors.brown[100])),
                        ),
                      ),

                      //////////////waiting button
                      Padding(
                        padding: const EdgeInsets.all(2.0),
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
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            prefs.remove('${TableScreen.TableName}');
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel Table',
                              style: TextStyle(color: Colors.brown[100])),
                        ),
                      ),
                      ////print button
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: MaterialButton(
                          minWidth: data.size.width / 9.2,
                          color: Colors.blue,
                          onPressed: () async {
                            setState(() {
                              isPrinted=true;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('${TableScreen.TableName}', true);

                            Printing.layoutPdf(onLayout: buildPdf);
                          },
                          child: Text('Print',
                              style: TextStyle(color: Colors.brown[100])),
                        ),
                      )
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
      pageFormat:
          PdfPageFormat(40 * PDFPageFormat.MM, 100.0 * PDFPageFormat.MM),
      build: (pdf.Context context) {
        return pdf.ConstrainedBox(
          constraints: const pdf.BoxConstraints.expand(),
          child: pdf.FittedBox(
            child: pdf.Center(
              child: pdf.Column(children: [
                pdf.Text('Sparrow Caffe',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.Text('phone : 03854666',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.Text('adress: Nabatieh ',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.Text('Merjeoun Street ',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.SizedBox(height: 20),
                pdf.Text("$bill",
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.Text('----------------------------------------',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.FittedBox(
                  child: pdf.ListView.builder(
                      itemBuilder: (context, index) {
                        return pdf.Row(children: [
                          pdf.Text(tableitems[index].description),
                          pdf.SizedBox(width: 10),
                          pdf.Text('${tableitems[index].Price}'),
                          pdf.SizedBox(width: 10),
                          pdf.Text('${tableitems[index].qtt}'),
                          pdf.SizedBox(width: 10),
                          pdf.Text(
                              '${tableitems[index].Price * tableitems[index].qtt}'),
                        ]);
                      },
                      itemCount: tableitems.length),
                ),
                pdf.Text('----------------------------------------',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.Row(children: [
                  pdf.Text('Total',
                      style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                  pdf.SizedBox(width: 10),
                  pdf.Text('$total',
                      style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                ]),
                pdf.Text('Thank You',
                    style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                pdf.SizedBox(height: 50),
              ]),
            ),
          ),
        );
      },
    ),
  );

  return doc.save();
}
