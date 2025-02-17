var charCount = document.getElementsByClassName('char-counter')[0];
if (charCount) {
  moj.Modules.CharacterCount = {
    $message: document.getElementById('correspondence-message-field') || document.getElementById('correspondence-message-field-error'),
    $liveRegion: document.getElementById('live-region-text'),
    maxChars: Number(charCount.dataset['maxlength']),

    init : function() {
      this.$message.addEventListener("keydown", this.countCharacters.bind(this));
      this.$message.addEventListener("keyup", this.countCharacters.bind(this));
      this.$message.dispatchEvent(new Event("keydown"));
    },

    countCharacters: function() {
      var text = this.$message.value;
      var realLength = text.length;
      var remaining = this.maxChars - realLength;

      if (remaining < 0) {
        this.$message.classList.add('char-counter--overlimit');
        this.$liveRegion.classList.add('char-counter--overlimit');
        this.$liveRegion.ariaLive = "assertive"
        this.$liveRegion.ariaAtomic = "true"
        this.updateRemaining(remaining);

      } else {
        this.$message.classList.remove('char-counter--overlimit');
        this.$liveRegion.classList.remove('char-counter--overlimit');
        this.$liveRegion.ariaLive = "polite"
        this.$liveRegion.ariaAtomic = "false"
        this.updateRemaining(remaining);
      }
    },

    updateRemaining : function (charsLeft) {
      this.$liveRegion.getElementsByClassName('char-counter-count')[0].textContent = charsLeft;
    }
  }
};
