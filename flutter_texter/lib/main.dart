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

Future<List<Conversation>>_getConversations() async {

    SmsQuery query = new SmsQuery();
//    List<SmsMessage> myMessages = await query.querySms(address: '8176370103', kinds: [SmsQueryKind.Sent]);
//    List<SmsMessage> theirMessages = await query.querySms(address: '8176370103', kinds: [SmsQueryKind.Inbox]);
//    myMessages.forEach((m) => print(m.body));

//    var contactMap = new Map<Contact, List<SmsMessage>>();
    List<Conversation> allConversations = new List<Conversation>();
    List<SmsThread> threads = await query.getAllThreads;
    for (var i=0; i<threads.length; i++) {
        String phoneNumber = threads[i].address;

        List<SmsMessage> sentMessages = await query.querySms(address: phoneNumber, kinds: [SmsQueryKind.Sent]);
        List<SmsMessage> receivedMessages = await query.querySms(address: phoneNumber, kinds: [SmsQueryKind.Inbox]);

        ContactQuery contactQuery = new ContactQuery();
        Contact contact = await contactQuery.queryContact(phoneNumber);
        Conversation conversation = new Conversation(contact, sentMessages, receivedMessages);
        allConversations.add(conversation);

    }
    allConversations.removeWhere((conv) => conv.sentMessages.length < 10);
    return allConversations;
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
                      future: _getConversations(), // a previously-obtained Future<String> or null
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
//        Map<Contact, List<SmsMessage>> contactMap = snapshot.data;
//        List<Contact> contacts = contactMap.keys.toList();
//        List<String> names = contacts.map((contact) => contact.fullName).toList();
//        List<String> numbers = contacts.map((contact) => contact.address).toList();
//        List<int> numChatMessages = contacts.map((contact) => contactMap[contact].length).toList();
//
//        List<Conversation> chats = new List<Conversation>();
//        contactMap.forEach((contact, messageHistory) => chats.add(new Conversation(contact, messageHistory)));


//        for (var i=0; i<names.length; i++) {
//            chats.add(new Conversation(names[i], numbers[i], numChatMessages[i], contactMap[numbers[i]]));
//        }

//    .sort((a, b) => a.id.compareTo(b.id));
        List<Conversation> chats = snapshot.data;

        chats.sort((a, b) => (b.sentMessages.length+b.receivedMessages.length).compareTo(a.sentMessages.length+a.receivedMessages.length));
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
                                        (chats[index].sentMessages.length+chats[index].receivedMessages.length).toString(),
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
    List<SmsMessage> sentMessages;
    List<SmsMessage> receivedMessages;

    Conversation(this.contact, this.sentMessages, this.receivedMessages) {}
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
          body: Center(
              child: new FutureBuilder(
                  future: _createMetricsObject(this.conversation), // a previously-obtained Future<String> or null
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                              return Text('Loading...');
                          case ConnectionState.done:
                              if (snapshot.hasError)
                                  return Text('Error: ${snapshot.error}');
                              return createDashboard(context, snapshot);;
                      }
                      return null; // unreachable
                  },
              ),
          )
        );
    }
}

Future<TextMetric>_createMetricsObject(Conversation conversation) async {
    TextMetric metric = new TextMetric();
    metric.name = conversation.contact.fullName;
    metric.totalMessages = conversation.sentMessages.length+conversation.receivedMessages.length;
    metric.textingSince = getFirstMessageDate(conversation.sentMessages);
    metric.numMessagesYouSent = conversation.sentMessages.length;
    metric.numMessagesTheySent = conversation.receivedMessages.length;
    return metric;
}

//int getYourMessageCount(Conversation conversation) {
//    List<SmsMessage> chatHistory = conversation.chatHistory;
//    int count = 0;
//    SmsMessage message;
//    for (int i=0; i < chatHistory.length; i++) {
//        message = chatHistory[i];
//        print(message.sender.toString());
////        print('sender = '+message.address.toString() + ' address = '+conversation.contact.address.toString());
//        if (message.sender.toString() != conversation.contact.address.toString()) {
////            print(message.body);
//            count++;
////            print(count);
//        }
//    }
//    return count;
//}

String getFirstMessageDate(List<SmsMessage> chatHistory) {
    String day = chatHistory.last.date.day.toString();
    String month = chatHistory.last.date.month.toString();
    String year = chatHistory.last.date.year.toString();
    return '$month-$day-$year';
}

class TextMetric {
    String name;
    String textingSince;
    int totalMessages;
    int numMessagesYouSent;
    int numMessagesTheySent;
    int yourAvgMessageLength;
    int theirAvgMessageLength;
}

Widget createDashboard(BuildContext context, AsyncSnapshot snapshot) {
    TextMetric metric = snapshot.data;
    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20.0),
        crossAxisSpacing: 10.0,
        crossAxisCount: 2,
//        childAspectRatio: 2.0,
        children: <Widget>[
            new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                    Text(
                        'You',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 2.0,
                    ),
                ],
            ),
            new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                    Text(
                        metric.name,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 2.0,
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.numMessagesYouSent.toString(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.4,
                    ),
                    Text(
                        'messages sent',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.numMessagesTheySent.toString(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.4,
                    ),
                    Text(
                        'messages sent',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.yourAvgMessageLength.toString(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.4,
                    ),
                    Text(
                        'average message length',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.theirAvgMessageLength.toString(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.4,
                    ),
                    Text(
                        'average message length',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.textingSince,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.4,
                    ),
                    Text(
                        'first message sent',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
        ],
    );
}