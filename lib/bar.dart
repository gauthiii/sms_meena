import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

graph(x, series, max, s, context) {
  return (series.isEmpty)
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
            child: Column(children: [
              Container(height: 8),
              Center(
                  child: Text(x,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins-Regular",
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
              RawScrollbar(
                  thumbColor: Colors.grey[800],
                  radius: Radius.circular(0),
                  isAlwaysShown: true,
                  controller: s,
                  thickness: 8,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: s,
                      child: Container(
                          padding: EdgeInsets.all(6),
                          height: 250,
                          width: (series[0].data.length < 7)
                              ? MediaQuery.of(context).size.width * 0.9
                              : ((MediaQuery.of(context).size.width *
                                      series[0].data.length) /
                                  7.5),
                          child: Padding(
                              padding: EdgeInsets.all(6),
                              child: charts.BarChart(
                                series,
                                //vertical: false,
                                barGroupingType: charts.BarGroupingType.grouped,
                                animate: true,
                                domainAxis: new charts.OrdinalAxisSpec(
                                    renderSpec:
                                        new charts.SmallTickRendererSpec(
                                  // Tick and Label styling here.
                                  labelStyle: new charts.TextStyleSpec(
                                      // size in Pts.

                                      fontFamily: "Poppins-Regular",
                                      color: charts.ColorUtil.fromDartColor(
                                          Colors.black)),

                                  axisLineStyle: new charts.LineStyleSpec(
                                      // size in Pts.

                                      color: charts.ColorUtil.fromDartColor(
                                          Colors.black)),
                                  tickLengthPx: 0,

                                  // Change the line colors to match text color.
                                )),
                                primaryMeasureAxis: charts.NumericAxisSpec(
                                    showAxisLine: true,
                                    renderSpec: new charts.GridlineRendererSpec(
                                      // Tick and Label styling here.
                                      labelStyle: new charts.TextStyleSpec(
                                          // size in Pts.

                                          fontFamily: "Poppins-Regular",
                                          color: charts.ColorUtil.fromDartColor(
                                              Colors.black)),

                                      lineStyle: new charts.LineStyleSpec(
                                          // size in Pts.
                                          dashPattern: [4, 4],
                                          color: charts.ColorUtil.fromDartColor(
                                              Colors.black)),

                                      axisLineStyle: new charts.LineStyleSpec(
                                          // size in Pts.

                                          color: charts.ColorUtil.fromDartColor(
                                              Colors.black)),
                                      tickLengthPx: 0,

                                      // Change the line colors to match text color.
                                    ),
                                    tickProviderSpec:
                                        charts.BasicNumericTickProviderSpec(
                                            desiredTickCount: 11),
                                    tickFormatterSpec:
                                        charts.BasicNumericTickFormatterSpec(
                                            (num value) {
                                      if (value == 0)
                                        return '0';
                                      else
                                        return '${value.toInt()}';
                                      /*  else
                            return '${value ~/ 1000}K';*/
                                    }),
                                    viewport: charts.NumericExtents(
                                        0, ((max ~/ 10) + 1) * 11)),
                              ))))),
            ]),
          ));
}
