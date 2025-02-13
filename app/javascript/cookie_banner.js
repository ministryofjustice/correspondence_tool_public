// Hide cookie banner
var cookieBanner = document.querySelector(".govuk-cookie-banner");
if (cookieBanner) {
  var hideButton = cookieBanner.querySelector('.cookie-hide-button');

  if (hideButton) {
    hideButton.addEventListener("click", function(e) {
      e.preventDefault();
      cookieBanner.style.display = 'none';
    });
  }
}
