import 'package:flutter/material.dart';

DateTime weB(DateTime a) {
  return DateTime(a.year, a.month, a.day + 6);
}

giveDate1(timestamp) {
  var z = timestamp.toDate().toString();
  var x1 = timestamp.toDate().toString().substring(0, 10).split("-");
  var y = x1[2] + "-" + x1[1] + "-" + x1[0].substring(2);
  var time = giveTime(z.substring(11, 16));

  return y + " at " + time;
}

giveTime(y) {
  var x1 = y.substring(0, 2);
  var x2 = y.substring(2, 5);
  var x3 = " AM";

  if (int.parse(x1) >= 12) {
    var a;
    if (int.parse(x1) != 12)
      a = int.parse(x1) - 12;
    else
      a = 12;
    x1 = a.toString();
    x3 = " PM";
  } else if (int.parse(x1) < 10) {
    var a = int.parse(x1);
    if (a == 0)
      x1 = "12";
    else
      x1 = a.toString();
  }

  return x1 + x2 + x3;
}

Widget table(data, mode, mL, days, weeks, dTD, maxi, context) {
  return (data.isEmpty)
      ? Container(
          padding: EdgeInsets.only(top: 100),
          child: Column(children: [
            Center(child: Image.asset('images/nf.png', height: 128)),
            Container(height: 20),
            Center(
                child: Text(
                    "Analysis available only after making atleast one transaction!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Poppins-Bold",
                        fontWeight: FontWeight.bold,
                        fontSize: 15)))
          ]),
        )
      : Padding(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[350],
                border: Border.all(
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
              child: Column(children: [
                Padding(
                    padding: EdgeInsets.all(8),
                    child: (mode == "cus")
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Container(width: 30),
                                Text(
                                  "${giveDate1(mL[0].date).split(" at ")[0]}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular",
                                      color: Colors.black),
                                ),
                                Icon(Icons.arrow_right_alt,
                                    color: Colors.black, size: 30),
                                Text(
                                  "${giveDate1(mL[mL.length - 1].date).split(" at ")[0]}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins-Regular",
                                      color: Colors.black),
                                ),
                                Container(width: 30),
                              ])
                        : Text(
                            (mode == "overall")
                                ? 'Overall Statement'
                                : (mode == "weekly")
                                    ? 'Weekly Statement'
                                    : 'Daily Statement',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins-Regular",
                                color: Colors.black),
                          )),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 2,
                    color: Colors.black),
                (mode == "overall" || mode == "cus")
                    ? Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(width: 2),
                        ),
                        columnWidths: const {
                            0: FixedColumnWidth(50),
                            1: FixedColumnWidth(90),
                            2: FixedColumnWidth(90),
                            3: FixedColumnWidth(120),
                          },
                        children: [
                            TableRow(children: [
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Key',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Date',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Time',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                            ]),
                            for (var i = 0; i < mL.length; i++)
                              TableRow(children: [
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          'E${i + 1}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          '${giveDate1(mL[i].date).split(" at ")[0]}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              //   fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          '${giveDate1(mL[i].date).split(" at ")[1]}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              //   fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          'Rs.${(mL[i].amt == null) ? 0 : (mL[i].amt - mL[i].amt.toInt() == 0) ? mL[i].amt.toInt() : mL[i].amt}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              //  fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                              ]),
                          ])
                    : Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(width: 2),
                        ),
                        columnWidths: const {
                            0: FixedColumnWidth(50),
                            1: FixedColumnWidth(120),
                            3: FixedColumnWidth(180),
                          },
                        children: [
                            TableRow(children: [
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Key',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Date',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                            ]),
                            for (var i = 0;
                                i <
                                    ((mode == "daily")
                                        ? days.length
                                        : weeks.length);
                                i++)
                              TableRow(children: [
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          (mode == 'daily')
                                              ? 'D${i + 1}'
                                              : 'W${i + 1}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 0),
                                        child: Text(
                                          (mode == "daily")
                                              ? '${dTD[i].day}-${dTD[i].month}-${dTD[i].year}'
                                              : '${dTD[i * 7].day}-${dTD[i * 7].month}-${dTD[i * 7].year}\nto\n${weB(dTD[i * 7]).day}-${weB(dTD[i * 7]).month}-${weB(dTD[i * 7]).year}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              //   fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text(
                                          (mode == "daily")
                                              ? 'Rs.${(days[i] == null) ? 0 : (days[i] - days[i].toInt() == 0) ? days[i].toInt() : days[i].toStringAsFixed(2)}'
                                              : 'Rs.${(weeks[i] == null) ? 0 : (weeks[i] - weeks[i].toInt() == 0) ? weeks[i].toInt() : weeks[i].toStringAsFixed(2)}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              //  fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins-Regular",
                                              color: Colors.black),
                                        ))),
                              ]),
                          ]),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 2,
                    color: Colors.black),
                (mode == "overall" || mode == "cus")
                    ? Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(width: 2),
                        ),
                        columnWidths: const {
                            0: FixedColumnWidth(230),
                            1: FixedColumnWidth(120),
                          },
                        children: [
                            TableRow(children: [
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Total',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        'Rs.${(maxi.reduce((value, element) => value + element) == null) ? 0 : (maxi.reduce((value, element) => value + element) - maxi.reduce((value, element) => value + element).toInt() == 0) ? maxi.reduce((value, element) => value + element).toInt() : maxi.reduce((value, element) => value + element).toStringAsFixed(2)}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                            ]),
                          ])
                    : Table(
                        border: TableBorder.symmetric(
                          inside: BorderSide(width: 2),
                        ),
                        columnWidths: const {
                            0: FixedColumnWidth(170),
                            1: FixedColumnWidth(180),
                          },
                        children: [
                            TableRow(children: [
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Text(
                                        'Total',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        (mode == 'daily')
                                            ? 'Rs.${(days.reduce((value, element) => value + element) == null) ? 0 : (days.reduce((value, element) => value + element) - days.reduce((value, element) => value + element).toInt() == 0) ? days.reduce((value, element) => value + element).toInt() : days.reduce((value, element) => value + element).toStringAsFixed(2)}'
                                            : 'Rs.${(weeks.reduce((value, element) => value + element) == null) ? 0 : (weeks.reduce((value, element) => value + element) - weeks.reduce((value, element) => value + element).toInt() == 0) ? weeks.reduce((value, element) => value + element).toInt() : weeks.reduce((value, element) => value + element).toStringAsFixed(2)}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins-Regular",
                                            color: Colors.black),
                                      ))),
                            ]),
                          ])
              ])));
}
