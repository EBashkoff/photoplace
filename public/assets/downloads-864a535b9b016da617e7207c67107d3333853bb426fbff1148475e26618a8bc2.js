/**
 * Created by Eric on 6/11/16.
 */


$(document).ready(function () {
    originalDownloadFormUrl = $("#download-link").attr("href")
});

function toggle() {
    imgTarget = event.target;
    if (isImageNotSelected(imgTarget)) {
        $(imgTarget).css("border", "solid blue 2px")
    } else {
        $(imgTarget).attr("style", null)
        $(imgTarget).attr("style", null)
    }
}

function isImageNotSelected(ele) {
    return ($(ele).css("border").indexOf("solid") === -1)
}

function selectedImages() {
    return ($(".thumbnail img[style]"))
}

function presentDownloadResolutions() {
    event.preventDefault();
    if (selectedImages().length > 0) {
        $("#select-choices").addClass("hidden");
        $("#resolution-choices").removeClass("hidden");
    } else {
        alert("You have not selected any images to download!");
    }
}

function chosenDownloadResolution(size) {
    event.preventDefault();
    var resolutionChoices = $("#resolution-choices");
    if (selectedImages().length < 1) {
        alert("You have not selected any images to download!");
        $("#select-choices").removeClass("hidden");
        resolutionChoices.addClass("hidden");
        return
    }
    resolutionChoices.addClass("hidden");
    $("#do-download-display").removeClass("hidden");
    chosenResolution = size;

    $(".thumbnail img").attr("onclick", null);

    var photo_names = $("div.thumbnail img").filter(function () {
        return !isImageNotSelected(this)
    }).map(function () {
        return this.id
    });
    var data = {
        "photo_names": [],
        "resolution": chosenResolution
    };
    photo_names.each(function () {
        data["photo_names"].push(this)
    });

    var downloadQueryParams = $.param(data);
    var url = originalDownloadFormUrl + "?" + downloadQueryParams;
    $("#download-link").attr("href", url)
}

function restoreOriginalDownloadQuestion() {
    $("#do-download-display").addClass("hidden");
    $("#select-choices").removeClass("hidden");
    selectedImages().attr("style", null);
    $(".thumbnail img").attr("onclick", "toggle()")
}
;
