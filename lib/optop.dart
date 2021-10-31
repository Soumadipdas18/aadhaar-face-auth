
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:xml/xml.dart';

import 'meth.dart';

class opOTP extends StatefulWidget {
  const opOTP({required this.txnid, required this.aadharno});

  final String txnid, aadharno;

  @override
  _opOTPState createState() => _opOTPState();
}

class _opOTPState extends State<opOTP> {
  static const platform = const MethodChannel('going.native.for.userdata');
String xmldata='';
  late String otp;
  bool error = false;
  bool isAsync = false;

  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(50),
                child: OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sans'),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: MediaQuery.of(context).size.width / 10,
                  fieldStyle: FieldStyle.underline,
                  onCompleted: (pin) {
                    otp = pin;
                    print("Completed: " + pin);
                  },
                  otpFieldStyle: OtpFieldStyle(
                      borderColor: Colors.grey, focusBorderColor: Colors.black),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF143B40),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: FractionalOffset.center,
                width: MediaQuery.of(context).size.width / 3.0,
                height: 40,
                child: FlatButton(
                  onPressed: () async {
                    if (otp.isNotEmpty) {
                      setState(() {
                        error = false;
                        isAsync = true;
                      });
                      Map<String,dynamic> response = await getKYC(widget.aadharno, otp, widget.txnid);
                      final builder = XmlBuilder();
                            builder.element('statelessMatchRequest', nest: () {
                            builder.attribute('language', 'en');
                            // builder.attribute('documentType', 'AADHAR');
                            builder.attribute('signedDocument', response["eKycString"]);
                            builder.attribute('requestId', '850b962e041c11e192340123456789ab');
                          });

                      //final bookshelfXml = '''<statelessMatchRequest enableAutoCapture="true" language="en" requestId="4484" signedDocument="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?>&lt;KycRes code=&quot;c7ad5748c5f74b4e8100ef7474e278d8&quot; ret=&quot;Y&quot; ts=&quot;2021-10-30T20:45:04.997+05:30&quot; ttl=&quot;2022-10-30T20:45:04&quot; txn=&quot;UKC:65edb08e-cd8d-45f5-bd37-4fb97e7a3633&quot;>&lt;Rar>PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48QXV0aFJlcyBjb2RlPSJjN2FkNTc0OGM1Zjc0YjRlODEwMGVmNzQ3NGUyNzhkOCIgaW5mbz0iMDR7MDEwMDAwNjg2RXhUdkFvZFA2aHBtdG5WT1NmMmJ6Zm5lNi9jek9xcjYwZmViM0VxakFNNG1WWitReHZqU1JoTU9tWlhrNnh2LEEsZTNiMGM0NDI5OGZjMWMxNDlhZmJmNGM4OTk2ZmI5MjQyN2FlNDFlNDY0OWI5MzRjYTQ5NTk5MWI3ODUyYjg1NSwwMTAwMDAwNDAwMDAwMDExLDIuMCwyMDIxMTAzMDIwNDUwMSwwLDAsMCwxLDIuNSwyMGVmMGYwYzhkMGVlYTk4NzcyNDEyY2VhOWIzYjkyNjEyZTNlNTNjYjVlNTkxNTJiNTcwMzE2NWY1NmU4YTUzLGVmYTFmMzc1ZDc2MTk0ZmE1MWEzNTU2YTk3ZTY0MWU2MTY4NWY5MTRkNDQ2OTc5ZGE1MGE1NTFhNDMzM2ZmZDcsZWZhMWYzNzVkNzYxOTRmYTUxYTM1NTZhOTdlNjQxZTYxNjg1ZjkxNGQ0NDY5NzlkYTUwYTU1MWE0MzMzZmZkNyxOQSxOQSxOQSxOQSxOQSxOQSxOQSxOQSxOQSxOQSxyZWdpc3RlcmVkLFJEU0lELDIuMF9RQSxxYV9tYW51ZmFjdHVyZXIsUE9DTUksTDAsc2d5ZElDMDl6enk2ZjhMYjN4YUFxektxdUtlOWxGY05SOXVUdll4RnArQT19IiByZXQ9InkiIHRzPSIyMDIxLTEwLTMwVDIwOjQ1OjA0Ljg4MCswNTozMCIgdHhuPSJVS0M6NjVlZGIwOGUtY2Q4ZC00NWY1LWJkMzctNGZiOTdlN2EzNjMzIj48U2lnbmF0dXJlIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj48U2lnbmVkSW5mbz48Q2Fub25pY2FsaXphdGlvbk1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnL1RSLzIwMDEvUkVDLXhtbC1jMTRuLTIwMDEwMzE1Ii8+PFNpZ25hdHVyZU1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyNyc2Etc2hhMSIvPjxSZWZlcmVuY2UgVVJJPSIiPjxUcmFuc2Zvcm1zPjxUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjZW52ZWxvcGVkLXNpZ25hdHVyZSIvPjwvVHJhbnNmb3Jtcz48RGlnZXN0TWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS8wNC94bWxlbmMjc2hhMjU2Ii8+PERpZ2VzdFZhbHVlPkc4QVBBc1lKK1V3aUh0TFlkU0MyTDVsZ0lhRDlyUkNoZGtXVGdkQ0krVVU9PC9EaWdlc3RWYWx1ZT48L1JlZmVyZW5jZT48L1NpZ25lZEluZm8+PFNpZ25hdHVyZVZhbHVlPmp3RE5IdHhMcnQ2dzBQSVRpeW4wQkZBbG9nanlSMUZ3WTFqRmtLVTQzRnBhT2JMV1BZSFZRSUNCenc1bGdNTWt6dUR5MVJ5OXVWRXEKMmwyOXY3ak13ZktYalo4QmVqNStLM2JiSlZjL1FYdXlodjZpVUFVaWFkRFVhaHQzbVNPUTBkaWh6WTYzNG4ya2ZmcnF5aHU4d3JiegpqVnVnYStRRmlJVGc4aG92VnVIWUwvSWlieXVHSTgwOTFNMUZPSndBbTV6SFRXRVlPUE5pOVVYK3d4U0ZKOVNwRmo3MDhOb0VzQ0w3CjBGN0sxWTZuTnU3bkNYUHc4cHZIZnBUVUlzeVZ1SmlyZnNDR253aGIzUEpDNm5xQnoyVXROLzFveVpLc3VUVWJjY1hrci81cG1UaTQKSi9KVnJxNHZjLzZRVkVwVjVsbmlUS2E1dzNyb0FVdmdLVWFrR1E9PTwvU2lnbmF0dXJlVmFsdWU+PC9TaWduYXR1cmU+PC9BdXRoUmVzPg==&lt;/Rar>&lt;UidData tkn=&quot;010000686ExTvAodP6hpmtnVOSf2bzfne6/czOqr60feb3EqjAM4mVZ+QxvjSRhMOmZXk6xv&quot; uid=&quot;999969115945&quot;>&lt;Poi dob=&quot;17-02-1997&quot; gender=&quot;M&quot; name=&quot;Sameer Raj Wankar&quot; phone=&quot;9685984424&quot;/>&lt;Poa co=&quot;S/O: Ashok Wankar&quot; country=&quot;India&quot; dist=&quot;Katni&quot; house=&quot;34&quot; lm=&quot;mahatma gandhi ward&quot; loc=&quot;vijayraghavgarh&quot; pc=&quot;483775&quot; state=&quot;Madhya Pradesh&quot; street=&quot;ward no 7&quot; vtc=&quot;Vijayraghavgarh&quot;/>&lt;LData/>&lt;Pht>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&lt;/Pht>&lt;/UidData>&lt;Signature xmlns=&quot;http://www.w3.org/2000/09/xmldsig#&quot;>&lt;SignedInfo>&lt;CanonicalizationMethod Algorithm=&quot;http://www.w3.org/TR/2001/REC-xml-c14n-20010315&quot;/>&lt;SignatureMethod Algorithm=&quot;http://www.w3.org/2000/09/xmldsig#rsa-sha1&quot;/>&lt;Reference URI=&quot;&quot;>&lt;Transforms>&lt;Transform Algorithm=&quot;http://www.w3.org/2000/09/xmldsig#enveloped-signature&quot;/>&lt;/Transforms>&lt;DigestMethod Algorithm=&quot;http://www.w3.org/2001/04/xmlenc#sha256&quot;/>&lt;DigestValue>dliZGtVLIyIWViRcnh/cA3blToV7KjYCzGPagbpQ1u0=&lt;/DigestValue>&lt;/Reference>&lt;/SignedInfo>&lt;SignatureValue>GykCJFU3bvT3uTYiWEuzGqabEwfUMy9HQKoOmYMyGqliYf1kH2vRBdd1rFw1LWbyyNSDIYeNIjzlJ10PusywUbqaTaLdHfFAnfm2LPkmwnm//F2P3O3oAMfFN/hEdshkW5+NkRctlsINCGtbePAWxhW0PmaI3pvFmK3PSF462QB348vQEsP6zTGprNYBisVCQHUbBXH9VeYqRqMvUHFN7nEZl4ZvicQjzPv3YZ2f0EKF1Gk6tz8pFbS5G3+oTkny4HU0KVd/EHm2aBBsE80r/EU2yV92suGc9Jvejj0RvBiv6zFc1vBaC1Zf3aJzmUjqEFILEJL7jWqgLqM+WvOoVQ==&lt;/SignatureValue>&lt;KeyInfo>&lt;X509Data>&lt;X509SubjectName>1.2.840.113549.1.9.1=#1617616e75702e6b756d61724075696461692e6e65742e696e,CN=AuthStaging25082025,OU=AuthStaging25082025,O=UIDAI,L=Bangalore,ST=Karnataka,C=IN&lt;/X509SubjectName>&lt;X509Certificate>MIID5DCCAsygAwIBAgIEATMzfzANBgkqhkiG9w0BAQsFADCBqTELMAkGA1UEBhMCSU4xEjAQBgNVBAgTCUthcm5hdGFrYTESMBAGA1UEBxMJQmFuZ2Fsb3JlMQ4wDAYDVQQKEwVVSURBSTEcMBoGA1UECxMTQXV0aFN0YWdpbmcyNTA4MjAyNTEcMBoGA1UEAxMTQXV0aFN0YWdpbmcyNTA4MjAyNTEmMCQGCSqGSIb3DQEJARYXYW51cC5rdW1hckB1aWRhaS5uZXQuaW4wHhcNMjAwODI1MDAwMDAwWhcNMjUwODI1MDAwMDAwWjCBqTELMAkGA1UEBhMCSU4xEjAQBgNVBAgTCUthcm5hdGFrYTESMBAGA1UEBxMJQmFuZ2Fsb3JlMQ4wDAYDVQQKEwVVSURBSTEcMBoGA1UECxMTQXV0aFN0YWdpbmcyNTA4MjAyNTEcMBoGA1UEAxMTQXV0aFN0YWdpbmcyNTA4MjAyNTEmMCQGCSqGSIb3DQEJARYXYW51cC5rdW1hckB1aWRhaS5uZXQuaW4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtnXWu8+uja+Us3z+TWjY1yV5KZq8I4CT9oHVk0hOMOhZz5Vash4mvj4mHa8u9y2/qZXIdIB8s006k2jz0dvnpBiMFzoJoQ5TSPwJl13gGKu/NTProBIELiDnOESfOFevQas48hMbHxvRIIrTUIZ+wL017uXCF/UIamdwRZ8SSoN897tWwrRmSutpsgDCE/F4k88XzfOyx2UyG+kJJZOYIWeYWMhLRH4ascP/OE1/9BtJ31wZEZFEUp0Saat5KNWLlDhKF4R8mwJc7+OMIOw5YPyjY/iW/OyoEwgxvjgqCizlWZnv+oRq8yBxtBkfwkakwxYv1rOamNbHpET30EB2TAgMBAAGjEjAQMA4GA1UdDwEB/wQEAwIF4DANBgkqhkiG9w0BAQsFAAOCAQEAVGhmm2h3d8aOBhoZonAN6C5W1NY0hsuKP7xZ3ZyVeEhs1/DIavaPmrNx3LISEJZ9UDwGJdP/6+1M86DXUK5dvyjpfQOESxnXFNqvbuQkh2C/IxawCWjQCjWgUm+yyRXnpvcgLGNYGhKxnmuZVJwJOlScc/6wjqvONscPV+neHwerrbFBq8DwXGgqiJU2dijRFpChhN09PSbkQ/y2ACOBOS87XJrcxBP+AyBSTdQNG+q94Ww/PKBDgIvnR2JzpYA+eHqu45CJDy5zA1oHT1N7JZlm5GPe798g5GMrBfd/CZ5GTeGRS+MNSAGmD3BjankxWFWMVdNiXjLs400EZdKQGg==&lt;/X509Certificate>&lt;/X509Data>&lt;/KeyInfo>&lt;/Signature>&lt;/KycRes>"/>''';
                      final bookshelfXml=builder.buildDocument();
                      setState(() {
                        fieldcontroller.text=bookshelfXml.toString();
                      });
                      print(bookshelfXml.toString());
                      try {
                        final result = await platform.invokeMethod('launchApp2',{ 'ekyc':  bookshelfXml.toXmlString()});
                        setState(() {
                          fieldcontroller.text=result;
                        });
                      } on PlatformException catch (e) {
                        setState(() {
                          fieldcontroller.text=e.message!;
                        });
                      }
                    }
                  },
                  child: Text(
                    "Enter OTP",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 30,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      TextFormField(
        // maxLength: 12,
        readOnly: true,
        controller: fieldcontroller,
        minLines: 500,
        maxLines: 700,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Open Sans',
          fontSize: 20,
        ),
      ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              )
            ],
          ),
        ),
      );
  }
  TextEditingController fieldcontroller=new TextEditingController();
}
