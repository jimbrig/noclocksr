// modified from https://stackoverflow.com/a/19999868/4089266
$(document).on('shiny:sessioninitialized', function(event) {

    var ua = window.navigator.userAgent;
    var chrome = ua.indexOf("Chrome") > 0;
    var firefox = ua.indexOf("Firefox") > 0;

    // Determine if the browser is Internet Explorer by excluding Chrome and Firefox
    var isIE = !chrome && !firefox;

    // Send the result to the Shiny server as 'isIE'
    Shiny.onInputChange('isIE', isIE);

});
