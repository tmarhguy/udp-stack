// Borrowed from the old AsciiDoc manual's theme: press "/" to search.
// No dependencies. Progressively enhanced: without JS there is simply
// no shortcut, and Material's own search keeps working normally.
(function () {
  "use strict";
  document.addEventListener("keydown", function (ev) {
    if (ev.key !== "/" || ev.ctrlKey || ev.metaKey || ev.altKey) return;
    var t = ev.target;
    if (t && (t.tagName === "INPUT" || t.tagName === "TEXTAREA" || t.isContentEditable)) return;
    var toggle = document.getElementById("__search");
    if (!toggle) return;
    ev.preventDefault();
    toggle.checked = true;
    var input = document.querySelector(".md-search__input");
    if (input) input.focus();
  });
})();
