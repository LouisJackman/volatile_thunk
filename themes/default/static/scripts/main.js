(function () {
    "use strict";

    var backToTheTopElement = document.querySelector(
        "a.back-to-the-top"
    );

    window.addEventListener("scroll", function () {
        var scrolled = window.pageYOffset;
        var position = document.documentElement.clientHeight;

        if (scrolled <= position) {
            backToTheTopElement.classList.remove("active");
        } else {
            backToTheTopElement.classList.add("active");
        }
    });

    backToTheTopElement.addEventListener("click", function () {
        backToTheTopElement.classList.remove("active");
    });

}());

