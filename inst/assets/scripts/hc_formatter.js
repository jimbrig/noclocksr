// hc_formatter.js

/**
 * Highcharts formatter function.
 *
 * This function formats the tooltip for the Highcharts graph.
 * It formats the y-axis values to be more human-readable,
 * converting large numbers to K (thousands) or M (millions),
 * while smaller values are formatted with appropriate precision.
 *
 * @returns {string} HTML string representing the formatted tooltip.
 */
 var hc_formatter = function () {

  var points = this.points;

  var ys = points.map(function (el) {
    var y = el.y;
    var out;

    if (y > 1000000) {
      out = (Math.round(y / 100000) / 10).toLocaleString("en-US", {
        minimumFractionDigits: 1,
        maximumFractionDigits: 1,
      }) + "M";
    } else if (y > 1000) {
      out = (Math.round(y / 100) / 10).toLocaleString("en-US", {
        minimumFractionDigits: 1,
        maximumFractionDigits: 1,
      }) + "K";
    } else if (y > 2) {
      out = y.toLocaleString("en-US", {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
      });
    } else {
      out = y.toLocaleString("en-US", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      });
    }

    return out;
  });

  var html_out = "<b>" + this.x + ":</b><br/>";
  var last_metric = "";

  for (var i = 0; i < points.length; i++) {
    if (points[i].series.userOptions.my_metric !== last_metric) {
      html_out += "<b>" + points[i].series.userOptions.my_metric + " :</b><br/>";
      last_metric = points[i].series.userOptions.my_metric;
    }
    html_out +=
      '<span style="color:' +
      points[i].color +
      '">\u25CF ' +
      points[i].series.userOptions.my_group +
      ": </span>" +
      ys[i] +
      "<br/>";
  }

  return html_out;

};

