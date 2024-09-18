moj.Modules.YesNoRadio = {

  // Using custom show/hide because old Gov UK show hide didn't work for us on Chrome 105+
  yes: $('#correspondence_contact_requested_yes')
  ,yesContent: $('#correspondence_contact_requested_yes_content')
  ,no: $('#correspondence_contact_requested_no')
  ,noContent: $('#correspondence_contact_requested_no_content')

  ,init: function() {
    with(this) {
      yes.click(showYesContent.bind(this));
      no.click(showNoContent.bind(this));

      if(yes.is(':checked'))showYesContent();
      if(no.is(':checked'))showNoContent();
    }
  }

  ,showYesContent: function() {
    this.yesContent.removeClass('js-hidden');
    this.noContent.addClass('js-hidden');
  }

  ,showNoContent: function() {
    this.yesContent.addClass('js-hidden');
    this.noContent.removeClass('js-hidden');
  }
};
