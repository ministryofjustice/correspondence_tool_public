// app/javascript/moj.js
(function() {
  "use strict";
  var moj = {
    Modules: {},
    init: function() {
      for (var x in moj.Modules) {
        if (typeof moj.Modules[x].init === "function") {
          moj.Modules[x].init();
        }
      }
    },
    // safe logging
    log: function(msg) {
      if (window && window.console) {
        window.console.log(msg);
      }
    },
    dir: function(obj) {
      if (window && window.console) {
        window.console.dir(obj);
      }
    }
  };
  window.moj = moj;
})();

