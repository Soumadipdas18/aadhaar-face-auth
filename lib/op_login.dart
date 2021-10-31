import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import 'meth.dart';
import 'optop.dart';

class opLogin extends StatefulWidget {
  const opLogin();

  @override
  _opLoginState createState() => _opLoginState();
}

class _opLoginState extends State<opLogin> {
  late Widget captchaimage=Container();
  late String op_aadhar;
  var uuid = Uuid();
  late String otpmessage;
  TextEditingController captchafield = new TextEditingController();
  bool isAsync = false;
  late String captchatxnid;
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(

        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 1.3,
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 13.6,
                child: TextField(
                  // maxLength: 12,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Open Sans',
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty)
                      return null;
                    else {
                      op_aadhar = value;
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        // color: Colors.redAccent,
                          width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        // color: Colors.redAccent,
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    filled: true,
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                    labelText: "Operator Aadhaar Number",
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF143B40),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: FractionalOffset.center,
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 3,
                height: 40,
                child: FlatButton(
                  onPressed: () async {
                    bool exists = true; //await checkIfDocExists(op_aadhar);
                    if (op_aadhar != null &&
                        op_aadhar.length == 12 &&
                        exists) {
                      Map<String, dynamic> responsebody = await getcaptcha();
                      //decoding response

                      setState(() {
                        print('No errors');
                        print(responsebody.toString());
                        var captchaBase64String =
                        responsebody["captchaBase64String"];
                        captchatxnid = responsebody["captchaTxnId"];
                        Uint8List bytes =
                        Base64Decoder().convert(captchaBase64String);
                        captchaimage = Image.memory(bytes);
                      });
                      setState(() {
                        isAsync = false;
                      });

                      // Navigator.pushNamed(context, 'opotp');
                    }
                  },
                  child: Text(
                    "Get Captcha",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery
                            .of(context)
                            .size
                            .width / 30,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30),
                Column(
                  children: [
                    captchaimage,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 1.3,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 13.6,
                      child: TextFormField(
                        controller: captchafield,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              // color: Colors.redAccent,
                                width: 1.0),
                            borderRadius:
                            BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              // color: Colors.redAccent,
                                width: 2.0),
                            borderRadius:
                            BorderRadius.all(Radius.circular(32.0)),
                          ),
                          filled: true,
                          labelStyle:
                          TextStyle(color: Colors.black, fontSize: 20),
                          labelText: "Enter Captcha",
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF143B40),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      alignment: FractionalOffset.center,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 3,
                      height: 40,
                      child: FlatButton(
                        onPressed: () async {
                          final uuidno = uuid.v4();
                          setState(() {
                            isAsync = true;
                          });
                          Map<String, dynamic> responsebody = await getotp(
                              uuidno,
                              op_aadhar,
                              captchafield.text,
                              captchatxnid);

                          print(responsebody);
                          setState(() {
                            otpmessage = responsebody["message"];
                          });
                          setState(() {
                            isAsync = false;
                          });
                          // if (errorcaptcha == false)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      opOTP(
                                        aadharno: op_aadhar,
                                        txnid: responsebody["txnId"],
                                      )),
                            );
                        },
                        child: Text(
                          "Verify Captcha",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width / 35,
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//TODO: Improve UI
//add error for wrong inputs(Less than 12 digits / wrong operator aadhar no.)
//Auth API integeation