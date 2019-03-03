import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sms/contact.dart';

void main() {
  runApp(new MyApp());
}

sendText(number, message) {
    SmsSender sender = new SmsSender();
    String address = number;
    sender.sendSms(new SmsMessage(address, message));
}

Future<Map<Contact, List<SmsMessage>>>_getMessages() async {

  SmsQuery query = new SmsQuery();
  var contactMap = new Map<Contact, List<SmsMessage>>();
  List<SmsThread> threads = await query.getAllThreads;
  for (var i=0; i<threads.length; i++) {
    String phoneNumber = threads[i].address;
    ContactQuery contactQuery = new ContactQuery();
    Contact contact = await contactQuery.queryContact(phoneNumber);
    contactMap[contact] = (threads[i].messages);

    // Print messages for a specific number
//    if (contact.address == '9499107853') {
//      List<SmsMessage> messages = contactMap[contact];
//      messages.forEach((m) => print(m.body));
//    }
  }


//  for (var i=0; i < messages.length; i++) {
//    SmsMessage message = messages[i];
//    String phoneNumber = message.address;
//    if (contactMap.containsKey(phoneNumber)) {
////      if (phoneNumber == '8176370103') {
////      if (phoneNumber == '9092476022') {
////        print(message.body);
////      }
//      contactMap[phoneNumber].add(message);
//    }
//    else {
//      contactMap[phoneNumber] = new List<SmsMessage>();
//    }
//  }
//  void iterateMapEntry(key, value) async {
//    // Check if I have more than 10 messages with this person
//    if (value.length < 10) {
//      contactMap.remove(key);
//    }
//  }

//  contactMap.forEach(iterateMapEntry);
  contactMap.removeWhere((key, value) => value.length < 10);
  return contactMap;
  
//  var contactNumbers = contactMap.keys.toList();
//  List<String> contactNames = new List<String>();
//  for (var i=0; i<contactNumbers.length; i++) {
//    Contact contact = await contacts.queryContact(contactNumbers[i]);
//    contactNames.add(contact.fullName);
//  }

//  List<String> contactNames = contactNumbers.map((number) => contacts.queryContact(number).toString()).toList();
//  print(contactNames);
//  return contactNames;
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
      title: 'Text Analyzer',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Contacts'),
        ),
        body: Center(
          child: new FutureBuilder(
            future: _getMessages(), // a previously-obtained Future<String> or null
               builder: (BuildContext context, AsyncSnapshot snapshot) {
                 switch (snapshot.connectionState) {
                   case ConnectionState.none:
                   case ConnectionState.active:
                   case ConnectionState.waiting:
                     return Text('Loading...');
                   case ConnectionState.done:
                     if (snapshot.hasError)
                       return Text('Error: ${snapshot.error}');
                     return createListView(context, snapshot);
                 }
                 return null; // unreachable
               },
          )
        ),
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
//    List<String> values = snapshot.data;
    Map<Contact, List<SmsMessage>> contactMap = snapshot.data;
    List<Contact> contacts = contactMap.keys.toList();
    List<String> names = contacts.map((contact) => contact.fullName).toList();
    List<String> numbers = contacts.map((contact) => contact.address).toList();
    List<int> numChatMessages = contacts.map((contact) => contactMap[contact].length).toList();

    List<Person> people = new List<Person>();
    for (var i=0; i<names.length; i++) {
      people.add(new Person(names[i], numbers[i], numChatMessages[i]));
    }

//    .sort((a, b) => a.id.compareTo(b.id));
    people.sort((a, b) => b.numMessages.compareTo(a.numMessages));
    people.forEach((person) => print(person.numMessages));
//    values.forEach((contact) => (contact.fullName));
//    map((name) => name.fullName);
    return new ListView.builder(
//      padding: EdgeInsets.all(8.0),
      itemCount: people.length,
//      itemExtent: 20.0,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(
                  people[index].name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                  textScaleFactor: 1.5,
              ),
              subtitle: new Text(people[index].number),
              trailing: new Text(
                people[index].numMessages.toString(),
                  style: TextStyle(fontWeight: FontWeight.w600),
                  textScaleFactor: 1.4,
              ),
            ),
            new Divider(
              height: 2.0,
            )
          ],
        );
      },
    );
  }
}

class Person {
  String name;
  String number;
  int numMessages;

  Person(this.name, this.number, this.numMessages) {}

}