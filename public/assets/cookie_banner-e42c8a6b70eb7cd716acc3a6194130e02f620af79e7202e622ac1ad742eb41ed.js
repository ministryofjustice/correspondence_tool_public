// app/javascript/cookie_banner.js
var cookieBanner = document.querySelector(".govuk-cookie-banner");
if (cookieBanner) {
  hideButton = cookieBanner.querySelector(".cookie-hide-button");
  if (hideButton) {
    hideButton.addEventListener("click", function(e) {
      e.preventDefault();
      cookieBanner.style.display = "none";
    });
  }
}
var hideButton;

