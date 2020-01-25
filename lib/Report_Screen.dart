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
  var DayTransaction=[];

  void getalltransaction()async{
    var url =
        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/transaction';
    var response = await http.get(url);
    Map data = json.decode(response.body);
    transactionList.clear();
    for (var msg in data["documents"]) {
      final numb = msg["fields"]["billnum"]["stringValue"];
     final tablename=msg["fields"]["tablename"]["stringValue"];
      final total=msg["fields"]["total"]["doubleValue"];
      final time = msg["createTime"];

      setState(() {
        transactionList.add({
         'billnum':numb,
          'tablename':tablename,
          'total':total,
          'timestamp':time,

        });
      });
      print(transactionList);
    }
  }
  Future<double> getalltransactiondate(DateTime startDate ,DateTime endDate)async{
    var qtts = [0.0];
    print(transactionList.length);
    for (var msg in transactionList) {
//      final numb = msg["fields"]["billnum"]["stringValue"];
//      final tablename=msg["fields"]["tablename"]["stringValue"];
      final total=msg["total"].todouble();
      final time = msg["timestamp"];
      print(time);
      print(total);
//      if (time.isAfter(startDate) && time.isBefore(endDate) ){
//        setState(() {
//          qtts.add(total);
//        });
//      }
    }

    var result = qtts.reduce((sum, element) => sum + element);
    print(result);
    return new Future(() => result);
  }
  @override
  void initState() {
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
                    FutureBuilder(
                        builder:
                            (BuildContext context, AsyncSnapshot<double> qttnumbr) {
                          return Center(
                            child: Text(
                              'Tolal  : ${qttnumbr.data} L.L',
                              style: TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
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
            child: Center(child: Text('kassem',style: TextStyle(fontSize: 45,color: Colors.black),)),

            color: Colors.red,
          )
        ],
      ),
    );
  }
}
