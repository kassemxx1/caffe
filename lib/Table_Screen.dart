import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:http/http.dart' as http;
class TableScreen extends StatefulWidget {
  static const String id = 'Table_Screen';
  static var AllItems=[];
  static String TableName = '';
  static var ListOfCategories=[];

  static var ListOfSubCategories=[];
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  double heightofAppbar=80.0;
var Listcat=[];
void getcat(){
  Listcat.clear();
  for (var i in TableScreen.AllItems){
    final name = i['name'];
    print(name);
    setState(() {
      Listcat.add(name);
    });

  }
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(TableScreen.AllItems);
//    getcat();

  }
  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.deviceScreenType == DeviceScreenType.Desktop) {
        return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(heightofAppbar),
              child: AppBar(title: Text(TableScreen.TableName),)),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: data.size.width*2 / 3.01,
                    height: (data.size.height-heightofAppbar)/2.1,

                    color: Colors.blue,
                  ),
                  Container(
                    width: data.size.width*2 / 3.01,
                    height: (data.size.height-heightofAppbar)/2.1,
                    color: Colors.green,
                    child:ListView.builder(

                      itemBuilder: ((BuildContext,index){
                        return GestureDetector(
                          child: ListTile(
                            title:Text('${TableScreen.AllItems[index]['name']}') ,
                          ),
                          onTap: (){


                          },
                        );

                      }),

                      itemCount: TableScreen.ListOfCategories.length,),
                  ),
                ],
              ),
              Container(
                width: data.size.width / 3.01,
                child: ListView.builder(

                  itemBuilder: ((BuildContext,index){
                    return GestureDetector(
                      child: ListTile(
                        title:Text('${TableScreen.AllItems[index]['name']}') ,
                      ),
                      onTap: (){


                      },
                    );

                  }),

                  itemCount: TableScreen.ListOfCategories.length,),
              ),
            ],
          ),
        );
      }
      return Container(

      );
    });
  }
}




