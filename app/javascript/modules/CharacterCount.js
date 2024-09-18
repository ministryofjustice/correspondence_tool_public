moj.Modules.CharacterCount = {
  init : function(){
    var self = this;
    // the total number of characters allowed:
    var totalChars = $('.char-counter').attr('data-maxlength');
    var $message = $('#correspondence_message');
    var $liveRegion =  $('#live-region-text');

    $message.on('keyup keydown', function () {
      var $el = $(this);
      // Get the value
      var text = $el.val();
      // chars remaining
      var realLength = text.length;
      var remaining = totalChars - realLength;

      if (remaining < 0) {

        $liveRegion.add($message).addClass('char-counter--overlimit');
        $liveRegion.attr({
          'aria-live': 'assertive',
          'aria-atomic': 'true'
        });
        self.updateRemaining($liveRegion,remaining);

      }else{
        $liveRegion.add($message).removeClass('char-counter--overlimit');
        $liveRegion
          .removeAttr('aria-live')
          .removeAttr('aria-atomic');
        self.updateRemaining($liveRegion,remaining);

      }
    }).trigger('keyup');
  },

  updateRemaining : function ($liveRegion, charsLeft) {
    $liveRegion.find('.char-counter-count').text(charsLeft);
  }
};
