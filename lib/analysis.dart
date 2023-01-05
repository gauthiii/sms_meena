import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:sms_meena/linear.dart';
import 'package:sms_meena/main.dart';
import 'package:sms_meena/new.dart';
import 'package:sms_meena/table.dart';
import 'package:sms_meena/bar.dart';
import 'package:sms_meena/line.dart';
import 'package:sms_meena/graphs.dart';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:sms_meena/mesRef.dart';

import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

sum_list(l) {
  num s = 0;

  for (var i = 0; i < l.length; i++) s = s + l[i];

  return s;
}

split_list(l, n) {
  var s = [];

  for (var i = 0; i <= n; i++) s.add(l[i]);

  return s;
}

class Profile extends StatefulWidget {
  final User currentUser;
  Profile({this.currentUser});

  @override
  ProfileS createState() => ProfileS();
}

class ProfileS extends State<Profile> {
  String mode = "";
  String start = "";
  String end = "";
  int st, en;
  List<Mes> mL = [];
  List<Mes> mL1 = [];
  List<DateTime> dT = [];
  List<DateTime> dTD = [];
  List<DateTime> dTW = [];
  List maxi = [];
  List cmaxi = [];
  List days = [];
  List weeks = [];
  num max = 0;
  num cmax = 0;
  num maxD = 0;
  num maxW = 0;
  num maxc = 0;
  num maxDc = 0;
  num maxWc = 0;
  num maxML = 0;
  num maxDML = 0;
  num maxWML = 0;
  bool isLoading = false;
  bool alert1 = false;
  bool alert = false;
  List diffS = [];
  int pre = 0;
  //bar graph
  List<SubscriberSeries> data = List<SubscriberSeries>();
  List<charts.Series<SubscriberSeries, String>> series;
  List<SubscriberSeries> cdata = List<SubscriberSeries>();
  List<charts.Series<SubscriberSeries, String>> cseries;
  List<SubscriberSeries> dataD = List<SubscriberSeries>();
  List<charts.Series<SubscriberSeries, String>> seriesD;
  List<SubscriberSeries> dataW = List<SubscriberSeries>();
  List<charts.Series<SubscriberSeries, String>> seriesW;
  //line chart
  List<Line> line = List<Line>();
  List<charts.Series<Line, num>> series1;
  List<Line> lineD = List<Line>();
  List<charts.Series<Line, num>> series1D;
  List<Line> lineW = List<Line>();
  List<charts.Series<Line, num>> series1W;
  //cumulative line chart
  List<Line> linec = List<Line>();
  List<charts.Series<Line, num>> series1c;
  List<Line> lineDc = List<Line>();
  List<charts.Series<Line, num>> series1Dc;
  List<Line> lineWc = List<Line>();
  List<charts.Series<Line, num>> series1Wc;
  //predicited line chart
  List<Line1> lineMLc = List<Line1>();
  List<charts.Series<Line1, num>> seriesMLc;
  List<Line1> lineMLDc = List<Line1>();
  List<charts.Series<Line1, num>> seriesMLDc;
  List<Line1> lineMLWc = List<Line1>();
  List<charts.Series<Line1, num>> seriesMLWc;

  ScrollController s = ScrollController();
  ScrollController sD = ScrollController();
  ScrollController sW = ScrollController();

  String isDaily = "";

  String predicted = "";
  String predictedx = "";
  String actual = "";
  String accuracy = "";

  @override
  void initState() {
    super.initState();
    getD();
  }

  getD() async {
    setState(() {
      isLoading = true;

      mL = [];

      dT = [];
      dTD = [];
      dTW = [];

      maxi = [];
      days = [];
      weeks = [];

      data = [];
      series = [];

      dataD = [];
      seriesD = [];

      dataW = [];
      seriesW = [];

      line = [];
      series1 = [];

      lineD = [];
      series1D = [];

      lineW = [];
      series1W = [];

      linec = [];
      series1c = [];

      lineDc = [];
      series1Dc = [];

      lineWc = [];
      series1Wc = [];

      max = 0;
      maxD = 0;
      maxW = 0;

      maxc = 0;
      maxDc = 0;
      maxWc = 0;
    });

    QuerySnapshot snapshot = await mesRef
        .document(widget.currentUser.email)
        .collection('messages')
        .orderBy('date', descending: false)
        .getDocuments();

    var ind = 1;
    line.add(Line(
      month: 0,
      subscribers1: 0,
      barColor1: charts.ColorUtil.fromDartColor(Colors.black),
    ));
    lineD.add(Line(
      month: 0,
      subscribers1: 0,
      barColor1: charts.ColorUtil.fromDartColor(Colors.black),
    ));
    lineW.add(Line(
      month: 0,
      subscribers1: 0,
      barColor1: charts.ColorUtil.fromDartColor(Colors.black),
    ));
    linec.add(Line(
      month: 0,
      subscribers1: 0,
      barColor1: charts.ColorUtil.fromDartColor(Colors.black),
    ));
    lineDc.add(Line(
      month: 0,
      subscribers1: 0,
      barColor1: charts.ColorUtil.fromDartColor(Colors.black),
    ));
    lineWc.add(Line(
      month: 0,
      subscribers1: 0,
      barColor1: charts.ColorUtil.fromDartColor(Colors.black),
    ));
    print(snapshot.documents.length);

    snapshot.documents.forEach((d) {
      Mes m = Mes.fromDocument(d);

      mL.add(m);

      SubscriberSeries i = SubscriberSeries(
        month: "E$ind",
        subscribers1: (m.amt == null) ? 0 : m.amt.toInt(),
        barColor1: charts.ColorUtil.fromDartColor(Colors.black),
      );

      Line j = Line(
        month: ind,
        subscribers1: (m.amt == null) ? 0 : m.amt.toInt(),
        barColor1: charts.ColorUtil.fromDartColor(Colors.black),
      );

      Line k = Line(
        month: ind,
        subscribers1: ((m.amt == null) ? 0 : m.amt.toInt()) +
            (maxi.length < 1 ? 0 : sum_list(maxi)).toInt(),
        barColor1: charts.ColorUtil.fromDartColor(Colors.black),
      );

      data.add(i);
      line.add(j);
      linec.add(k);
      maxi.add((m.amt == null) ? 0 : m.amt.toDouble());
      if (((m.amt == null) ? 0 : m.amt.toDouble()) > max)
        max = ((m.amt == null) ? 0 : m.amt.toDouble());

      if (k.subscribers1 > maxc) maxc = k.subscribers1;

      dT.add(m.date.toDate());

      ind = ind + 1;
    });
    print(1);

    setState(() {
      if (snapshot.documents.length > 0) {
        List day = [];
        List day1 = [];
        DateTime ts = dT[0];
        dTD.add(ts);
        dTW.add(ts);
        for (var i = 0; i < maxi.length; i++) {
          if (daysBetween(ts, dT[i]) > 0) {
            day1.add(day);
            day = [];
            ts = dT[i];
            dTD.add(ts);
            day.add(maxi[i]);
          } else
            day.add(maxi[i]);
        }
        day1.add(day);

        day1.forEach((y) {
          num sum = 0;
          y.forEach((z) {
            sum = sum + z;
          });
          days.add(sum);
        });

        List week = [];
        List week1 = [];
        var pos = 0;
        for (var i = 0; i < days.length; i++) {
          if (pos == 7) {
            week1.add(week);
            week = [];
            pos = 0;
            week.add(days[i]);
            pos = pos + 1;
          } else {
            week.add(days[i]);
            pos = pos + 1;
          }
        }
        week1.add(week);

        week1.forEach((y) {
          num sum = 0;
          y.forEach((z) {
            sum = sum + z;
          });
          weeks.add(sum);
        });

        for (var ix = 0; ix < days.length; ix++) {
          SubscriberSeries i = SubscriberSeries(
            month: "D${ix + 1}",
            subscribers1: days[ix].toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          );

          Line j = Line(
            month: ix + 1,
            subscribers1: days[ix].toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          );

          Line k = Line(
            month: ix + 1,
            subscribers1:
                days[ix].toInt() + (sum_list(split_list(days, ix - 1))).toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          );

          if (days[ix] > maxD) maxD = days[ix];

          if (k.subscribers1 > maxDc) maxDc = k.subscribers1;

          dataD.add(i);
          lineD.add(j);
          lineDc.add(k);
        }

        for (var ix = 0; ix < weeks.length; ix++) {
          SubscriberSeries i = SubscriberSeries(
            month: "W${ix + 1}",
            subscribers1: weeks[ix].toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          );

          Line j = Line(
            month: ix + 1,
            subscribers1: weeks[ix].toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          );

          Line k = Line(
            month: ix + 1,
            subscribers1: weeks[ix].toInt() +
                (sum_list(split_list(weeks, ix - 1))).toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          );

          if (k.subscribers1 > maxWc) maxWc = k.subscribers1;

          if (weeks[ix] > maxW) maxW = weeks[ix];

          dataW.add(i);
          lineW.add(j);
          lineWc.add(k);
        }

        series = [
          charts.Series(
              id: "Income",
              data: data,
              domainFn: (SubscriberSeries series, _) => series.month,
              measureFn: (SubscriberSeries series, _) => series.subscribers1,
              colorFn: (SubscriberSeries series, _) => series.barColor1),
        ];

        seriesD = [
          charts.Series(
              id: "Income",
              data: dataD,
              domainFn: (SubscriberSeries series, _) => series.month,
              measureFn: (SubscriberSeries series, _) => series.subscribers1,
              colorFn: (SubscriberSeries series, _) => series.barColor1),
        ];
        seriesW = [
          charts.Series(
              id: "Income",
              data: dataW,
              domainFn: (SubscriberSeries series, _) => series.month,
              measureFn: (SubscriberSeries series, _) => series.subscribers1,
              colorFn: (SubscriberSeries series, _) => series.barColor1),
        ];

        series1 = [
          charts.Series(
              id: "Income",
              data: line,
              domainFn: (Line series, _) => series.month,
              measureFn: (Line series, _) => series.subscribers1,
              colorFn: (Line series, _) => series.barColor1),
        ];
        series1D = [
          charts.Series(
              id: "Income",
              data: lineD,
              domainFn: (Line series, _) => series.month,
              measureFn: (Line series, _) => series.subscribers1,
              colorFn: (Line series, _) => series.barColor1),
        ];

        series1W = [
          charts.Series(
              id: "Income",
              data: lineW,
              domainFn: (Line series, _) => series.month,
              measureFn: (Line series, _) => series.subscribers1,
              colorFn: (Line series, _) => series.barColor1),
        ];

        series1c = [
          charts.Series(
              id: "Income",
              data: linec,
              domainFn: (Line series, _) => series.month,
              measureFn: (Line series, _) => series.subscribers1,
              colorFn: (Line series, _) => series.barColor1),
        ];

        series1Dc = [
          charts.Series(
              id: "Income",
              data: lineDc,
              domainFn: (Line series, _) => series.month,
              measureFn: (Line series, _) => series.subscribers1,
              colorFn: (Line series, _) => series.barColor1),
        ];

        series1Wc = [
          charts.Series(
              id: "Income",
              data: lineWc,
              domainFn: (Line series, _) => series.month,
              measureFn: (Line series, _) => series.subscribers1,
              colorFn: (Line series, _) => series.barColor1),
        ];

        print(series1Dc[0].data.length);
        print(series1Wc[0].data.length);
      }

      if (isDaily != "")
        reg(pre);
      else
        print("noreg");

      print(mode);
      print(mL.isNotEmpty);

      if (mL.isNotEmpty && mode != "cus") {
        print("no cus");
        st = 0;
        en = dTD.length - 1;
        start = "${dTD[st].day}-${dTD[st].month}-${dTD[st].year}";
        end = "${dTD[en].day}-${dTD[en].month}-${dTD[en].year}";
      } else if (mode == "cus") customize();

      isLoading = false;

      print(mode);
    });
  }

  mscaf() {
    if (isLoading == true)
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 10.0),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(Colors.black),
          ));
    else
      return RefreshIndicator(
          // ignore: missing_return
          onRefresh: () {
            getD();
          },
          child: (mode == "") ? scaf() : list());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: _getColorFromHex("#FFC107"),
            appBar: AppBar(
              centerTitle: true,
              title: Text(app()),
            ),
            body: mscaf()),
        // ignore: missing_return
        onWillPop: () {
          setState(() {
            if (alert == true)
              alert = false;
            else if (isDaily != "")
              isDaily = "";
            else if (mode != "") {
              if (mode == "cus") {
                mode = "";
                alert = true;
              } else {
                mode = "";
                getD();
              }
            } else
              Navigator.of(context).pop();
          });
        });
  }

  String app() {
    if (mode == "overall")
      return "Overall Expense Analysis";
    else if (mode == "weekly")
      return "Weekly Expense Analysis";
    else if (mode == "daily")
      return "Daily Expense Analysis";
    else if (mode == "pat")
      return "Predict Expenses";
    else if (mode == "cus")
      return "Custom Expenses";
    else if (mode == "cum")
      return "Cumulative Expense Analysis";
    else
      return "View Analysis";
  }

  bar() {
    if (mode == "overall")
      return graph("Overall Expense Analysis", series, max, s, context);
    else if (mode == "cus")
      return graph("Custom Expense Analysis", cseries, cmax, s, context);
    else if (mode == "weekly")
      return graph("Weekly Expense Analysis", seriesW, maxW, sW, context);
    else if (mode == "daily")
      return graph("Daily Expense Analysis", seriesD, maxD, sD, context);
    else if (mode == "pat")
      return pat();
    else if (mode == "cum") return cum();
  }

  nopred() {
    print("mudiyaaaaadddhhhhuuuuu");
  }

  pred() {
    reg(pre);
  }

  ml_choose() {
    return Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(height: 30),
          Center(child: Image.asset('images/ml.png', height: 128)),
          Container(height: 50),
          RaisedButton(
              onPressed: () {
                setState(() {
                  isDaily = "Daily";
                });
                if (days.length >= 2)
                  pred();
                else
                  nopred();
              },
              color: Colors.black,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Predict Daily Expenses  ",
                    style: TextStyle(
                        fontSize: 15.0,
                        color: _getColorFromHex("#FFC107"),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular")),
              ])),
          Container(height: 30),
          RaisedButton(
              onPressed: () {
                setState(() {
                  isDaily = "Weekly";
                });
                if (weeks.length >= 2)
                  pred();
                else
                  nopred();
              },
              color: Colors.black,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Predict Weekly Expenses",
                    style: TextStyle(
                        fontSize: 15.0,
                        color: _getColorFromHex("#FFC107"),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular")),
              ])),
          Container(height: 30),
          RaisedButton(
              onPressed: () {
                setState(() {
                  isDaily = "Overall";
                });
                if (maxi.length >= 2)
                  pred();
                else
                  nopred();
              },
              color: Colors.black,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Predict Overall Expenses",
                    style: TextStyle(
                        fontSize: 15.0,
                        color: _getColorFromHex("#FFC107"),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Regular")),
              ])),
        ]));
  }

  ml_choose2() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      RaisedButton(
          onPressed: () {
            setState(() {
              isDaily = "Daily";
            });
            if (days.length >= 2)
              reg(pre);
            else
              nopred();
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
            if (weeks.length >= 2)
              reg(pre);
            else
              nopred();
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
            setState(() {
              isDaily = "Overall";
            });
            if (maxi.length >= 2)
              reg(pre);
            else
              nopred();
          },
          color: Colors.black,
          child: Row(children: [
            Text("Overall",
                style: TextStyle(
                    fontSize: 15.0,
                    color: _getColorFromHex("#FFC107"),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Regular")),
            (isDaily == "Overall")
                ? Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.check_circle,
                        color: _getColorFromHex("#FFC107"), size: 18))
                : Container(height: 0, width: 0)
          ])),
    ]);
  }

  list() {
    return ListView(
      padding: EdgeInsets.all(6),
      children: [
        (mode != "pat" || data.length < 5)
            ? Container(height: 0, width: 0)
            : (isDaily == "")
                ? ml_choose() // Predict choose screen
                : ml_choose2(), // Predict change option on top
        Container(height: 20),
        bar(),
        Container(height: 20),
        (mode == "pat" || mode == "cum")
            ? Container(height: 0, width: 0)
            : table(
                (mode == "cus") ? cdata : data,
                mode,
                (mode == "cus") ? mL1 : mL,
                days,
                weeks,
                dTD,
                (mode == "cus") ? cmaxi : maxi,
                context),
        Container(height: 20),
      ],
    );
  }

  prediction() {
    return (mode == "pat" && isDaily != "")
        ? Column(children: [
            Container(
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Column(children: [
                  Transform.translate(
                      offset: const Offset(5.0, 12.0),
                      child: Text("Predict for the next",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Poppins-Bold",
                              fontWeight: FontWeight.bold,
                              fontSize: 15))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 40.0,
                          width: 40.0,
                          child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (pre > 0) pre -= 1;
                                });
                                reg(pre);
                              })),
                      Text("$pre",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Poppins-Bold",
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      SizedBox(
                          height: 40.0,
                          width: 40.0,
                          child: IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: Colors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  pre += 1;
                                });
                                reg(pre);
                              })),
                      Text(
                          ((isDaily == "Daily")
                                  ? "day"
                                  : (isDaily == "Weekly")
                                      ? "week"
                                      : "payment") +
                              ((pre == 1) ? "" : "s"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Poppins-Bold",
                              fontWeight: FontWeight.bold,
                              fontSize: 15))
                    ],
                  ),
                  Container(height: 10),
                  Padding(
                      padding: EdgeInsets.only(left: 6, right: 6),
                      child: (pre > 0)
                          ? RichText(
                              text: TextSpan(
                                  text: "You are expected to spend ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Poppins-Regular",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  children: <TextSpan>[
                                  TextSpan(
                                      text: "Rs.$predicted",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Poppins-Bold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  TextSpan(
                                    text: " in another ${(pre > 1) ? pre : ""}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                    text: ((isDaily == "Daily")
                                            ? " day"
                                            : (isDaily == "Weekly")
                                                ? " week"
                                                : " payment") +
                                        ((pre == 1) ? "." : "s."),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                    text:
                                        " This is the cumulative amount.\n\nThe amount you are most likely to spend on that particular",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                    text: ((isDaily == "Daily")
                                        ? " day is "
                                        : (isDaily == "Weekly")
                                            ? " week is "
                                            : " payment is "),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                    text: "Rs." + predictedx,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                    text:
                                        ".\n\nThe accuracy rate is $accuracy %\nThe amount should be between Rs.${(double.tryParse(accuracy) * double.tryParse(predictedx) / 100).toStringAsFixed(2)} and Rs.${((200 - double.tryParse(accuracy)) * double.tryParse(predictedx) / 100).toStringAsFixed(2)}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ]))
                          : RichText(
                              text: TextSpan(
                                  text: "You were expected to spend ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "Poppins-Regular",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  children: <TextSpan>[
                                  TextSpan(
                                      text: "Rs.$predicted",
                                      style: TextStyle(
                                          color: Colors.red[900],
                                          fontFamily: "Poppins-Bold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  TextSpan(
                                    text: ". But you have spent ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  TextSpan(
                                      text: "Rs.$actual",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Poppins-Bold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  TextSpan(
                                    text:
                                        ".\n\nThe predicted amount is $accuracy % accurate.",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Regular",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ]))),
                ])),
            Container(
                padding: EdgeInsets.only(left: 6, right: 6),
                child: Text(
                  "",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ))
          ])
        : Container(
            height: 0,
            width: 0,
          );
  }

  scaf() {
    return Stack(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RaisedButton(
                        disabledColor: Colors.black,
                        onPressed: (alert == true)
                            ? null
                            : () {
                                setState(() {
                                  mode = "overall";
                                });
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // <-- Radius
                        ),
                        elevation: 10,
                        color: Colors.black,
                        child: Container(
                            height: 150,
                            child: Center(
                                child: Text("Overall\nAnalysis",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _getColorFromHex("#FFC107"),
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))))))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RaisedButton(
                        disabledColor: Colors.black,
                        onPressed: (alert == true)
                            ? null
                            : () {
                                setState(() {
                                  mode = "weekly";
                                });
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // <-- Radius
                        ),
                        elevation: 10,
                        color: Colors.black,
                        child: Container(
                            height: 150,
                            child: Center(
                                child: Text("Weekly\nAnalysis",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _getColorFromHex("#FFC107"),
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))))))),
          ]),
          Container(height: 50),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RaisedButton(
                        disabledColor: Colors.black,
                        onPressed: (alert == true)
                            ? null
                            : () {
                                setState(() {
                                  mode = "daily";
                                });
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // <-- Radius
                        ),
                        elevation: 10,
                        color: Colors.black,
                        child: Container(
                            height: 150,
                            child: Center(
                                child: Text("Daily\nAnalysis",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _getColorFromHex("#FFC107"),
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))))))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RaisedButton(
                        disabledColor: Colors.black,
                        onPressed: (alert == true)
                            ? null
                            : () {
                                setState(() {
                                  alert = !alert;
                                });
                                print(alert);
                                print(dTD.length);
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // <-- Radius
                        ),
                        elevation: 10,
                        color: Colors.black,
                        child: Container(
                            height: 150,
                            child: Center(
                                child: Text("Custom\nAnalysis",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _getColorFromHex("#FFC107"),
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))))))),
          ]),
          Container(height: 50),
          Row(children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RaisedButton(
                        disabledColor: Colors.black,
                        onPressed: (alert == true)
                            ? null
                            : () {
                                setState(() {
                                  mode = "cum";
                                });

                                //  Navigator.of(context).pop();
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // <-- Radius
                        ),
                        elevation: 10,
                        color: Colors.black,
                        child: Container(
                            height: 150,
                            child: Center(
                                child: Text("Cumulative\nAnalysis",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _getColorFromHex("#FFC107"),
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))))))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: RaisedButton(
                        disabledColor: Colors.black,
                        onPressed: (alert == true)
                            ? null
                            : () {
                                setState(() {
                                  mode = "pat";
                                });
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // <-- Radius
                        ),
                        elevation: 10,
                        color: Colors.black,
                        child: Container(
                            height: 150,
                            child: Center(
                                child: Text("Predict\nExpenses",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: _getColorFromHex("#FFC107"),
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))))))),
          ]),
        ],
      ),
      (alert == true)
          ? BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 8.0,
                sigmaY: 8.0,
              ),
              child: AlertDialog(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: _getColorFromHex("#FFC107")),
                    borderRadius: BorderRadius.circular(10)),
                title: (data.isEmpty)
                    ? Text(
                        "ERROR\n\nMake atleast one transaction to view Custom Analysis",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins-Bold",
                            color: _getColorFromHex("#FFC107")))
                    : Column(children: [
                        Text("Custom Dates",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins-Bold",
                                color: _getColorFromHex("#FFC107"))),
                        Container(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: data.isEmpty
                                      ? Colors.grey
                                      : (st <= 0)
                                          ? Colors.grey
                                          : _getColorFromHex("#FFC107"),
                                  size: 20,
                                ),
                                onPressed: data.isEmpty
                                    ? null
                                    : (st <= 0)
                                        ? null
                                        : () {
                                            if (st > 0)
                                              setState(() {
                                                st = st - 1;
                                                start =
                                                    "${dTD[st].day}-${dTD[st].month}-${dTD[st].year}";
                                              });
                                          }),
                            Text(start,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular",
                                    color: _getColorFromHex("#FFC107"))),
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: data.isEmpty
                                      ? Colors.grey
                                      : (st >= en)
                                          ? Colors.grey
                                          : _getColorFromHex("#FFC107"),
                                  size: 20,
                                ),
                                onPressed: data.isEmpty
                                    ? null
                                    : (st >= en)
                                        ? null
                                        : () {
                                            if (st < en)
                                              setState(() {
                                                st = st + 1;
                                                start =
                                                    "${dTD[st].day}-${dTD[st].month}-${dTD[st].year}";
                                              });
                                          }),
                          ],
                        ),
                        Text("to",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins-Regular",
                                color: _getColorFromHex("#FFC107"))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: data.isEmpty
                                      ? Colors.grey
                                      : (en <= st)
                                          ? Colors.grey
                                          : _getColorFromHex("#FFC107"),
                                  size: 20,
                                ),
                                onPressed: data.isEmpty
                                    ? null
                                    : (en <= st)
                                        ? null
                                        : () {
                                            if (en > st)
                                              setState(() {
                                                en = en - 1;

                                                end =
                                                    "${dTD[en].day}-${dTD[en].month}-${dTD[en].year}";
                                              });
                                          }),
                            Text(end,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins-Regular",
                                    color: _getColorFromHex("#FFC107"))),
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: data.isEmpty
                                      ? Colors.grey
                                      : (en >= dTD.length - 1)
                                          ? Colors.grey
                                          : _getColorFromHex("#FFC107"),
                                  size: 20,
                                ),
                                onPressed: data.isEmpty
                                    ? null
                                    : (en >= dTD.length - 1)
                                        ? null
                                        : () {
                                            if (en < dTD.length - 1)
                                              setState(() {
                                                en = en + 1;
                                                end =
                                                    "${dTD[en].day}-${dTD[en].month}-${dTD[en].year}";
                                              });
                                          }),
                          ],
                        ),
                      ]),
                content: (data.isEmpty)
                    ? Padding(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              alert = !alert;
                            });
                          },
                          color: Colors.red[900],
                          child: Text("Okay",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins-Regular")),
                        ))
                    : Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RaisedButton(
                                onPressed: () {
                                  //   Navigator.of(context).pop();

                                  customize();
                                },
                                color: _getColorFromHex("#FFC107"),
                                child: Text("Done",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular")),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    alert = !alert;
                                  });
                                },
                                color: Colors.red[900],
                                child: Text("Cancel",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular")),
                              )
                            ])),
              ))
          : Container()
    ]);
  }

  customize() {
    setState(() {
      cdata = [];
      cseries = [];
      cmax = 0;
      mL1 = [];
      cmaxi = [];
      var ind = 0;
      for (var i = 0; i < mL.length; i++) {
        print(
            "${daysBetween(mL[i].date.toDate(), dTD[st])} days to ${daysBetween(mL[i].date.toDate(), dTD[en])} days");

        if (daysBetween(mL[i].date.toDate(), dTD[st]) <= 0 &&
            daysBetween(mL[i].date.toDate(), dTD[en]) >= 0) {
          cdata.add(SubscriberSeries(
            month: "E${ind + 1}",
            subscribers1: (mL[i].amt == null) ? 0 : mL[i].amt.toInt(),
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          ));

          if (((mL[i].amt == null) ? 0 : mL[i].amt.toInt()) > cmax)
            cmax = (mL[i].amt == null) ? 0 : mL[i].amt.toInt();

          mL1.add(mL[i]);
          cmaxi.add((mL[i].amt == null) ? 0 : mL[i].amt.toDouble());

          ind += 1;
        }
      }
      print(cdata.length);

      cseries = [
        charts.Series(
            id: "Income",
            data: cdata,
            domainFn: (SubscriberSeries series, _) => series.month,
            measureFn: (SubscriberSeries series, _) => series.subscribers1,
            colorFn: (SubscriberSeries series, _) => series.barColor1),
      ];

      alert = !alert;
      mode = "cus";
    });
  }

  cum() {
    return (data.isEmpty)
        ? Container(
            padding: EdgeInsets.only(top: 100),
            child: Column(children: [
              Center(child: Image.asset('images/nf.png', height: 128)),
              Container(height: 20),
              Center(
                  child: Text("Make atleast one transaction to view analysis!!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-Bold",
                          fontWeight: FontWeight.bold,
                          fontSize: 15)))
            ]),
          )
        : Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Card(
                color: Colors.grey,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  //<-- SEE HERE
                  side: BorderSide(color: Colors.black, width: 2),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Center(
                                child: Text("Overall Cumulative Statistics",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)))),
                        lineC(s, series1c, linec, maxc, context),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: Colors.black),
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Center(
                                child: Text("Daily Cumulative Statistics",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)))),
                        lineC(sD, series1Dc, lineDc, maxDc, context),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: Colors.black),
                        Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Center(
                                child: Text("Weekly Cumulative Statistics",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Bold",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)))),
                        lineC(sW, series1Wc, lineWc, maxWc, context),
                      ]),
                    ])));
  }

  reg(pre) {
    setState(() {
      isLoading = true;

      if (isDaily == "Overall") {
        List x = [];
        for (var i = 0; i < maxi.length; i++) x.add(i + 1);
        List y = [];
        //  y = maxi;
        for (var i = 1; i < linec.length; i++) y.add(linec[i].subscribers1);
        var z = regress(x, y);
        lineMLc = [];
        seriesMLc = [];
        maxML = 0;
        lineMLc.add(Line1(
          month: 0,
          subscribers1: 0,
          barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          subscribers2: z["intercept"],
          barColor2: charts.ColorUtil.fromDartColor(Colors.red[900]),
        ));

        for (var i = 0; i < y.length + pre; i++) {
          Line1 j1 = Line1(
            month: i + 1,
            subscribers1: (i < y.length) ? y[i].toInt() : null,
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
            subscribers2: (z["intercept"] + (i * z["slope"])),
            barColor2: charts.ColorUtil.fromDartColor(Colors.red[900]),
          );

          lineMLc.add(j1);
          predicted = (z["intercept"] + (i * z["slope"])).toStringAsFixed(2);

          if (i > 0)
            predictedx = ((z["intercept"] + (i * z["slope"])) -
                    (z["intercept"] + ((i - 1) * z["slope"])))
                .toStringAsFixed(2);

          if (i < y.length) actual = y[i].toInt().toStringAsFixed(2);

          if (i < y.length) {
            var x = double.tryParse(predicted) - double.tryParse(actual);
            x = (x < 0) ? x * -1 : x;
            x = x * 100 / double.tryParse(actual);
            x = 100 - x;

            accuracy = x.toStringAsFixed(2);
          }
        }
        for (var i = 0; i < lineMLc.length; i++) {
          if (lineMLc[i].subscribers2 > maxML) maxML = lineMLc[i].subscribers2;
        }

        if (maxc > maxML) maxML = maxc;

        seriesMLc = [
          charts.Series(
              id: "Expenses",
              data: lineMLc,
              domainFn: (Line1 series, _) => series.month,
              measureFn: (Line1 series, _) => series.subscribers2,
              colorFn: (Line1 series, _) => series.barColor2)
            ..setAttribute(charts.rendererIdKey, 'customLine'),
          charts.Series(
              id: "Income",
              data: lineMLc,
              domainFn: (Line1 series, _) => series.month,
              measureFn: (Line1 series, _) => series.subscribers1,
              colorFn: (Line1 series, _) => series.barColor1)
            ..setAttribute(charts.rendererIdKey, 'customLine1'),
        ];
      } else if (isDaily == "Daily") {
        List xD = [];
        for (var i = 0; i < days.length; i++) xD.add(i + 1);
        List y = [];
        //  y = days;
        for (var i = 1; i < lineDc.length; i++) y.add(lineDc[i].subscribers1);
        var z = regress(xD, y);
        print(z);
        lineMLDc = [];
        seriesMLDc = [];
        maxDML = 0;
        lineMLDc.add(Line1(
          month: 0,
          subscribers1: 0,
          barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          subscribers2: z["intercept"],
          barColor2: charts.ColorUtil.fromDartColor(Colors.red[900]),
        ));
        for (var i = 0; i < y.length + pre; i++) {
          Line1 j1 = Line1(
            month: i + 1,
            subscribers1: (i < y.length) ? y[i].toInt() : null,
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
            subscribers2: (z["intercept"] + (i * z["slope"])),
            barColor2: charts.ColorUtil.fromDartColor(Colors.red[900]),
          );

          lineMLDc.add(j1);

          predicted = (z["intercept"] + (i * z["slope"])).toStringAsFixed(2);

          if (i > 0)
            predictedx = ((z["intercept"] + (i * z["slope"])) -
                    (z["intercept"] + ((i - 1) * z["slope"])))
                .toStringAsFixed(2);

          if (i < y.length) actual = y[i].toInt().toStringAsFixed(2);

          if (i < y.length) {
            var x = double.tryParse(predicted) - double.tryParse(actual);
            x = (x < 0) ? x * -1 : x;
            x = x * 100 / double.tryParse(actual);
            x = 100 - x;

            accuracy = x.toStringAsFixed(2);
          }
        }

        for (var i = 0; i < lineMLDc.length; i++) {
          if (lineMLDc[i].subscribers2 > maxDML)
            maxDML = lineMLDc[i].subscribers2;
        }

        if (maxDc > maxDML) maxDML = maxDc;

        seriesMLDc = [
          charts.Series(
              id: "Expenses",
              data: lineMLDc,
              domainFn: (Line1 series, _) => series.month,
              measureFn: (Line1 series, _) => series.subscribers2,
              colorFn: (Line1 series, _) => series.barColor2)
            ..setAttribute(charts.rendererIdKey, 'customLine'),
          charts.Series(
              id: "Income",
              data: lineMLDc,
              domainFn: (Line1 series, _) => series.month,
              measureFn: (Line1 series, _) => series.subscribers1,
              colorFn: (Line1 series, _) => series.barColor1)
            ..setAttribute(charts.rendererIdKey, 'customLine1'),
        ];
      } else {
        List xW = [];
        for (var i = 0; i < weeks.length; i++) xW.add(i + 1);

        List y = [];
        //  y = weeks;
        for (var i = 1; i < lineWc.length; i++) y.add(lineWc[i].subscribers1);

        var z = regress(xW, y);

        print(z);

        lineMLWc = [];
        seriesMLWc = [];

        maxWML = 0;

        lineMLWc.add(Line1(
          month: 0,
          subscribers1: 0,
          barColor1: charts.ColorUtil.fromDartColor(Colors.black),
          subscribers2: z["intercept"],
          barColor2: charts.ColorUtil.fromDartColor(Colors.red[900]),
        ));

        for (var i = 0; i < y.length + pre; i++) {
          Line1 j1 = Line1(
            month: i + 1,
            subscribers1: (i < y.length) ? y[i].toInt() : null,
            barColor1: charts.ColorUtil.fromDartColor(Colors.black),
            subscribers2: (z["intercept"] + (i * z["slope"])),
            barColor2: charts.ColorUtil.fromDartColor(Colors.red[900]),
          );

          lineMLWc.add(j1);

          predicted = (z["intercept"] + (i * z["slope"])).toStringAsFixed(2);

          if (i > 0)
            predictedx = ((z["intercept"] + (i * z["slope"])) -
                    (z["intercept"] + ((i - 1) * z["slope"])))
                .toStringAsFixed(2);

          if (i < y.length) actual = y[i].toInt().toStringAsFixed(2);

          if (i < y.length) {
            var x = double.tryParse(predicted) - double.tryParse(actual);
            x = (x < 0) ? x * -1 : x;
            x = x * 100 / double.tryParse(actual);
            x = 100 - x;

            accuracy = x.toStringAsFixed(2);
          }
        }

        for (var i = 0; i < lineMLWc.length; i++) {
          if (lineMLWc[i].subscribers2 > maxWML)
            maxWML = lineMLWc[i].subscribers2;
        }

        if (maxWc > maxWML) maxWML = maxWc;

        seriesMLWc = [
          charts.Series(
              id: "Expenses",
              data: lineMLWc,
              domainFn: (Line1 series, _) => series.month,
              measureFn: (Line1 series, _) => series.subscribers2,
              colorFn: (Line1 series, _) => series.barColor2)
            ..setAttribute(charts.rendererIdKey, 'customLine'),
          charts.Series(
              id: "Income",
              data: lineMLWc,
              domainFn: (Line1 series, _) => series.month,
              measureFn: (Line1 series, _) => series.subscribers1,
              colorFn: (Line1 series, _) => series.barColor1)
            ..setAttribute(charts.rendererIdKey, 'customLine1'),
        ];
      }

      isLoading = false;
    });
  }

  pat() {
    return (data.length < 5)
        ? Container(
            padding: EdgeInsets.only(top: 100),
            child: Column(children: [
              Center(child: Image.asset('images/nf.png', height: 128)),
              Container(height: 20),
              Center(
                  child: Text(
                      "Make atleast 5 transactions to predict expenses!!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-Bold",
                          fontWeight: FontWeight.bold,
                          fontSize: 15)))
            ]),
          )
        : (isDaily == "")
            ? Container()
            : Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Card(
                    color: Colors.grey,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      //<-- SEE HERE
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            /*    Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Center(
                                    child: Text(isDaily + " Statistics",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "Poppins-Bold",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)))),
                            (isDaily == "Overall")
                                ? lineC(s, series1, line, max, context)
                                : (isDaily == "Daily")
                                    ? lineC(s, series1D, lineD, maxD, context)
                                    : lineC(s, series1W, lineW, maxW, context),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 2,
                                color: Colors.black), */
                            Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Center(
                                    child: Text(isDaily + " Prediction",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "Poppins-Bold",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)))),
                            (isDaily == "Overall")
                                ? lineC(sD, seriesMLc, lineMLc, maxML, context)
                                : (isDaily == "Daily")
                                    ? lineC(sD, seriesMLDc, lineMLDc, maxDML,
                                        context)
                                    : lineC(sD, seriesMLWc, lineMLWc, maxWML,
                                        context),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 2,
                                color: Colors.black),
                            prediction(),
                            Container(height: 20),
                          ]),
                        ])));
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
