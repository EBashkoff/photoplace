$(document).ready(function () {
    adjustGallerySize()
});

function adjustGallerySize() {
    var windowWidth = $(window).width();
    var galleriaWidth = windowWidth * 0.95;
    var windowHeight = $(window).height();
    var galleriaHeight = windowHeight - 68;

    $(".galleria").css('height', galleriaHeight);
    $(".galleria").css('width', galleriaWidth);
    $(".galleria").css('margin-left', (windowWidth - galleriaWidth - 4) / 2)
}


