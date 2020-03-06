import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'Main_Screen.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
class LoginScreen extends StatefulWidget {
  static const String id = 'Login_Screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var listPassword=[];
  var password='';
  void getallPass()async{
    var url =
        'https://firestore.googleapis.com/v1beta1/projects/caffe-38150/databases/(default)/documents/passwords';
    var response = await http.get(url);
    Map data = json.decode(response.body);
    listPassword.clear();
    for (var msg in data["documents"]) {
      final pass = msg["fields"]["password"]["stringValue"];
      final isAdmin= msg["fields"]["admin"]["booleanValue"];

      setState(() {
        listPassword.add({
          'password':pass,
          'isAdmin':isAdmin,

        });
      });


    }

  }
  TextEditingController _textEditingController1 = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getallPass();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context ,constraints){
          if(constraints.maxWidth > 600){
            return new Container(
//          decoration: BoxDecoration(
//              image: DecorationImage(
//                  image: AssetImage("assets/images/pirate.jpg"), fit: BoxFit.fill)),

                child: Center(

                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Welcome To Sparrow Caffe',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,

                                  ),
                                ),
                                Text(
                                  'Enter Your Password',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,

                                  ),
                                ),
                                TextField(
                                  controller: _textEditingController1,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    setState(() {
                                      password=value;

                                    });
                                  },
                                  obscureText: true,
                                  decoration:
                                  KTextFieldImputDecoration.copyWith(
                                      hintText:
                                      'Enter Your Password'),
                                ),
                                Center(
                                    child:MaterialButton(
                                      color: Colors.blue,
                                      onPressed: (){
                                        for(var pass in listPassword){
                                          if (password==pass['password']){
                                            MainScreen.isAmmin=pass['isAdmin'];


                                            Navigator.pushNamed(context,MainScreen.id);
                                          }
                                        }
                                      },
                                      child: Text('Login'),
                                    )
                                ),


                              ],
                            ),
                          ),
                        ),


                )
            );
          }
          else{
            return  Container(
              child: Center(
                  child: Card(
                    color: Colors.white.withOpacity(.5),
                    elevation: 40,
                    borderOnForeground: true,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Welcome To Sparrow Caffe',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,

                              ),
                            ),
                            Text(
                              'Enter Your Password',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,

                              ),
                            ),
                            TextField(
                              controller: _textEditingController1,
                              keyboardType: TextInputType.emailAddress,
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                setState(() {
                                  password=value;

                                });
                              },
                              obscureText: true,
                              decoration:
                              KTextFieldImputDecoration.copyWith(
                                  hintText:
                                  'Enter Your Password'),
                            ),
                            Center(
                                child:MaterialButton(
                                  color: Colors.blue,
                                  onPressed: (){
                                    for(var pass in listPassword){
                                      if (password==pass['password']){
                                        Navigator.pushNamed(context,MainScreen.id);
                                      }
                                    }
                                  },
                                  child: Text('Login'),
                                )
                            ),


                          ],
                        ),
                      ),
                    ),
                  ),

              ),
            );
          }
        },
      )
    );
  }
}
