import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms/contact.dart';

void main() {
  getMessages();
  runApp(new MyApp());
}

getMessages() async {
  SmsQuery query = new SmsQuery();
//  List<SmsMessage> messages = await query.getAllSms;
//  List<SmsMessage> messages = await query.querySms({
//    address: getContactAddress()
//  });
//  ContactQuery contacts = new ContactQuery();
//  Contact contact = await contacts.queryContact('8176370103');
  List<SmsMessage> messages = await query.querySms();
//  query.querySms({0, 2, contact.address});
//  query.querySms()
  var count = 0;
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
  void iterateMapEntry(key, value) async {
    // Check if I have more than 10 messages with this person
    if (value.length > 10) {
      ContactQuery contacts = new ContactQuery();
      Contact contact = await contacts.queryContact(key);
      print(contact.fullName);
    }
  }
  contactMap.forEach(iterateMapEntry);
//  print(contactMap.keys);
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
          child: Text("Yeahhhhh"),
        ),
      ),
    );
  }
}