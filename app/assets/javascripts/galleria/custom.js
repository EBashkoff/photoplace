$(document).ready(function () {
    adjustGallerySize()
});

function adjustGallerySize() {
    var windowWidth = $(window).width();
    var galleriaWidth = '100%';
    // var galleriaWidth = windowWidth * 0.95;
    var windowHeight = $(window).height();
    var galleriaHeight = windowHeight - 68;

    var galleriaSelector = $(".galleria");
    galleriaSelector.css('height', galleriaHeight);
    galleriaSelector.css('width', galleriaWidth);
    galleriaSelector.css('margin-left', (windowWidth - galleriaWidth - 4) / 2)
}


