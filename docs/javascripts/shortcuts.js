// Borrowed from the old AsciiDoc manual's theme: press "/" to search.
// No dependencies. Progressively enhanced: without JS there is simply
// no shortcut, and Material's own search keeps working normally.
(function () {
  "use strict";

  function relabelToc() {
    // Fumadocs heads the right rail with "On this page" instead of the
    // page title, so swap the rail header text (aria labels follow).
    var rail = document.querySelector(
      ".md-sidebar--secondary label[for='__toc'] .md-ellipsis"
    );
    if (rail) rail.textContent = "On this page";
    var navs = document.querySelectorAll('.md-nav--secondary[aria-label="Table of contents"]');
    navs.forEach(function (el) {
      el.setAttribute("aria-label", "On this page");
    });
  }

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

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", relabelToc);
  } else {
    relabelToc();
  }
})();
