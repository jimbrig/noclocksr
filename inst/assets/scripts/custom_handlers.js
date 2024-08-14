// handlers.js

Shiny.addCustomMessageHandler("updateComponent", function(message) {
    // Custom logic to update a UI component
    console.log("Component updated with data:", message.data);
});

Shiny.addCustomMessageHandler("updateHighchart", function(message) {
    var chart = $("#" + message.name).highcharts();
    var series = chart.series;
    series.addPoint([Number(message.x), Number(message.y0)], false, true);
    series.addPoint([Number(message.x), Number(message.y1)], false, true);
    chart.redraw();
});
