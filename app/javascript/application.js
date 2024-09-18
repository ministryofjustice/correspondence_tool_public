// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require govuk/selection-buttons
//= require moj
//= require_tree ./modules

(function () {
  'use strict';

  // Make the radio buttons checked when active
  var buttonSelector = 'label input[type=radio]';
  var selectionButtons = new GOVUK.SelectionButtons(buttonSelector);
  selectionButtons.setInitialState($(buttonSelector));

  moj.init();
}(GOVUK));

