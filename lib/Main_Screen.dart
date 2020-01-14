import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Table_Screen.dart';
class MainScreen extends StatefulWidget {
  static const String id = 'Main_Screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void getallItems()async{
    TableScreen.AllItems.clear();
    var url1 = 'https://firestore.googleapis.com/v1/projects/caffe-38150/databases/(default)/documents/categories';
    var response = await http.get(url1);

    Map  data = json.decode(response.body);
    print(data);
    for (var msg in data['documents']) {
      final name =msg['fields']['name']["stringValue"];

      setState(() {
        TableScreen.AllItems.add({
          'name':name,
        });
      });

    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getallItems();
  }
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.Desktop) {
        return DesktopWidget();
      }
      return DesktopWidget();
    });
  }
}

class DesktopWidget extends StatelessWidget {
  var ListOfTable=['1','2','3','4','5','6','7','8','9','10'];



  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    print(data.size.width);
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
                          TableScreen.TableName='Table ${ListOfTable[index]}';
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
                            child: Center(child: Text('Table ${ListOfTable[index]}',style: TextStyle(fontSize: 40),)),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: ListOfTable.length,
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