const RADIUSOFEARTH = 3959;      // In miles
const PERCENTAGEOFDIAGONAL = 2;  //  Percentage of map diagonal distance determines radius of cluster
var infoWindows = new Array();
var labels = [];
var googlemarkers = [];
var geotaggedfiles = [];
var bounds = new google.maps.LatLngBounds();
var map;
var slideshowctr;

if (!Array.prototype.indexOf) {  // This section is needed for MSIE which cannot handle indexOf function without this
    Array.prototype.indexOf = function (searchElement, fromIndex) {
        var i,
            pivot = (fromIndex) ? fromIndex : 0,
            length;

        if (!this) {
            throw new TypeError();
        }

        length = this.length;

        if (length === 0 || pivot >= length) {
            return -1;
        }

        if (pivot < 0) {
            pivot = length - Math.abs(pivot);
        }

        for (i = pivot; i < length; i++) {
            if (this[i] === searchElement) {
                return i;
            }
        }
        return -1;
    };
}

function initialize() {
    var initialload = true;
    var zoomaction = false;
    var panaction = false;
    var mapOptions = {
        zoom: 7,
        center: new google.maps.LatLng(39.109, -96.550),
        scaleControl: true,
        zoomControl: true,
        streetViewControl: false,
        minZoom: 2,
        zoomControlOptions: {
            style: google.maps.ZoomControlStyle.SMALL,
            position: google.maps.ControlPosition.TOP_RIGHT
        },
        panControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    if (document.getElementById('map-canvas') !== null) {
        map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    } else {
        //            return;
    }

    adjustwindowsize();
    geotaggedfiles = gon.geotaggedfiles;

    // The following section is a workaround for Object.keys(geotaggedfiles).length which does not work in MSIE
    Object.size = function (obj) {
        var size = 0, key;
        for (key in obj) {
            if (obj.hasOwnProperty(key)) size++;
        }
        return size;
    };

    // Below statement requires code above as workaround for MSIE
    if (Object.size(geotaggedfiles) === 0) {
        takedownprogressoverlay();
        return;
    }
    generatemarkersfromfiles(initialload, 20 / 5280);  //  Initial cluster radius in miles

    google.maps.event.addListener(map, "zoom_changed", function (event) {
        zoomaction = true;
        if (!initialload) {
            generatemarkersfromfiles(initialload, calculateclusterradius());
            $("#zoomlevel").text(map.getZoom());
            $("#clusterradius").text(Math.round(calculateclusterradius() * 100) / 100)
        }
    });

    google.maps.event.addListener(map, "center_changed", function () {
        panaction = true;
    });

    google.maps.event.addListener(map, "tilesloaded", function () {
        if (initialload) takedownprogressoverlay();
        if ((!zoomaction) && (!panaction)) {
            adjustwindowsize(true);
            zoomaction = false;
            panaction = false;
        }
        initialload = false;
    });
}

function generatemarkersfromfiles(initialload, clusterradius) {
    if (!initialload) {
        for (i = 0; i < googlemarkers.length; i++) {
            googlemarkers[i].setMap(null);
            labels[i].setMap(null);
        }
    }

    // Empty arrays
    infoWindows.length = 0;
    labels.length = 0;
    googlemarkers.length = 0;

    var tempgtfiles = new Array();
    for (var onetaggedfile in geotaggedfiles) {
        geotaggedfiles[onetaggedfile]['indexintogooglemarkers'] = -1;
        tempgtfiles.push(onetaggedfile);
    }

    googlemarkerscount = 0;
    comparearraycounter = tempgtfiles.length;

    for (var onetaggedfile in geotaggedfiles) {
        if (geotaggedfiles[onetaggedfile]['indexintogooglemarkers'] == -1) { // Only look at files not compared yet
            if (comparearraycounter > 0) {  // Remove this file from file compare list
                //  MSIE cannot handle indexOf method without Array.prototype.indexOf section above
                tempgtfiles.splice(tempgtfiles.indexOf(onetaggedfile), 1);
                comparearraycounter--;
            }
            var markerLatLng = new google.maps.LatLng(geotaggedfiles[onetaggedfile]["latitude"], geotaggedfiles[onetaggedfile]["longitude"]);
            var filearray = new Array();  // marker will have one filename initially
            filearray.push(onetaggedfile);
            var marker = new google.maps.Marker({
                position: markerLatLng,
                map: map,
                icon: gon.pin_icon_img['small'],
                animation: null,
                filenames: filearray,
                numberoffiles: 1,
                zIndex: 1,
                title: geotaggedfiles[onetaggedfile]["description"] + "\n"
                + "Filename: " + geotaggedfiles[onetaggedfile]["filename"] + "\n"
                + "Latitude: " + ((geotaggedfiles[onetaggedfile]["latitude"] > 0.0) ? "N " : "S ") + Math.abs(geotaggedfiles[onetaggedfile]["latitude"]) + "\n"
                + "Longitude: " + ((geotaggedfiles[onetaggedfile]["longitude"] > 0.0) ? "E " : "W ") + Math.abs(geotaggedfiles[onetaggedfile]["longitude"])
            });

            //  Loop through remaining filenames to compare locations; if similar then add to filename list in marker
            for (i = 0; i < comparearraycounter; i++) {
                filenametocompare = tempgtfiles[i];
                //  alert(i + ": File: " + onetaggedfile + ", Compared to: " + filenametocompare);
                var latLngToCompare = new google.maps.LatLng(geotaggedfiles[filenametocompare]["latitude"], geotaggedfiles[filenametocompare]["longitude"]);
                if (google.maps.geometry.spherical.computeDistanceBetween(markerLatLng, latLngToCompare, RADIUSOFEARTH) <= clusterradius) {  // lat/longs are close
                    // alert("In Range");
                    marker.setPosition(null);
                    filearray.push(filenametocompare);
                    marker['filenames'] = filearray;
                    marker['numberoffiles'] = marker['numberoffiles'] + 1;
                    marker.setTitle("");
                    if (marker['numberoffiles'] > 9) {
                        marker.setIcon(gon.pin_icon_img['medium']);
                    } else if (marker['numberoffiles'] > 99) {
                        marker.setIcon(gon.pin_icon_img['large']);
                    }
                    geotaggedfiles[filenametocompare]['indexintogooglemarkers'] = googlemarkerscount;  // Mark file in file source array as accounted for
                    tempgtfiles.splice(tempgtfiles.indexOf(filenametocompare), 1);   //  Remove file from compare list
                    comparearraycounter--;
                    i--;  //  Decrement i since array element was removed
                } else {
                    //                        alert("Not In Range");
                }
            }  //  End inner compare loop
            googlemarkers.push(marker);
            geotaggedfiles[onetaggedfile]['indexintogooglemarkers'] = googlemarkerscount;
            googlemarkerscount++;
        }  //  End if
    }  //  End out compare loop

    for (i = 0; i < googlemarkerscount; i++) {  //  Loop through markers to find clustered files
        if (googlemarkers[i]['numberoffiles'] > 1) {  //  This is a marker with multiple files
            var boundszone = new google.maps.LatLngBounds();
            var concatenatedfilenames = "Filenames: \n";
            for (j = 0; j < googlemarkers[i]['numberoffiles']; j++) {
                fileonmarkerlist = googlemarkers[i]['filenames'][j];
                concatenatedfilenames += fileonmarkerlist + "\n";
                var latLngInZone = new google.maps.LatLng(geotaggedfiles[fileonmarkerlist]['latitude'], geotaggedfiles[fileonmarkerlist]['longitude']);
                boundszone.extend(latLngInZone);
            }
            googlemarkers[i].setPosition(boundszone.getCenter());  //  Calculate center point of this zone of files and put it in group marker
            googlemarkers[i].setTitle(concatenatedfilenames);
        }
    }

    for (i = 0; i < googlemarkerscount; i++) {  //  Loop through all markers to place them on map
        //Below code adds label to marker
        var label = new Label({map: map}, ((googlemarkers[i]['numberoffiles'] < 10) ? 'small' : 'large'));
        label.bindTo('position', googlemarkers[i], 'position');
        label.bindTo('text', googlemarkers[i], 'numberoffiles');
        label.bindTo('zindex', googlemarkers[i], 'zIndex');
        labels.push(label);

        // Below code creates infowindow pop-up; first create content string
        slideshowctr = 0;
        var filenm = googlemarkers[i]['filenames'][0];  // First file name for this marker
        var contentstring = "<div class=\"info-window\" id=\"slideshowdiv\" style=\"overflow: hidden; width: 230px;\">";
        contentstring += "<div style=\"height: 30px\">";
        contentstring += "<div style=\"float:left;\"><input type=\"button\" class=\"button-style\" name=\"bback\" value=\"<<\" onclick=\"displayslide(event, " + i + ");\">";
        contentstring += "<input type=\"button\" class=\"button-style\" name=\"back\" value=\"<\" onclick=\"displayslide(event, " + i + ");\">";
        contentstring += "<input type=\"button\" class=\"button-style\" name=\"forward\" value=\">\" onclick=\"displayslide(event, " + i + ");\">";
        contentstring += "<input type=\"button\" class=\"button-style\" name=\"fforward\" value=\">>\" onclick=\"displayslide(event, " + i + ");\"></div>";
        contentstring += "<span id=\"slideshowctrtxt\" style=\"float:right; font-weight: bold;\">1/" + googlemarkers[i]['numberoffiles'] + "</span>";
        contentstring += "</div>";

        if (geotaggedfiles[filenm]['orientation'] === 'landscape') var imgDimension = "width: 220px;\"";
        if (geotaggedfiles[filenm]['orientation'] === 'portrait') var imgDimension = "height: 147px;\"";
        contentstring += "<div id=\"slideshowimagediv\" style=\"border: 1px solid black; padding: 4px; " + imgDimension + " align=center>";

        if (geotaggedfiles[filenm]['orientation'] === 'landscape') imgDimension = "style=\"max-width: 100% !important;\"";
        if (geotaggedfiles[filenm]['orientation'] === 'portrait') imgDimension = "style=\"max-height: 100% !important;\"";
        contentstring += "<img src=\"" + gon.geotaggedfiles[filenm].small_photo_url + "\" alt=\"No Image\" " + imgDimension + "></div>";

        contentstring += "<div id=\"slideshowcaption\" style=\"white-space: nowrap; overflow: hidden; text-overflow: ellipsis;\"><b>" + geotaggedfiles[filenm]["description"] + "</b><br>Filename: " + filenm + "</div>";
        contentstring += "</div>";

        var infoWindow = new google.maps.InfoWindow({
            content: contentstring
        });
        infoWindows[i] = infoWindow;

        google.maps.event.addListener(googlemarkers[i], 'click', function () {
            for (j = 0; j < googlemarkerscount; j++) {
                infoWindows[j].close();
            }
            infoWindows[googlemarkers.indexOf(this)].open(map, this);
        });
        bounds.extend(googlemarkers[i].getPosition());  //  Update region for all markers
    }
}

function calculateclusterradius() {
    var mapbounds = map.getBounds();
    var mapsizediagonal = Math.abs(google.maps.geometry.spherical.computeDistanceBetween(mapbounds.getNorthEast(), mapbounds.getSouthWest(), RADIUSOFEARTH));
    return (mapsizediagonal * PERCENTAGEOFDIAGONAL / 100);
}

function bouncemarker(filenm) {
    demagnifypic();
    panaction = true;
    temp = googlemarkers[geotaggedfiles[filenm]['indexintogooglemarkers']];
    temp.setAnimation(google.maps.Animation.BOUNCE);
    setTimeout(function () {
        temp.setAnimation(null);
    }, 2000);
    map.panTo(temp.getPosition());
}

function takedownprogressoverlay() {
    $("#progressbarparent").addClass("hidden");
    $("#progressbar").progressbar("destroy");
    $("#map-and-list").css("visibility", "visible");
}

function adjustwindowsize(adjustbounds) {
    var screenheight = $(window).height();
    $("#map-canvas").css("height", screenheight - 80 - 140);
    $("#filelistonright").css("height", screenheight - 80 - 162);
    if (adjustbounds && map && bounds) map.fitBounds(bounds);  //  Set map view appropriate to all markers only on windowsize
}

function displayslide(event, markernumber) {
    var totalfilenum = googlemarkers[markernumber]['numberoffiles'];
    event = event || window.event;
    panaction = true;
    var srcEle = event.srcElement || event.target;
    var showdirection = srcEle.name;
    if (showdirection === 'bback') slideshowctr = 0;
    if (showdirection === 'back') slideshowctr += totalfilenum - 1;
    if (showdirection === 'forward') slideshowctr++;
    if (showdirection === 'fforward') slideshowctr = totalfilenum - 1;
    slideshowctr %= totalfilenum;

    var thisfile = googlemarkers[markernumber]['filenames'][slideshowctr];  //  This file's name

    document.getElementById("slideshowctrtxt").innerHTML = (slideshowctr + 1) + "/" + totalfilenum;

    var divImg = $("#slideshowimagediv");
    var oImg = $("#slideshowimagediv img");
    oImg.attr("src", gon.geotaggedfiles[thisfile].small_photo_url);
    oImg.attr("alt", "No Image");
    if (geotaggedfiles[thisfile]['orientation'] === 'landscape') divImg.css("width", "220px");
    if (geotaggedfiles[thisfile]['orientation'] === 'portrait') divImg.css("height", "147px");
    oImg.css("max-width", "100%");
    oImg.css("max-height", "100%");

    $("#slideshowcaption").text = "<b>" + geotaggedfiles[thisfile]["description"] + "</b><br>Filename: " + thisfile;
}

//Communicates to the web browser to run the initialize function when the web page loads
google.maps.event.addDomListener(window, 'load', initialize);

$(window).resize(function () {
    adjustwindowsize(true)
});
