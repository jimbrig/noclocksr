/**
 * Formats the chart label based on the y value or total value.
 *
 * @returns {string} - The formatted label.
 */
function chartLabel() {
    var i = this.y ? this.y : this.total;
    return chartLabel_val(i);
}

/**
 * Formats a value based on its magnitude, optionally as a percentage.
 *
 * @param {number} ival - The value to format.
 * @param {boolean} [aspercent=false] - Whether to format the value as a percentage.
 * @param {number} [digits=undefined] - Number of decimal places to include.
 * @returns {string} - The formatted value.
 */
function chartLabel_val(ival, aspercent, digits) {
    var i = ival;
    var absi = Math.abs(i);

    // Determine the divisor based on the value's magnitude
    var divxby = absi > 1000000000 ? 1000000000 : (absi > 1000000 ? 1000000 : (absi > 20000 ? 1000 : 1));

    if (divxby == 1 && !aspercent) {
        // Handle numbers smaller than 20,000 that aren't percentages
        if (absi < 10) {
            return i.toFixed(digits !== undefined ? digits : (i == 0 ? 0 : (i < 0.1 ? 4 : 2)));
        }
        return i.toFixed(0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    // Adjust to percentage or add suffix
    if (aspercent) {
        i = (i * 100).toFixed(digits !== undefined ? digits : 1) + "%";
    } else {
        // Divide and add the indicator (billion, million, thousand)
        var isuffix = absi > 1000000000 ? 'B' : (absi > 1000000 ? 'M' : (absi > 20000 ? 'K' : ''));
        i = (i / divxby).toFixed(digits !== undefined ? digits : 1);
        i = i + ' ' + isuffix;
    }

    return i;
}

/**
 * Formats a number with commas as thousand separators.
 *
 * @param {number|string} x - The number to format.
 * @param {string} [sep=','] - The separator character (default is comma).
 * @param {number} [grp=3] - The number of digits between each separator (default is 3).
 * @returns {string} - The formatted number as a string.
 */
function localeString(x, sep, grp) {
    var sx = ('' + x).split('.'), s = '', i, j;
    sep = sep || ',';            // Default separator
    grp = grp || grp === 0 || (grp = 3); // Default grouping
    i = sx[0].length;
    while (i > grp) {
        j = i - grp;
        s = sep + sx[0].slice(j, i) + s;
        i = j;
    }
    s = sx[0].slice(0, i) + s;
    sx[0] = s;
    return sx.join('.');
}
