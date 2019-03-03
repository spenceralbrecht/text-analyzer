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
    List<Conversation> allConversations = new List<Conversation>();
    List<SmsThread> threads = await query.getAllThreads;
    for (var i=0; i<threads.length; i++) {
        String phoneNumber = threads[i].address;

        List<SmsMessage> sentMessages = await query.querySms(address: phoneNumber, kinds: [SmsQueryKind.Sent]);
        List<SmsMessage> receivedMessages = await query.querySms(address: phoneNumber, kinds: [SmsQueryKind.Inbox]);

        ContactQuery contactQuery = new ContactQuery();
        Contact contact = await contactQuery.queryContact(phoneNumber);
        if (contact.fullName == null) {
            contact.fullName= contact.address;
        }
        Conversation conversation = new Conversation(contact, sentMessages, receivedMessages);
        allConversations.add(conversation);

    }
    allConversations.removeWhere((conv) => conv.sentMessages.length < 3);
    return allConversations;
}


class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Text Analyzer',
            theme: ThemeData(
                // Define the default Brightness and Colors
                brightness: Brightness.light,
                primaryColor: Colors.black,
                accentColor: Colors.black26,

                // Define the default Font Family
                fontFamily: 'Montserrat',

                // Define the default TextTheme. Use this to specify the default
                // text styling for headlines, titles, bodies of text, and more.
                textTheme: TextTheme(
                    headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                    title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                    body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
                ),
            ),
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
                                  return CircularProgressIndicator(semanticsLabel: 'Analyzing Messages',);
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
                              return CircularProgressIndicator();
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
    metric.yourAvgMessageLength = getAverageMessageLength(conversation.sentMessages);
    metric.theirAvgMessageLength = getAverageMessageLength(conversation.receivedMessages);
    return metric;
}

int getAverageMessageLength(List<SmsMessage> messages) {
    var totalLength = 0;
    messages.forEach((message) => totalLength+=message.body.length);
    return totalLength~/messages.length;
}

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
        crossAxisSpacing: 5.0,
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
                        textAlign: TextAlign.center,
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
                        textAlign: TextAlign.center,
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.textingSince,
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.8,
                    ),
                    Text(
                        'first message sent',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.totalMessages.toString(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.8,
                    ),
                    Text(
                        'total messages',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
            new Column(
                children: <Widget>[
                    Text(
                        metric.numMessagesYouSent.toString(),
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.8,
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
                        textScaleFactor: 1.8,
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
                        metric.yourAvgMessageLength.toString()+' characters',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.8,
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
                        metric.theirAvgMessageLength.toString()+' characters',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textScaleFactor: 1.8,
                    ),
                    Text(
                        'average message length',
                        style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                ],
            ),
        ],
    );
}