$(document).ready(function () {
    var step = 1;      //  Step in process
    var pathname_notallowed = new RegExp("[\\\\?%&\\*:|\"<>\\.]", "g"); // Characters /\?%&*:|"<>.
    var newfoldername = "";
    var existingFolderRoot = "";
    var compositeFolderPath = "";
    var aNewFolderIsDesired = false;
    var filesToUpload = [];
    var fullresolist = [];
    var countsuccesses = 0;
    var countreplies = 0;
    var newFolderButton = $("#newfolderbutton");
    newFolderButton.prop("disabled", true);

    $("#newfoldercheckbox").on("change", function () {
        step = 1;  //  If clicked, this reverts back to step 1
        prepstep2('off');  // Now a new destination folder is being chosen so must block out file upload section
        prepstep3('off');  // Now a new destination folder is being chosen so must block out file resolution section
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
        prepstep3("off");  // Now a new destination folder is being chosen so must block out file resolution section
        if (aNewFolderIsDesired) {
            if (existingFolderRoot) {  // Check if anything was typed in yet
                compositeFolderPath = existingFolderRoot + "/" + newfoldername + "/images/full";
                $("#uploaddest").text(compositeFolderPath).css("color", "black");
                $("#newfolderbutton").prop("disabled", false)
            } else {
                $("#uploaddest").text("<Please select an existing parent folder>").css("color", "red");
                $("#newfolderbutton").prop("disabled", true)
            }
        } else {
            compositeFolderPath = existingFolderRoot + "/images/full";
            $("#uploaddest").text(compositeFolderPath);
            $("#newfolderbutton").prop("disabled", false)
        }
    };

    $("#newfolderinput").on("input", constructFolderName);
    $("#pickedfolder").on("change", constructFolderName);

    performstep1 = function performstep1(event) {  // Routine to set up a new or current destination folder for uploaded images
        if (event.preventDefault) event.preventDefault(); else event.returnValue = false; // event.preventDefault() not available in MSIE
        var albumData = {
            "newFolder": existingFolderRoot,
            "albumName": $("#album-name").val(),
            "albumDescription": $("#album-description").val()
        };

        //  Determine if we are dealing with new or existing folder situation
        if (aNewFolderIsDesired) {       //  New folder situation requires creation of new folders on server
            var matchingFolderOptions = $("#pickedfolder").find("option").filter(function () {
                return $(this).val().toLowerCase() == compositeFolderPath.replace("/images/full", "").toLowerCase();
            });
            var newfolderexists = (matchingFolderOptions.length > 0);
            if (!newfolderexists) {
                albumData["newFolder"] = compositeFolderPath.replace("/images/full", "");
                $.post(gon.create_folders_url, albumData)
                    .done(postProcessStep1Success)
                    .fail(postProcessStep1Failure);
            } else {  // New folder already exists
                alert("The entered new folder already exists");
                $("#newfolderinput").val("");
                $("#newfolderbutton").prop("disabled", true);
                newfoldername = "";
            }
        } else {
            $.post(gon.set_album_meta_url, albumData)
                .done(function () {
                    step = 2;
                    alert("Using folder " + existingFolderRoot + ".\nProceed to STEP 2...");
                    $("#filedeststep2").text(existingFolderRoot + "/images/full").removeClass("hidden");
                    prepstep2("on");  // Now full resolution file folder has been changed - enable file upload section
                    prepstep3("on");  // Now full resolution file folder has been changed - must rescan folders for file resolution section
                    changetabs(2);
                })
                .fail(postProcessStep1Failure);
        }
    };

    newFolderButton.on("click", performstep1);

    postProcessStep1Success = function (responseData) {
        var createdFolderRoot = responseData.created_folder_root;
        alert("Created folders under " + createdFolderRoot + " successfully.\nProceed to STEP 2...");
        step = 2;
        //  Put new folder in option list
        var option = "<option value=\"" + createdFolderRoot + "\">" + createdFolderRoot.replace(gon.base_photo_path + "/", "") + "</option>";
        $("#pickedfolder").append(option);
        $("#filedeststep2").text(createdFolderRoot + "/images/full").removeClass("hidden");
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
                formData.append('newFolder', fileDestinationFolder);
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

        var progressBarStepTwo = $("#progressbarstep2");
        var percentCompleteStepTwo = $("#percentcompletestep2");
        var fileBeingUploaded = $("#filebeinguploaded");

        var answer = (responseData.success ? "Success" : "Failure")
            + " for " + responseData.filename
            + (responseData.overwritten ? " - Already on server" : "");
        fileBeingUploaded.text(answer);
        if (responseData.success) countsuccesses++;
        progressBarStepTwo.val(countsuccesses);
        percentCompleteStepTwo.text(Math.round(100 * countsuccesses / filesToUpload.length) + "%");

        // Handle the final reply
        if (countreplies === filesToUpload.length) {
            step = 3;
            alert("Upload attempts: " + filesToUpload.length
                + "\nReplies from server: " + countreplies
                + "\nSuccessful transfers: " + countsuccesses
                + "\n\nProceed to STEP 3...");
            progressBarStepTwo.addClass("hidden");
            progressBarStepTwo.value = 0;
            percentCompleteStepTwo.addClass("hidden");
            percentCompleteStepTwo.text("0%");
            fileBeingUploaded.text("");
            $("#addfilesbutton").prop("disabled", false);
            $("#removefilesbutton").prop("disabled", false);
            $("#uploadfilesbutton").prop("disabled", false);
            prepstep3("on");
            changetabs(3);
        }
    };

    postProcessStep2Failure = function (jqXHR, textStatus, errorThrown) {
        alert("Received error '" + jqXHR.responseJSON.statusText + "' from server (HTTP Status: " + jqXHR.status + ").");
    };

    function prepstep3(onoroff) {
        var resolutionsContainer = $("#resocontainer");
        var fileSourceStepThree = $("#filesourcestep3");
        switch (onoroff) {  //  Set or clear all STEP 3 elements
            case 'on':
                if (fileSourceStepThree.text() !== "") prepstep3("off");  //  Must clear list if list was not empty
                var step3sourcepath = $("#filedeststep2").text();
                fileSourceStepThree.text(step3sourcepath);
                fileSourceStepThree.removeClass("hidden");
                resolutionsContainer.removeClass("hidden");
                $("#reso-filelist-pre-header").removeClass("hidden");
                $("#reso-filelist-post-header").addClass("hidden");

                var url = gon.full_res_files_url
                    + "?newFolder="
                    + encodeURIComponent(step3sourcepath.replace("/images/full", ""));
                $.get(url)
                    .done(prepStep3PostProcessingSuccess)
                    .fail(prepStep3PostProcessingFailure);
                break;
            case 'off':
                fileSourceStepThree.text("");
                $("#resotbody").empty();
                resolutionsContainer.addClass("hidden");
                $("#progressbarstep3").val(0);
                $("#percentcompletestep3").text("0%");
                fullresolist = [];
                break;
            default:
                break;
        }
    }

    function selectPhotosResosNotComplete(event) {
        if (event) event.preventDefault();
        $("#resotbody tr").each(function () {
            var rowNotComplete = $(this).find("td[data-description]").text().length < 4;
            $(this).find("td>input").prop("checked", rowNotComplete);
        });
    }

    function selectAllResosPhotosYesOrNo(event, select) {
        event.preventDefault();
        $("#resotbody tr input").prop("checked", select);
    }

    $("#select-resos-button-incomplete").on("click", selectPhotosResosNotComplete);
    $("#select-resos-button-all").on("click", function (event) {
        selectAllResosPhotosYesOrNo(event, true)
    });

    $("#select-resos-button-none").on("click", function (event) {
        selectAllResosPhotosYesOrNo(event, false)
    });

    prepStep3PostProcessingSuccess = function (responseData) {
        var resotbody = $("#resotbody");
        fullresolist = responseData;
        fullresolist.forEach(function (fileMeta) {
            var onerow = "<tr data-description=\""
                + fileMeta.path + "\">"
                + "<td><input type=\"checkbox\"/ value=\"1\" class=\"checkbox\" checked /></td>"
                + "<td class=\"text-center\">"
                + fileMeta.filename
                + "</td>"
                + "<td  class=\"text-center\" data-description=\"large\">"
                + ((fileMeta.resolutions.large) ? String.fromCharCode(0x2713) : "")
                + "</td>"
                + "<td  class=\"text-center\" data-description=\"medium\">"
                + ((fileMeta.resolutions.medium) ? String.fromCharCode(0x2713) : "")
                + "</td>"
                + "<td  class=\"text-center\" data-description=\"small\">"
                + ((fileMeta.resolutions.small) ? String.fromCharCode(0x2713) : "")
                + "</td>"
                + "<td  class=\"text-center\" data-description=\"thumb\">"
                + ((fileMeta.resolutions.thumb) ? String.fromCharCode(0x2713) : "")
                + "</td>"
                + "</tr>";
            resotbody.append(onerow);
        });
        selectPhotosResosNotComplete(null);
        if (fullresolist.length > 0) $("#genresosbutton").prop("disabled", false);  // Enable button to generate files
    };

    prepStep3PostProcessingFailure = function (responseData) {
        alert("Received error '" + responseData.statusText + "' from server (HTTP Status: " + responseData.status + ").");
    };

    performstep3 = function performstep3(event) {  // Routine to generate reduced resolution files from full resolution files
        event.preventDefault();
        var step3sourcepath = $("#filesourcestep3").text();
        if (step3sourcepath !== "") {
            var numberOfSelectedFiles = $("#resotbody").find("tr").find("input:checked").length;
            if (fullresolist.length > 0 && numberOfSelectedFiles > 0) {
                var progressBarStepThree = $("#progressbarstep3");
                progressBarStepThree.removeClass("hidden");
                progressBarStepThree.prop("max", numberOfSelectedFiles);
                progressBarStepThree.val(0);
                var percentCompleteStepThree = $("#percentcompletestep3");
                percentCompleteStepThree.removeClass("hidden");
                percentCompleteStepThree.text("0%");
                $("#reso-filelist-pre-header").addClass("hidden");
                $("#reso-filelist-post-header").removeClass("hidden");
                $("#genresosbutton").prop("disabled", true);
                countreplies = 0;
                countsuccesses = 0;
                fullresolist.forEach(function (fileMeta) {
                    var rowSelector = "tr[data-description=\"" + fileMeta.path + "\"] input";
                    if (!$(rowSelector).prop("checked")) return;
                    var url = gon.resize_file_url;
                    var data = {
                        "newFolder": step3sourcepath,
                        "filename": fileMeta.filename  // Encode ampersands in filename
                    };
                    $.post(url, data)
                        .done(postProcessStep3Success)
                        .fail(postProcessStep3Failure);
                })
            } else {
                alert("No full resolution files selected to process.");
            }
        } else {
            alert("You must first establish a source path for full resolution files.");
        }
    };

    $("#genresosbutton").on("click", performstep3);

    postProcessStep3Success = function (responseData) {
        countreplies++;  // Counts replies from server even if response is an error state from the server

        var resotbody = $("#resotbody");
        var progressBarStepThree = $("#progressbarstep3");
        var percentCompleteStepThree = $("#percentcompletestep3");
        var rowSelector = "tr[data-description=\"" + responseData.sourcefile + "\"]";

        for (var resolution in responseData.results) {
            if (!responseData.results.hasOwnProperty(resolution)) continue;
            var answers = responseData.results[resolution];
            if (answers.success) countsuccesses++;  // Successes only accumulate for valid server replies
            var content = (answers.success) ? String.fromCharCode(0x2713) : "";
            content += (answers.overwritten && !!content) ? "|o" : "";
            selector = rowSelector + ">td[data-description=\"" + resolution + "\"]";
            $(selector).text(content);
        }

        progressBarStepThree.val(countreplies);
        var numberOfSelectedFiles = resotbody.find("tr").find("input:checked").length;
        var percentcomplete = countreplies / numberOfSelectedFiles;
        percentCompleteStepThree.text(Math.round(100 * percentcomplete) + '%');

        // Handle the final reply
        if (countreplies === numberOfSelectedFiles) {
            if ((countreplies * 4) === countsuccesses) {  // This indicates all server replies were valid ones
                step = 4;
                alert("Requests sent to server: " + numberOfSelectedFiles
                    + "\nReplies from server: " + countreplies
                    + "\nSuccessful files generated: " + countsuccesses + " of " + (4 * countreplies) + " possible"
                    + "\n\nUpload processes all completed!");
            } else { // Some server replies were invalid - some files did not get generated so stay on this step
                alert("Requests sent to server: " + numberOfSelectedFiles
                    + "\nReplies from server: " + countreplies
                    + "\nSuccessful files generated: " + countsuccesses + " of " + (4 * countreplies) + " possible"
                    + "\n\nCheck table below for results")
            }
            progressBarStepThree.addClass("hidden");
            progressBarStepThree.val(0);
            percentCompleteStepThree.addClass("hidden");
            percentCompleteStepThree.text("0%")
        }
    };

    postProcessStep3Failure = function (jqXHR, textStatus, errorThrown) {
        alert("Received error '" + jqXHR.responseJSON.statusText + "' from server (HTTP Status: " + jqXHR.status + ").")
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
            for (var i = 1; i <= 3; i++) {
                var thisTab = $("#step-" + i + "-tab").parent();
                var tabContent = $("#step-" + i);
                if (i == forcetabnumber) {
                    thisTab.addClass("active");
                    tabContent.addClass("active");
                } else {
                    thisTab.removeClass("active");
                    tabContent.removeClass("active");
                }
            }
        } else {
            alert("You must complete prior steps first");
            changetabs(step)
        }
    }

    $("li a#step-1-tab").on("click", function () {
        changetabs(1)
    });
    $("li a#step-2-tab").on("click", function () {
        changetabs(2)
    });
    $("li a#step-3-tab").on("click", function () {
        changetabs(3)
    });

});
