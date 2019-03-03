import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms/contact.dart';

void main() {
  runApp(new MyApp());
}

Future<List<String>>_getMessages() async {
  SmsQuery query = new SmsQuery();
  ContactQuery contacts = new ContactQuery();
  List<SmsMessage> messages = await query.querySms();
  var contactMap = new Map();
  for (var i=0; i < messages.length; i++) {
    SmsMessage message = messages[i];
    String phoneNumber = message.address;
    if (contactMap.containsKey(phoneNumber)) {
      contactMap[phoneNumber].add(message);
    }
    else {
      contactMap[phoneNumber] = new List<SmsMessage>();
    }
  }
//  void iterateMapEntry(key, value) async {
//    // Check if I have more than 10 messages with this person
//    if (value.length < 10) {
//      contactMap.remove(key);
//    }
//  }

//  contactMap.forEach(iterateMapEntry);
  contactMap.removeWhere((key, value) => value.length < 10);
  
  var contactNumbers = contactMap.keys.toList();
  List<String> contactNames = new List<String>();
  for (var i=0; i<contactNumbers.length; i++) {
    Contact contact = await contacts.queryContact(contactNumbers[i]);
    contactNames.add(contact.fullName);
  }

//  List<String> contactNames = contactNumbers.map((number) => contacts.queryContact(number).toString()).toList();
  print(contactNames);
  return contactNames;
//  return contactMap;
//  print(contactMap.keys);
}

getTilesForContacts(contactMap) {
  List<Widget> tiles = new List<ListTile>();

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Welcome to Flutter',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: new FutureBuilder(
            future: _getMessages(), // a previously-obtained Future<String> or null
               builder: (BuildContext context, AsyncSnapshot snapshot) {
                 switch (snapshot.connectionState) {
                   case ConnectionState.none:
                     return Text('Press button to start.');
                   case ConnectionState.active:
                   case ConnectionState.waiting:
                     return Text('Awaiting result...');
                   case ConnectionState.done:
                     if (snapshot.hasError)
                       return Text('Error: ${snapshot.error}');
                     return Text('Result: ${snapshot.data}');
                 }
                 return null; // unreachable
               },
          )
        ),
      ),
    );
  }
}