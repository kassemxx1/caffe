import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
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
  var transactionList=[];

  void getalltransaction()async{
    var url =
        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/transaction';
    var response = await http.get(url);
    Map data = json.decode(response.body);
    print(data);
    transactionList.clear();
    for (var msg in data["documents"]) {
      final numb = msg["fields"]["billnum"]["stringValue"];
     final tablename=msg["fields"]["tablename"]["stringValue"];
      final total=msg["fields"]["total"]["doubleValue"];
      print(tablename);
      setState(() {
        transactionList.add({
         'billnum':numb,
          'tablename':tablename,
          'total':total,

        });
      });
    }
    print(transactionList);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getalltransaction();

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
                                      startDate = date;
                                    });

                                    print(startDate);
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
                  children: <Widget>[
                    Text('Daily',style: TextStyle(fontSize: 35*data.size.width/2000),),

                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Center(child: Text('kassem',style: TextStyle(fontSize: 45,color: Colors.black),)),

            color: Colors.red,
          )
        ],
      ),
    );
  }
}
