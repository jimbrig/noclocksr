// Event listener for the 'shiny:visualchange' event
$(document).on('shiny:visualchange', function(event) {

    // Iterate over each element with class 'expand-div' that is within an active container
    $('.active .expand-div').each(function(i, elem) {

        var sub = $(elem).find('.chart-sub');

        // Remove any existing expand icon containers
        sub.find('.icon_expand_container').remove();

        // Append a new expand icon container with an icon inside
        sub.append('<div class="icon_expand_container"><i class="fas fa-expand"></i></div>');

        // Attach a click event to the new expand icon
        sub.find('.icon_expand_container').click(function() {
            expandImg(elem);
        });

    });

});

// Object to store the current state (expanded/collapsed) of each element
var savevals = {};

/**
 * Toggles the expansion state of an element and sends the state to Shiny.
 *
 * @param {HTMLElement} element - The DOM element to toggle expansion for.
 */
function expandImg(element) {

    var id = 'expand_' + element.id;

    // Get the current state of the element (default to 0 if not saved)
    var curval = savevals[id] || 0;

    // Toggle the state (0 becomes 1, 1 becomes 0)
    var newval = 1 - curval;

    // Send the new state to Shiny
    Shiny.onInputChange(id, newval);

    // Save the new state in the savevals object
    savevals[id] = newval;
}
