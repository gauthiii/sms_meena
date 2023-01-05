import 'package:flutter/material.dart';
import 'package:sms_meena/analysis.dart';
import 'package:sms_meena/mesRef.dart';
import 'package:sms_meena/background.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

final mesRef = Firestore.instance.collection('Sms_Messages');
final userRef = Firestore.instance.collection('Sms_Users');
List<Mes> mL = [];
bool isAuth = false;
User currentUser;
final GoogleSignIn _googleSignIn = GoogleSignIn();

onBackgroundMessage(SmsMessage message) async {
  debugPrint("onBackgroundMessage called");
  print(message.body);
  print(message.toString());

  _googleSignIn.signInSilently(suppressErrors: false).then((account) async {
    DocumentSnapshot d = await userRef.document(account.email).get();
    currentUser = User.fromDocument(d);

    if (currentUser != null) {
      String mId = Uuid().v4();

      if (message.body.contains("DEBITED") ||
          message.body.contains("debited")) {
        print("HDFC");
        mesRef
            .document(currentUser.email)
            .collection("messages")
            .document(message.address +
                " " +
                DateTime.fromMillisecondsSinceEpoch(message.date).toString())
            .setData({
          "id": mId,
          "message": message.body.trim(),
          "date": DateTime.fromMillisecondsSinceEpoch(message.date),
          "address": message.address.trim(),
          "amt": amtfinder(message.body.trim()),
          "balance": balfinder(message.body.trim())
        });
        if (currentUser.daily_date == null) {
          userRef
              .document(currentUser.email)
              .updateData({"daily_sum": 0, "daily_date": DateTime.now()});

          DocumentSnapshot d = await userRef.document(account.email).get();
          currentUser = User.fromDocument(d);
        }
        if (currentUser.daily_date.toDate().day != DateTime.now().day) {
          userRef
              .document(currentUser.email)
              .updateData({"daily_sum": 0, "daily_date": DateTime.now()});

          DocumentSnapshot d = await userRef.document(account.email).get();
          currentUser = User.fromDocument(d);
        }

        if (currentUser.weekly_date == null) {
          userRef
              .document(currentUser.email)
              .updateData({"weekly_sum": 0, "weekly_date": DateTime.now()});

          DocumentSnapshot d = await userRef.document(account.email).get();
          currentUser = User.fromDocument(d);
        }

        if (daysBetween(currentUser.weekly_date.toDate(), DateTime.now()) >=
            7) {
          userRef
              .document(currentUser.email)
              .updateData({"weekly_sum": 0, "weekly_date": DateTime.now()});

          DocumentSnapshot d = await userRef.document(account.email).get();
          currentUser = User.fromDocument(d);
        }

        userRef.document(currentUser.email).updateData({
          "daily_sum": currentUser.daily_sum + amtfinder(message.body.trim())
        });

        userRef.document(currentUser.email).updateData({
          "weekly_sum": currentUser.weekly_sum + amtfinder(message.body.trim())
        });

        QuerySnapshot snapshot = await mesRef
            .document(currentUser.email)
            .collection('messages')
            .orderBy('date', descending: true)
            .getDocuments();

        print(snapshot.documents.length);

        snapshot.documents.forEach((d) async {
          Mes m = Mes.fromDocument(d);
          mL.add(m);
          print(m.amt);
        });

        if ((amtfinder(message.body.trim()) != null)) {
          notify(message, currentUser);
        }
      }
    }
  }).catchError((err) {
    print('Error signing in: $err');
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker App',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyHomePage> {
  bool isLoading = false;
  String isDaily = "";

  final telephony = Telephony.instance;
  TextEditingController lim = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(DateTime.fromMillisecondsSinceEpoch(1666090364000));

    google();

    initPlatformState();
    bg();
  }

  google() {
    setState(() {
      isLoading = true;
    });

    _googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handle(account.email);
    }).catchError((err) {
      print('Error signing in: $err');
      setState(() {
        isLoading = false;
      });
    });
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(currentUser.email).get();
    setState(() {
      currentUser = User.fromDocument(doc);

      isLoading = false;
    });
  }

  bg() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Expense Tracker App",
      notificationText: "The App is running in the background",
      notificationImportance: AndroidNotificationImportance.Max,
      notificationIcon: AndroidResource(
          name: 'ic_launcher',
          defType: 'mipmap'), // Default is ic_launcher from folder mipmap
    );

    var hasPermissions = await FlutterBackground.hasPermissions;

    bool success =
        await FlutterBackground.initialize(androidConfig: androidConfig);

    final backgroundExecution =
        await FlutterBackground.enableBackgroundExecution();
  }

  onMessage(SmsMessage message) async {
    await onBackgroundMessage(message);
    getUser();
  }

  onSendStatus(SendStatus status) {
    print(status == SendStatus.SENT ? "sent" : "delivered");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  savecheck() {
    if ((int.tryParse(lim.text.trim()) == currentUser.daily_limit &&
            isDaily == "Daily") ||
        (int.tryParse(lim.text.trim()) == currentUser.weekly_limit &&
            isDaily == "Weekly"))
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: _getColorFromHex("#FFC107")),
                  borderRadius: BorderRadius.circular(10)),
              title: Image.asset('images/close.png', height: 50),
              content: Text("Same as before! No new changes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Regular",
                      color: _getColorFromHex("#FFC107"))),
            );
          });
    else
      save();
  }

  save() async {
    setState(() {
      isLoading = true;
    });

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: _getColorFromHex("#FFC107")),
                borderRadius: BorderRadius.circular(10)),
            title: (int.tryParse(lim.text.trim()) != null && isDaily != "")
                ? Image.asset('images/checked.png', height: 50)
                : Image.asset('images/close.png', height: 50),
            content: Text(
                (int.tryParse(lim.text.trim()) != null && isDaily != "")
                    ? "₹ ${lim.text.trim()} set as your $isDaily limit"
                    : "INVALID INPUT!!!\nEnter a valid amount and choose a time interval",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Regular",
                    color: _getColorFromHex("#FFC107"))),
          );
        });

    if (int.tryParse(lim.text.trim()) != null && isDaily != "") {
      if (isDaily == "Daily")
        userRef.document(currentUser.email).updateData({
          "daily_limit": int.tryParse(lim.text.trim()),
          "daily_date": DateTime.now(),
        });
      else if (isDaily == "Weekly")
        userRef.document(currentUser.email).updateData({
          "weekly_limit": int.tryParse(lim.text.trim()),
          "weekly_date": DateTime.now(),
        });

      DocumentSnapshot doc = await userRef.document(currentUser.email).get();
      currentUser = User.fromDocument(doc);
    }

    setState(() {
      isLoading = false;
    });
  }

  handle(a) async {
    DocumentSnapshot doc = await userRef.document(a).get();
    if (!doc.exists) {
      userRef.document(a).setData({
        "email": a,
        "weekly_limit": 0,
        "daily_limit": 0,
        "weekly_sum": 0,
        "daily_sum": 0,
        "weekly_date": DateTime.now(),
        "daily_date": DateTime.now(),
      });

      doc = doc = await userRef.document(a).get();
    }

    setState(() {
      currentUser = User.fromDocument(doc);
      print(currentUser.email);
      print(currentUser.email);

      isAuth = true;
      isLoading = false;
    });
  }

  login() async {
    setState(() {
      isLoading = true;
    });

    _googleSignIn.signIn();

    _googleSignIn.onCurrentUserChanged.listen((account) {
      print(account.email);

      handle(account.email);
    }, onError: (err) {
      print('Error signing in: $err');

      setState(() {
        isLoading = false;
      });
    });
  }

  scaf() {
    if (isLoading && isAuth == true)
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 10.0),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Colors.black),
          ));
    else if (isAuth == false)
      return ListView(
        padding: EdgeInsets.all(8),
        children: [
          Container(height: 30),
          Center(child: Image.asset('images/wallet.png', height: 128)),
          Container(height: 20),
          Center(
              child: Text("",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-Bold",
                      fontWeight: FontWeight.bold,
                      fontSize: 15))),
          Container(height: 30),
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 35, right: 35),
            width: 300,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                login();
              },
              color: Colors.black,
              child: Text("Sign in with Google",
                  style: TextStyle(
                      fontSize: 15.0,
                      color: _getColorFromHex("#FFC107"),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Regular")),
            ),
          ),
          (isLoading)
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 30.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  ))
              : Container(height: 0, width: 0)
        ],
      );
    else if (isAuth == true)
      return RefreshIndicator(
          // ignore: missing_return
          onRefresh: () {
            getUser();
          },
          child: ListView(
            padding: EdgeInsets.all(8),
            children: [
              Center(child: Image.asset('images/wallet.png', height: 128)),
              Container(height: 20),
              Center(
                  child: Text("Enter the amount you wanna set as the limit",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-Bold",
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
              Container(height: 20),
              Padding(
                  padding: EdgeInsets.only(left: 50, right: 50),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular"),
                    controller: lim,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                          top: 5, bottom: 5, left: 10, right: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.black, width: 3.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: Colors.black, width: 3.0),
                      ),
                      hintText: "₹ Amount (Enter Digits Only)",
                      hintStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.normal,
                          fontFamily: "Poppins-Regular"),
                    ),
                  )),
              Container(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                RaisedButton(
                    onPressed: () {
                      setState(() {
                        isDaily = "Daily";
                      });
                    },
                    color: Colors.black,
                    child: Row(children: [
                      Text("Daily",
                          style: TextStyle(
                              fontSize: 15.0,
                              color: _getColorFromHex("#FFC107"),
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      (isDaily == "Daily")
                          ? Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.check_circle,
                                  color: _getColorFromHex("#FFC107"), size: 18))
                          : Container(height: 0, width: 0)
                    ])),
                RaisedButton(
                    onPressed: () {
                      setState(() {
                        isDaily = "Weekly";
                      });
                    },
                    color: Colors.black,
                    child: Row(children: [
                      Text("Weekly",
                          style: TextStyle(
                              fontSize: 15.0,
                              color: _getColorFromHex("#FFC107"),
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                      (isDaily == "Weekly")
                          ? Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.check_circle,
                                  color: _getColorFromHex("#FFC107"), size: 18))
                          : Container(height: 0, width: 0)
                    ])),
                RaisedButton(
                    onPressed: () {
                      setState(() {});
                      savecheck();
                    },
                    color: Colors.black,
                    child: Row(children: [
                      Text("Save",
                          style: TextStyle(
                              fontSize: 15.0,
                              color: _getColorFromHex("#FFC107"),
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Regular")),
                    ])),
              ]),
              Text(
                  "\nDaily Spend Limit : Rs.${(currentUser.daily_limit - currentUser.daily_limit.toInt() == 0) ? currentUser.daily_limit.toInt() : currentUser.daily_limit}",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-Bold",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                  "You've spent Rs.${(currentUser.daily_sum - currentUser.daily_sum.toInt() == 0) ? currentUser.daily_sum.toInt() : currentUser.daily_sum.toStringAsFixed(2)} today",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                  "\nWeekly Spend Limit : Rs.${(currentUser.weekly_limit - currentUser.weekly_limit.toInt() == 0) ? currentUser.weekly_limit.toInt() : currentUser.weekly_limit}",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-Bold",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                  "You've spent Rs.${(currentUser.weekly_sum - currentUser.weekly_sum.toInt() == 0) ? currentUser.weekly_sum.toInt() : currentUser.weekly_sum.toStringAsFixed(2)} this week",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Container(height: 30),
              Container(height: 20),
              Padding(
                padding: EdgeInsets.all(8),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(
                                currentUser: currentUser,
                              )),
                    );
                  },
                  color: Colors.black,
                  child: Text("View Analysis",
                      style: TextStyle(
                          fontSize: 15.0,
                          color: _getColorFromHex("#FFC107"),
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Regular")),
                ),
              ),
            ],
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _getColorFromHex("#FFC107"),
        appBar: AppBar(
          title: const Text('Expense Tracker App'),
          centerTitle: true,
          actions: [
            (isAuth == true)
                ? IconButton(
                    icon: Icon(
                      Icons.input,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _googleSignIn.signOut();
                        isAuth = false;
                      });
                    })
                : Container(height: 0, width: 0)
          ],
        ),
        body: scaf());
  }
}

Color _getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
}
