// helpers.js - Shiny Helpers


/**
 * Checks if a Shiny input value has changed.
 *
 * @param {Object} evt - The event object containing the input name and value.
 * @param {string} evt.name - The name of the Shiny input.
 * @param {*} evt.value - The current value of the Shiny input.
 * @returns {boolean} - Returns `true` if the input value has changed, `false` otherwise.
 */
function isInputChanged(evt) {
  if (!evt || typeof evt.name !== 'string' || typeof evt.value === 'undefined') {
    console.warn('Invalid event object passed to isInputChanged.');
    return false;
  }

  if (Shiny && Shiny.hasOwnProperty("shinyapp") && Shiny.shinyapp.hasOwnProperty("inputValues")) {
    let oldValue = null;

    // Loop through the Shiny input values to find the first match
    for (const key in Shiny.shinyapp.$inputValues) {
      // Remove any :binding from the input name
      const inputName = key.split(':')[0];

      if (inputName === evt.name) {
        oldValue = Shiny.shinyapp.$inputValues[key];
        break;
      }
    }

    return evt.value !== oldValue;
  } else {
    console.warn('Shiny application or input values are not available.');
    return false;
  }
}


/**
 * Cancels a Shiny input change by restoring its original value.
 *
 * @param {Object} evt - The event object containing the input name and value.
 * @param {string} evt.name - The name of the Shiny input.
 * @param {*} evt.value - The current value of the Shiny input.
 * @returns {Object} - An object containing the event, the original value, and the attempted new value.
 */
function cancelInput(evt) {
  if (!evt || typeof evt.name !== 'string' || typeof evt.value === 'undefined') {
    console.warn('Invalid event object passed to cancelInput.');
    return;
  }

  if (Shiny && Shiny.hasOwnProperty("shinyapp") && Shiny.shinyapp.hasOwnProperty("$inputValues")) {
    let oldValue = null;
    const newValue = evt.value;

    // Loop through the Shiny input values to find the first match
    for (const key in Shiny.shinyapp.$inputValues) {
      // Remove any :binding from the input name
      const inputName = key.split(':')[0];

      if (inputName === evt.name) {
        oldValue = Shiny.shinyapp.$inputValues[key];
        break;
      }
    }

    // Restore the original value if it differs from the new value
    if (newValue !== oldValue) {
      evt.value = oldValue;
    }
  } else {
    console.warn('Shiny application or input values are not available.');
  }

  // Cancel the event to prevent further propagation
  if (typeof evt.preventDefault === 'function') {
    evt.preventDefault();
  }

  return {
    event: evt,
    oldvalue: oldValue,
    newvalue: evt.value
  };
}



/**
 * Collects the content of all textarea elements on the page
 * and sends it to the Shiny server as an input value.
 *
 * The function retrieves all textarea elements, extracts their
 * values, and sends the array of values to the Shiny server under
 * the input ID 'texts'.
 */
function collectContent() {
  // Get all textarea elements on the page
  var textAreas = document.getElementsByTagName('textarea');

  // Extract the value of each textarea and store them in an array
  var texts = Array.from(textAreas, textarea => textarea.value);

  // Send the array of textarea values to the Shiny server
  Shiny.setInputValue('texts', texts);
}


/**
 * Updates the inner HTML content of a specified DOM element.
 *
 * @param {string} elementId - The ID of the DOM element to update.
 * @param {string} content - The new content to set as the inner HTML of the element.
 */
function updateElementContent(elementId, content) {
  var element = document.getElementById(elementId);

  if (element) {
    element.innerHTML = content;
  } else {
    console.warn(`Element with ID "${elementId}" not found.`);
  }
}

/**
 * Validates an HTML form by checking its validity state.
 *
 * @param {string} formId - The ID of the form element to validate.
 * @returns {boolean} - Returns `true` if the form is valid, otherwise `false`.
 */
function validateForm(formId) {
  var form = document.getElementById(formId);

  if (!form) {
    console.warn(`Form with ID "${formId}" not found.`);
    return false;
  }

  var isValid = form.checkValidity();

  if (!isValid) {
    alert("Please fill out all required fields.");
  }

  return isValid;
}


/**
 * Attaches a click event listener to a button element.
 *
 * @param {string} buttonId - The ID of the button element to attach the event listener to.
 * @param {Function} callback - The function to be called when the button is clicked.
 */
function handleButtonClick(buttonId, callback) {
  var button = document.getElementById(buttonId);

  if (!button) {
    console.warn(`Button with ID "${buttonId}" not found.`);
    return;
  }

  if (typeof callback !== 'function') {
    console.error('The provided callback is not a function.');
    return;
  }

  button.addEventListener('click', callback);
}
