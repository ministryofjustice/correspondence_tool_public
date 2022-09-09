moj.Modules.ShowHideContent = {
  elementSelector: 'label:has(":radio, :checkbox")',
  init: function() {
    var self = this;

    var showHideContent = new GOVUK.ShowHideContent();

    self.cacheEls();

    self.bindEvents();

    showHideContent.init();
  },

  cacheEls: function(){
    this.govukLabels = $(this.elementSelector);
  },

  bindEvents: function() {
    this.govukLabels.each(function (index, element) {
      var showHideTarget = element.getAttribute('for') + '_content';
      element.setAttribute('data-target', showHideTarget);
    });

    // Temporary emergency override to patch Chrome issue that prevents form showing
    if(navigator.userAgent.indexOf('Chrome')>-1) {
      $('#correspondence_contact_requested_yes').click(function(){
        $('#correspondence_contact_requested_yes_content').removeClass('js-hidden');
      });
      $('#correspondence_contact_requested_no').click(function(){
        $('#correspondence_contact_requested_yes_content').addClass('js-hidden');
      });
    }
    // End temporary fix

  }

};
