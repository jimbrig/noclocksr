$(document).ready(function() {
  function setupDebugButton(ns_prefix, hide, keys_js) {

    console.log('setupDebugButton', ns_prefix, hide, keys_js);

    if (hide) {
      $('#'+ ns_prefix + 'browser_btn').hide();
    }

    $(document).on('keydown', function(e) {
      if (eval(keys_js)) {
        $('#'+ ns_prefix + 'browser_btn').toggle();
      }
    });
  }
});
