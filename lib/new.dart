import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ScatterPlotComboLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            color: Colors.red[200],
            height: 500,
            child: charts.ScatterPlotChart(_createSampleData(),
                animate: false,
                // Configure the default renderer as a point renderer. This will be used
                // for any series that does not define a rendererIdKey.
                //
                // This is the default configuration, but is shown here for
                // illustration.
                defaultRenderer: new charts.PointRendererConfig(),
                // Custom renderer configuration for the line series.
                customSeriesRenderers: [
                  new charts.LineRendererConfig(
                      // ID used to link series to this renderer.
                      customRendererId: 'customLine',
                      // Configure the regression line to be painted above the points.
                      //
                      // By default, series drawn by the point renderer are painted on
                      // top of those drawn by a line renderer.
                      layoutPaintOrder: charts.LayoutViewPaintOrder.point + 1)
                ])));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final desktopSalesData = [
      new LinearSales(0, 5, 5.0),
      new LinearSales(10, 25, 5.0),
      new LinearSales(12, 75, 5.0),
      new LinearSales(13, 225, 5.0),
      new LinearSales(16, 50, 5.0),
      new LinearSales(24, 75, 5.0),
      new LinearSales(25, 100, 5.0),
      new LinearSales(34, 150, 5.0),
      new LinearSales(37, 10, 5.0),
      new LinearSales(45, 300, 5.0),
      new LinearSales(52, 15, 5.0),
      new LinearSales(56, 200, 5.0),
    ];

    var myRegressionData = [
      new LinearSales(0, 5, 3.5),
      new LinearSales(56, 240, 3.5),
    ];

    final maxMeasure = 300;

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (LinearSales sales, _) =>
            charts.ColorUtil.fromDartColor(Colors.black),
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        radiusPxFn: (LinearSales sales, _) => sales.radius,
        data: desktopSalesData,
      ),
      new charts.Series<LinearSales, int>(
          id: 'Mobile',
          colorFn: (_, __) =>      charts.ColorUtil.fromDartColor(Colors.red[900]),
          domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearSales sales, _) => sales.sales,
          data: myRegressionData)
        // Configure our custom line renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customLine'),
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;
  final double radius;

  LinearSales(this.year, this.sales, this.radius);
}
