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
    contactMap.removeWhere((key, value) => value.length < 10);
    return contactMap;
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

        List<Conversation> chats = new List<Conversation>();
        contactMap.forEach((contact, messageHistory) => chats.add(new Conversation(contact, messageHistory)));


//        for (var i=0; i<names.length; i++) {
//            chats.add(new Conversation(names[i], numbers[i], numChatMessages[i], contactMap[numbers[i]]));
//        }

//    .sort((a, b) => a.id.compareTo(b.id));
        chats.sort((a, b) => b.chatHistory.length.compareTo(a.chatHistory.length));
//    values.forEach((contact) => (contact.fullName));
//    map((name) => name.fullName);
        return new ListView.builder(
//      padding: EdgeInsets.all(8.0),
            itemCount: chats.length,
//      itemExtent: 20.0,
            itemBuilder: (BuildContext context, int index) {
                return new Column(
                    children: <Widget>[
                        new ListTile(
                            title: new Text(
                                chats[index].contact.fullName,
                                style: TextStyle(fontWeight: FontWeight.w600),
                                textScaleFactor: 1.5,
                            ),
                            trailing: new Column(
                                children: <Widget>[
                                    Text(
                                        chats[index].chatHistory.length.toString(),
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                        textScaleFactor: 1.4,
                                    ),
                                    Text(
                                        'messages',
                                        style: TextStyle(fontWeight: FontWeight.w300),
                                    ),
                                ],
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            onTap: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(builder: (context) {
                                        return new SecondScreen(chats[index]);
                                    })
                                );
                            },

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

class Conversation {
//    String name;
//    String number;
//    int numMessages;
    Contact contact;
    List<SmsMessage> chatHistory;

    Conversation(this.contact, this.chatHistory) {}
}

class SecondScreen extends StatelessWidget {
    Conversation conversation;

    SecondScreen(this.conversation) {}

    @override
    Widget build (BuildContext ctxt) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text("Conversation Details"),
            ),
            body: new Text(this.conversation.chatHistory.length.toString()),
        );
    }
}