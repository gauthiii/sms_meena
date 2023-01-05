import 'dart:math';

regress(List x, List y) {
  var n = y.length;
  num sx = 0;
  num sy = 0;
  num sxy = 0;
  num sxx = 0;
  num syy = 0;
  for (var i = 0; i < n; i++) {
    sx = sx + x[i];
    sy = sy + y[i];
    sxy = sxy + x[i] * y[i];
    sxx = sxx + x[i] * x[i];
    syy = syy + y[i] * y[i];
  }
  var mx = sx / n;
  var my = sy / n;
  var yy = n * syy - sy * sy;
  var xx = n * sxx - sx * sx;
  var xy = n * sxy - sx * sy;
  var slope = xy / xx;
  var intercept = my - slope * mx;
  var r = xy / sqrt(xx * yy);
  var r2 = pow(r, 2);
  num sst = 0;
  for (var i = 0; i < n; i++) {
    sst = sst + pow((y[i] - my), 2);
  }
  var sse = sst - r2 * sst;
  var see = sqrt(sse / (n - 2));
  var ssr = sst - sse;
  return {"slope": slope, "intercept": intercept};
}
