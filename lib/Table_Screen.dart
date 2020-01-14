import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;

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

  var Listcat = [];
  var subcat = [
    {
      'cat': 'Juice',
      'name': 'Orange',
      'price': 4000,
    }
  ];
  void savesubcat() async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setString('subcat', json.encode(subcat));
  }

  void getsharedcat() async {
    var preferences = await SharedPreferences.getInstance();
    setState(() {
      Listcat = json.decode(preferences.getString('listcat'));
      print(Listcat[0]['name']);
    });
  }

  void getsharedsubcat(String cat) async {
    var list = [];
    TableScreen.ListOfSubCategories.clear();
    var preferences = await SharedPreferences.getInstance();
    list = json.decode(preferences.getString('subcat'));
    TableScreen.ListOfSubCategories.clear();
    for (var i in list) {
      if (i['cat'] == cat) {
        setState(() {
          TableScreen.ListOfSubCategories.add(
              {'name': i['name'], 'price': i['price']});
        });
      }
    }
    print(TableScreen.ListOfSubCategories);

  }

//void getcat(){
//  Listcat.clear();
//  for (var i in TableScreen.AllItems){
//    final name = i['name'];
//    print(name);
//    setState(() {
//      Listcat.add(name);
//    });
//
//  }
//}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(TableScreen.AllItems);
//    getcat();
    getsharedcat();
    savesubcat();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.Tablet) {
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
                  Container(
                    width: data.size.width * 2 / 3.01,
                    height: (data.size.height - heightofAppbar) / 2.1,
                    color: Colors.green,
                    child: ListView.builder(
                      itemBuilder: ((BuildContext, index) {
                        return GestureDetector(
                          child: ListTile(
                            enabled: true,
                            title: Text(
                                '${TableScreen.ListOfSubCategories[index]['name']}'),
                            leading: Text(
                                '${TableScreen.ListOfSubCategories[index]['price']}'),
                          ),
                          onTap: () {},
                        );
                      }),
                      itemCount: TableScreen.ListOfSubCategories.length,
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
                        title: Text('${Listcat[index]['name']}'),
                      ),
                      onTap: () {
                        getsharedsubcat('${Listcat[index]['name']}');
                      },
                    );
                  }),
                  itemCount: Listcat.length,
                ),
              ),
            ],
          ),
        );
      }
      return Scaffold(
        body: Container(
          color: Colors.white,
        ),
      );
    });
  }
}
