import 'dart:convert';

import 'package:database/database.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'Main_Screen.dart';


var now = new DateTime.now();
int day = now.day;
int year = now.year;
int month = now.month;
class ReportScreen extends StatefulWidget {
  static const String id = 'Report_Screen';

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  var tomorow = new DateTime(year, month, day, 23, 59, 59, 99, 99);
  var startDate = DateTime(year, month, day, 0, 0, 0, 0, 0);
  var endDate = new DateTime(year, month, day, 23, 59, 59, 99, 99);
  var DayTransaction=[];
  var transactiondate=[];
  Map<String,dynamic> items;
  bool sort;

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        transactiondate.sort((a, b) => a.time.compareTo(a.time));
      } else {
        transactiondate.sort((a, b) => b.time.compareTo(a.time));
      }
    }
  }
  void getItems(String numb){

    for(var msg in MainScreen.alltrans){
      if(msg['billnum']==numb){
        setState(() {
          items = jsonDecode(msg['items']);
        });
        print(items);
      }

    }
  }
  void gettransationdate(DateTime startDate ,DateTime endDate){
    transactiondate.clear();
    for (var msg in MainScreen.alltrans)  {
            final numb = msg["billnum"];
            final tablename=msg["tablename"];
            final total=msg["total"];
            final time = msg["timestamp"];
            var timenow=new DateTime(time.year,time.month,time.day,time.hour + 2 ,time.minute,time.second);
            if (timenow.isAfter(startDate) && timenow.isBefore(endDate) ){
              setState(()  {
                transactiondate.add(
                  transDate(timenow, numb, tablename, total)
                );
              });

            }
    }


  }
  Future<double> getalltransactiondate(DateTime startDate ,DateTime endDate) {
    var qtts = [0.0];

    for (var msg in MainScreen.alltrans) {
//      final numb = msg["fields"]["billnum"]["stringValue"];
//      final tablename=msg["fields"]["tablename"]["stringValue"];

      final total=msg["total"];
      final time = msg["timestamp"];
      var timenow=new DateTime(time.year,time.month,time.day,time.hour + 2 ,time.minute,time.second);
      if (timenow.isAfter(startDate) && timenow.isBefore(endDate) ){
        setState(() {
          qtts.add(total);
        });
      }
    }
    var result = qtts.reduce((sum, element) => sum + element);

    return new Future(() => result);
  }
  @override
  void initState() {
    super.initState();
    sort = false;
    gettransationdate(startDate, tomorow);
  }
  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Report'),),
      body: Column(
        children: <Widget>[
          Container(
            height: data.size.height/3,
            color: Colors.green,

            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('start Date:',style: TextStyle(fontSize: 35*data.size.width/2000,color: Colors.black),),
                        FlatButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2019, 1, 1),
                                  maxTime: DateTime(2025, 6, 7),
                                  onChanged: (date) {}, onConfirm: (date) {
                                    setState(() {
                                      startDate = new DateTime(date.year,date.month,date.day,0,0,0);
                                    });
                                    print(startDate);
                                    gettransationdate(startDate, endDate);
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Text(
                              '${formatDate(startDate, [
                                yyyy,
                                '-',
                                mm,
                                '-',
                                dd
                              ])}',
                              style: TextStyle(color: Colors.blue,fontSize:35*data.size.width/1920.0),
                            )),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('End Date:',style: TextStyle(fontSize: 35*data.size.width/1920.0,color: Colors.black)),
                        FlatButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2019, 1, 1),
                                  maxTime: DateTime(2025, 6, 7),
                                  onChanged: (date) {}, onConfirm: (date) {
                                    setState(() {
                                      endDate = date.add(new Duration(
                                          hours: 23, minutes: 59, seconds: 59));
                                    });
                                    gettransationdate(startDate, endDate);
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Text(
                              '${formatDate(endDate, [
                                yyyy,
                                '-',
                                mm,
                                '-',
                                dd
                              ])}',
                              style: TextStyle(color: Colors.blue,fontSize: 35*data.size.width/1920.0),
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Daily',style: TextStyle(fontSize: 35*data.size.width/2000,fontWeight: FontWeight.bold,),),
                    FutureBuilder(
                        builder:
                            (BuildContext context, AsyncSnapshot<double> qttnumbr) {
                          return Center(
                            child: Text(
                              'Tolal  : ${qttnumbr.data} L.L',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35*data.size.width/2000),
                            ),
                          );
                        },
                        initialData: 1.0,
                        future:getalltransactiondate(startDate, tomorow)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Between Date',style: TextStyle(fontSize: 35*data.size.width/2000,fontWeight: FontWeight.bold,),),
                    FutureBuilder(
                        builder:
                            (BuildContext context, AsyncSnapshot<double> qttnumbr) {
                          return Center(
                            child: Text(
                              'Tolal  : ${qttnumbr.data} L.L',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35*data.size.width/2000),
                            ),
                          );
                        },
                        initialData: 1.0,
                        future:getalltransactiondate(startDate, endDate)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: data.size.height *1.5 /3,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                sortColumnIndex: 0,
                sortAscending: sort,
                columns: [
                  DataColumn(
                    label: Text(
                      'Date',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        sort = !sort;
                      });

                      onSortColum(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'BillNumb',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'TableNumb',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),

                  ),
                  DataColumn(
                    label: Text(
                      'Total',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                ],
                rows: transactiondate.map((transDate)=>
                    DataRow(cells:[
                      DataCell(Text(
                        '${formatDate(transDate.time, [
                          yyyy,
                          '-',
                          mm,
                          '-',
                          dd,
                          '   ',
                          hh,
                          ':',
                          nn
                        ])}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(MaterialButton(
                        child: Text(
                          '${transDate.numb}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: (){
                          getItems(transDate.numb);
                          showDialog(context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              content: Card(
                                child: Column(
                                  children: <Widget>[


                                  ],
                                ),
                              ),
                            );
                          }
                          );
                        },
                      )),
                      DataCell(Text(
                        '${transDate.tablename}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        '${transDate.total}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),

                    ]
                    )

                ).toList(),
              ),


            ),

          )
        ],
      ),
    );
  }
}
class transDate {
  DateTime time;
  String numb;
  String tablename;
  double total;
  transDate(this.time, this.numb, this.tablename, this.total);
}
