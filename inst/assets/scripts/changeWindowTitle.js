var window_title = {
  title: window.document.title,
  busy_title: null,
  load_state: false,
  inactive_state: false,
  pulse: false,
  flash_flag: false,

  _revertUpdate: function(e) {
    window.document.title = window_title.title;
    window_title.inactive_state = false;
    window.onfocus = null;
  },

  updateTitle: function(message) {
    if (!message.inactive) {
      window_title.title = message.title;
      window.document.title = message.title;
    } else {
      if (!document.hasFocus()) {
        if (message.revert_focus) {
          window_title.inactive_state = true;
          window.onfocus = window_title._revertUpdate;
        } else {
          window_title.title = message.title;
        }
        window.document.title = message.title;
      }
    }
  },

  _stopFlashMouseMove: function(e) {
    window_title.pulse = false;
    window.document.title = window_title.title;
    window.onmousemove = null;
  },

  _stopFlashFocus: function(e) {
    window_title.pulse = false;
    window.document.title = window_title.title;
    window.onfocus = null;
  },

  _stopFlashTimeout: function(flash) {
    clearInterval(flash);
    window.document.title = window_title.title;
  },

  _changeTitle: function(original_title, new_title) {
    if (window_title.pulse) {
      window.document.title = window_title.flash_flag ? original_title : new_title;
      window_title.flash_flag = !window_title.flash_flag;
    }
  },

  flashTitle: function(message) {
    window_title.flash_flag = false;
    window_title.pulse = true;

    if (message.revert_mouse) {
      window.onmousemove = window_title._stopFlashMouseMove;
    }

    if (!document.hasFocus() && message.revert_focus) {
      window.onfocus = window_title._stopFlashFocus;
    }

    var flashInterval = setInterval(window_title._changeTitle, message.interval, window_title.title, message.title);

    if (message.duration > 0) {
       setTimeout(window_title._stopFlashTimeout, message.duration, flashInterval);
    }
  },

  setBusyTitle: function() {
    window.document.title = window_title.busy_title;
  },

  setIdleTitle: function() {
    if (!window_title.inactive_state && !window_title.pulse) {
      window.document.title = window_title.title;
    } else if (window_title.inactive_state && document.hasFocus()) {
      window_title._revertUpdate(null);
    }
  }
};

Shiny.addCustomMessageHandler('updateWindowTitle', window_title.updateTitle);

Shiny.addCustomMessageHandler('flashWindowTitle', window_title.flashTitle);

$(document).on('shiny:connected', function() {
 var busy_title_element = document.getElementsByClassName('shiny-busy-title');
  if (busy_title_element.length === 1) {
    window_title.busy_title = busy_title_element[0].dataset.title;
    $(document).on('shiny:busy', window_title.setBusyTitle);
    $(document).on('shiny:idle', window_title.setIdleTitle);
  }
});
