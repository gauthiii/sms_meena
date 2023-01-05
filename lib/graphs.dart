import 'package:charts_flutter/flutter.dart' as charts;

class SubscriberSeries {
  final String month;
  final int subscribers1;
  final charts.Color barColor1;

  SubscriberSeries({
    this.month,
    this.subscribers1,
    this.barColor1,
  });
}

class Line {
  final int month;
  final int subscribers1;
  final charts.Color barColor1;

  Line({
    this.month,
    this.subscribers1,
    this.barColor1,
  });
}

class Line1 {
  final num month;
  final num subscribers1, subscribers2;
  final double radius;
  final charts.Color barColor1, barColor2;

  Line1({
    this.month,
    this.subscribers1,
    this.subscribers2,
    this.radius,
    this.barColor1,
    this.barColor2,
  });
}
