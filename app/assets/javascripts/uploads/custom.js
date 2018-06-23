$(document).ready(function () {
    var step = 1;      //  Step in process
    var pathname_notallowed = new RegExp("[\\\\?%&\\*:|\"<>\\.]", "g"); // Characters /\?%&*:|"<>.
    var newfoldername = "";
    var existingFolderRoot = "";
    var compositeFolderPath = "";
    var aNewFolderIsDesired = false;
    var filesToUpload = [];
    var countsuccesses = 0;
    var countreplies = 0;
    var newFolderButton = $("#newfolderbutton");
    newFolderButton.prop("disabled", true);

    $("#newfoldercheckbox").on("change", function () {
        step = 1;  //  If clicked, this reverts back to step 1
        prepstep2('off');  // Now a new destination folder is being chosen so must block out file upload section
        $("#newfolderbutton").prop("disabled", true);
        if ($(this).is(":checked")) {
            $("#newfolderinputdiv").removeClass("hidden");
            aNewFolderIsDesired = true
        } else {
            $("#newfolderinputdiv").addClass("hidden");
            $("#newfolderinput").val("");
            $("#uploaddest").text("");
            $("#folderselector").val(null);
            newfoldername = "";
            existingFolderRoot = "";
            aNewFolderIsDesired = false
        }
    });

    $("#addfilesbutton").on("change", addfiles);
    $("#removefilesbutton").on("click", removefiles);

    constructFolderName = function constructFolderName() {  // Creates upload folder name on server from selected options
        var pickedfolder = $("#pickedfolder").find(":selected");
        var albumName = $("#album-name");
        var albumDescription = $("#album-description");
        newfoldername = $("#newfolderinput").val().replace(pathname_notallowed, "");
        albumName.val(pickedfolder.attr("data-name"));
        albumDescription.val(pickedfolder.attr("data-description"));
        existingFolderRoot = pickedfolder.val();
        step = 1;  //  If parent folder is selected or new folder name entered, this reverts back to step 1
        prepstep2("off");  // Now a new destination folder is being chosen so must block out file upload
        if (aNewFolderIsDesired) {
            if (existingFolderRoot != null) {  // Check if anything was typed in yet
                if (existingFolderRoot === '') {
                    compositeFolderPath = newfoldername;
                } else {
                    compositeFolderPath = existingFolderRoot + "/" + newfoldername;
                }
                $("#uploaddest").text(compositeFolderPath).css("color", "black");
                $("#newfolderbutton").prop("disabled", false)
            } else {
                $("#uploaddest").text("<Please select an existing parent folder>").css("color", "red");
                $("#newfolderbutton").prop("disabled", true)
            }
        } else {
            compositeFolderPath = existingFolderRoot;
            $("#uploaddest").text(compositeFolderPath);
            $("#newfolderbutton").prop("disabled", false)
        }
    };

    $("#newfolderinput").on("input", constructFolderName);
    $("#pickedfolder").on("change", constructFolderName);

    performstep1 = function performstep1(event) {  // Routine to set up a new or current destination folder for uploaded images
        if (event.preventDefault) event.preventDefault(); else event.returnValue = false; // event.preventDefault() not available in MSIE
        var albumData = {
            album: {
                path: compositeFolderPath,
                title: $("#album-name").val(),
                description: $("#album-description").val()
            }
        };

        //  Determine if we are dealing with new or existing folder situation
        if (aNewFolderIsDesired) {       //  New folder situation requires creation of new folders on server
            var matchingFolderOptions = $("#pickedfolder").find("option").filter(function () {
                return $(this).val().toLowerCase() == compositeFolderPath.toLowerCase();
            });
            if (matchingFolderOptions.length > 0) { // New folder already exists
                alert("The entered new folder already exists");
                $("#newfolderinput").val("");
                $("#newfolderbutton").prop("disabled", true);
                newfoldername = "";
            } else {
                albumData.album.collection_id = $('#collection').val();
                $.post(gon.create_album_url, albumData)
                    .done(postProcessStep1Success)
                    .fail(postProcessStep1Failure);
            }
        } else {
            $.ajax({
                url: gon.update_album_url,
                method: 'PUT',
                data: albumData
            }).done(function () {
                step = 2;
                alert("Using folder " + compositeFolderPath + ".\nProceed to STEP 2...");
                $("#filedeststep2").text(compositeFolderPath).removeClass("hidden");
                prepstep2("on");  // Now full resolution file folder has been changed - enable file upload section
                changetabs(2);
            }).fail(postProcessStep1Failure);
        }
    };

    newFolderButton.on("click", performstep1);

    postProcessStep1Success = function (responseData) {
        var createdFolderRoot = responseData.path;
        alert("Created folders under " + createdFolderRoot + " successfully.\nProceed to STEP 2...");
        step = 2;
        //  Put new folder in option list
        var option = "<option value=\"" + createdFolderRoot + "\">" + createdFolderRoot + "</option>";
        $("#pickedfolder").append(option);
        $("#filedeststep2").text(createdFolderRoot).removeClass("hidden");
        prepstep2("on");  // Now full resolution file folder has been changed - enable file upload section
        changetabs(2);
    };

    postProcessStep1Failure = function (jqXHR, textStatus, errorThrown) {
        alert("Received error '" + jqXHR.responseJSON.statusText + "' from server (HTTP Status: " + jqXHR.status + ").")
    };

    function prepstep2(onoroff) {
        var progressBarStepTwo = $("#progressBarStepTwo");
        var percentCompleteStepTwo = $("#percentCompleteStepTwo");
        var fileUploadContainer = $("#fileuploadcontainer");
        switch (onoroff) {  //  Set or clear all STEP 2 elements
            case "on":
                fileUploadContainer.removeClass("hidden");
                break;
            case "off":
                $("#filedeststep2").text("").addClass("hidden");
                var uploadfilelist = $("#fileselector");
                uploadfilelist.empty();
                fileUploadContainer.addClass("hidden");
                filesToUpload = [];
                $("#uploadfilesbutton").prop("disabled", (filesToUpload.length < 1));
                progressBarStepTwo.val(0);
                percentCompleteStepTwo.text("0%");
                break;
            default:
                break;
        }
    }

    performstep2 = function performstep2(event) {  // Routine to upload full resolution file to images/full folder on server
        var progressBarStepTwo = $("#progressbarstep2");
        var percentCompleteStepTwo = $("#percentcompletestep2");
        var fileDestinationFolder = $("#filedeststep2").text();

        if (fileDestinationFolder !== "") {
            progressBarStepTwo.removeClass("hidden");
            progressBarStepTwo.prop("max", filesToUpload.length);
            progressBarStepTwo.val(0);
            percentCompleteStepTwo.removeClass("hidden");
            percentCompleteStepTwo.text("0%");
            $("#addfilesbutton").prop("disabled", true);
            $("#removefilesbutton").prop("disabled", true);
            $("#uploadfilesbutton").prop("disabled", true);
            countreplies = 0;
            countsuccesses = 0;
            var url = gon.upload_file_url;

            var fileBeingUploaded = $("#filebeinguploaded");
            fileBeingUploaded.text("Initiating...");
            for (var i = 0; i < filesToUpload.length; i++) {
                var formData = new FormData();
                formData.append('file', filesToUpload[i]);
                formData.append('filename', filesToUpload[i].name);
                formData.append('album_path', fileDestinationFolder);
                $.ajax({
                    url: url,
                    data: formData,
                    contentType: false,
                    processData: false,
                    type: 'POST',
                    success: postProcessStep2Success,
                    fail: postProcessStep2Failure
                })
            }
        } else {
            alert("You must select an upload location first");
        }
    };

    $("#uploadfilesbutton").on("click", performstep2);

    postProcessStep2Success = function (responseData) {
        countreplies++;

        var fileDestinationFolder = $("#filedeststep2").text();
        var progressBarStepTwo = $("#progressbarstep2");
        var percentCompleteStepTwo = $("#percentcompletestep2");
        var fileBeingUploaded = $("#filebeinguploaded");

        var answer = (responseData.success ? "Success" : "Failure")
            + " for " + responseData.filename;
        fileBeingUploaded.text(answer);
        if (responseData.success) countsuccesses++;
        progressBarStepTwo.prop('max', filesToUpload.length);
        if (progressBarStepTwo.val() < countsuccesses) {
            progressBarStepTwo.val(countsuccesses);
            percentCompleteStepTwo.text(Math.round(100.0 * countsuccesses / filesToUpload.length) + "%");
        }

        // Handle the final reply
        if (countreplies === filesToUpload.length) {
            $.post(gon.after_upload_files_url, {album: {path: fileDestinationFolder}})
                .done(function (response) {
                    console.log(response);
                    setTimeout(function () {
                        alert("Upload attempts: " + filesToUpload.length
                            + "\nReplies from server: " + countreplies
                            + "\nSuccessful transfers: " + countsuccesses)
                        progressBarStepTwo.addClass("hidden");
                        progressBarStepTwo.val(0);
                        percentCompleteStepTwo.addClass("hidden");
                        percentCompleteStepTwo.text("0%");
                        fileBeingUploaded.text("");
                        $("#addfilesbutton").prop("disabled", false);
                        $("#removefilesbutton").prop("disabled", false);
                        $("#uploadfilesbutton").prop("disabled", false);
                        window.location.href = '/album_thumbs'+ '/' + response.album_id.toString();
                    }, 500);
                });
        }
    };

    postProcessStep2Failure = function (jqXHR, textStatus, errorThrown) {
        alert("Received error '" + jqXHR.statusText + "' from server (HTTP Status: " + jqXHR.status + ").");
    };

    function addfiles(event) {  // Pertains to STEP 2 adding files to option list
        event.preventDefault();
        var uploadfilelist = $("#fileselector");
        var filestoadd = event.currentTarget.files;
        for (var i = 0; i < filestoadd.length; i++) {
            var isimageorvideo = (filestoadd[i].type.indexOf("image/") > -1) || (filestoadd[i].type.indexOf("video/") > -1);
            var isnotonfilelist = (filesToUpload.filter(function (value) {
                return (value.name === filestoadd[i].name)
            }).length === 0);
            if (isimageorvideo && isnotonfilelist) {
                var filetoobig = (filestoadd[i].size > gon.max_upload_size);
                var fileText = filestoadd[i].name + (filetoobig ? " - will not upload - too large" : "");
                var fileValue = (!filetoobig ? filestoadd[i].name : "toobig");  //  If file too large, file can't be uploaded or removed from filesToUpload
                var addedfileoption = "<option value=\"" + fileValue + "\">" + fileText + "</option>";
                uploadfilelist.append(addedfileoption);
                if (!filetoobig) filesToUpload.push(filestoadd[i]);
            }
        }
        $("#uploadfilesbutton").prop("disabled", (filesToUpload.length < 1));
    }

    function removefiles(event) {  // Pertains to STEP 2 removing files from option list
        event.preventDefault();
        var uploadFileSelector = $("#fileselector");
        var filesToRemoveOptions = uploadFileSelector.children("option:selected");

        filesToRemoveOptions.each(function () {  // Removes files from actual upload list
            var currentRemovalOption = $(this);
            if (currentRemovalOption.val() !== "toobig") {  //  Files that are too large are not on filesToUpload list so cannot be removed from that list
                filesToUpload.splice(filesToUpload.indexOf(filesToUpload.filter(function (value) {
                    return (value.name === currentRemovalOption.val());
                })[0]), 1);
            }
        });
        filesToRemoveOptions.remove();
        $("#uploadfilesbutton").prop("disabled", (filesToUpload.length < 1));
    }

    function changetabs(forcetabnumber) {
        if (forcetabnumber <= step) {
            for (var i = 1; i <= 2; i++) {
                var thisTab = $("#step-" + i + "-tab").parent();
                var tabContent = $("#step-" + i);
                if (i === forcetabnumber) {
                    thisTab.addClass("active");
                    tabContent.addClass("active");
                } else {
                    thisTab.removeClass("active");
                    tabContent.removeClass("active");
                }
            }
        } else {
            alert("You must complete prior step first");
            changetabs(1)
        }
    }

    $("li a#step-1-tab").on("click", function () {
        changetabs(1)
    });
    $("li a#step-2-tab").on("click", function () {
        changetabs(2)
    });

});
