moj.Modules.YesNoRadio = {
  $yesContent: document.getElementById('correspondence_contact_requested_yes_content'),
  $noContent: document.getElementById('correspondence_contact_requested_no_content'),

  init: function() {
    const $yes = document.getElementById('correspondence-contact-requested-yes-field');
    const $no = document.getElementById('correspondence-contact-requested-no-field');

    if ($yes) {
      $yes.addEventListener("click", this.showYesContent.bind(this))
      if($yes.checked) this.showYesContent();
    }

    if ($no) {
      $no.addEventListener("click", this.showNoContent.bind(this))
      if($no.checked) this.showNoContent();
    }
  },

  showYesContent: function() {
    this.$yesContent.classList.remove('js-hidden');
    this.$noContent.classList.add('js-hidden');
  },

  showNoContent: function() {
    this.$yesContent.classList.add('js-hidden');
    this.$noContent.classList.remove('js-hidden');
  }
};
