mapclick = function( point, indexname ) {

    var selected = point.series.chart.getSelectedPoints().map(function(x) { return x[indexname]; });
    var clicked = point[indexname];

    if( event.shiftKey || event.ctrlKey ){

        if( selected.indexOf( clicked ) == -1 ){
            selected.push( clicked );
        } else {
            selected.splice( selected.indexOf( clicked ) );
        }

    } else { selected = clicked }

    // Sending null doesn't trigger reactivity. '' will be interpreted by getinput as NULL.
    if( selected.length == 0 ) selected = '';

    Shiny.onInputChange( 'selectedgeos', selected );

}
