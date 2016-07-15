$(document).ready(function () {
    var step = 1;      //  Step in process
    var input_notallowed = new RegExp("[<>\"%{};]", "g");                // Characters <>"%{};
    var pathname_notallowed = new RegExp("[\\\\?%&\\*:|\"<>\\.]", "g"); // Characters /\?%&*:|"<>.
    var newfoldername = "";
    var existingFolderRoot = "";
    var compositeFolderPath = "";
    var aNewFolderIsDesired = false;
    var filesToUpload = [];
    var fullresolist = [];
    var xmlmenu;
    var callback = function () {
    };
    var uploadform;
    var countsuccesses = 0;
    var countreplies = 0;
    var newFolderButton = $("#newfolderbutton");
    newFolderButton.prop("disabled", true);

    $("#newfoldercheckbox").on("change", function () {
        step = 1;  //  If clicked, this reverts back to step 1
        prepstep2('off');  // Now a new destination folder is being chosen so must block out file upload section
        prepstep3('off');  // Now a new destination folder is being chosen so must block out file resolution section
        prepstep4('off');  // Now full resolution file folder has been changed - must re-display folder name for album naming section
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
        newfoldername = $("#newfolderinput").val().replace(pathname_notallowed, "");
        existingFolderRoot = $("#pickedfolder").val();
        step = 1;  //  If parent folder is selected or new folder name entered, this reverts back to step 1
        prepstep2("off");  // Now a new destination folder is being chosen so must block out file upload
        prepstep3("off");  // Now a new destination folder is being chosen so must block out file resolution section
        prepstep4("off");  // Now full resolution file folder has been changed - must re-display folder name for album naming section
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
        //  Determine if we are dealing with new or existing folder situation
        if (aNewFolderIsDesired) {       //  New folder situation requires creation of new folders on server
            var matchingFolderOptions = $("#pickedfolder option").filter(function () {
                return $(this).val().toLowerCase() == compositeFolderPath.replace("/images/full", "").toLowerCase();
            });
            var newfolderexists = (matchingFolderOptions.length > 0);
            if (!newfolderexists) {
                var url = gon.create_folders_url;
                $.post(url, {"newFolder": compositeFolderPath.replace("/images/full", "")})
                    .done(postProcessStep1Success)
                    .fail(postProcessStep1Failure)
            } else {  // New folder already exists
                alert("The entered new folder already exists");
                $("#newfolderinput").val("");
                $("#newfolderbutton").prop("disabled", true);
                newfoldername = "";
            }
        } else {  //  Existing folder situation does not require creation of new folders on server
            if (compositeFolderPath !== "") {
                step = 2;
                alert("Using folder " + existingFolderRoot + ".\nProceed to STEP 2...");
                $("#filedeststep2").text(existingFolderRoot + "/images/full").removeClass("hidden");
                prepstep2("on");  // Now full resolution file folder has been changed - enable file upload section
                prepstep3("on");  // Now full resolution file folder has been changed - must rescan folders for file resolution section
                prepstep4("on");  // Now full resolution file folder has been changed - must re-display folder name for album naming section
                changetabs(2);
            }
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
        prepstep3("on");  // Now full resolution file folder has been changed - must rescan folders for file resolution section
        prepstep4("on");  // Now full resolution file folder has been changed - must re-display folder name for album naming section
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

    prepStep3PostProcessingSuccess = function (responseData) {
        var resotbody = $("#resotbody");
        fullresolist = responseData;
        fullresolist.forEach(function (fileMeta) {
            var onerow = "<tr data-description=\""
                + fileMeta["path"] + "\"><td class=\"text-center\">"
                + fileMeta["filename"]
                + "</td>"
                + "<td  class=\"text-center\" data-description=\"large\"></td>"
                + "<td  class=\"text-center\" data-description=\"medium\"></td>"
                + "<td  class=\"text-center\" data-description=\"small\"></td>"
                + "<td  class=\"text-center\" data-description=\"thumb\"></td>"
                + "</tr>";
            resotbody.append(onerow);
        });
        if (fullresolist.length > 0) $("#genresosbutton").prop("disabled", false);  // Enable button to generate files
    };

    prepStep3PostProcessingFailure = function (responseData) {
        alert("Received error '" + responseData.statusText + "' from server (HTTP Status: " + responseData.status + ").");
    };

    performstep3 = function performstep3(event) {  // Routine to generate reduced resolution files from full resolution files
        var step3sourcepath = $("#filesourcestep3").text();
        if (step3sourcepath !== "") {
            if (fullresolist.length > 0) {
                var progressBarStepThree = $("#progressbarstep3");
                progressBarStepThree.removeClass("hidden");
                progressBarStepThree.prop("max", fullresolist.length);
                progressBarStepThree.val(0);
                var percentCompleteStepThree = $("#percentcompletestep3");
                percentCompleteStepThree.removeClass("hidden");
                percentCompleteStepThree.text("0%");
                $("#genresosbutton").prop("disabled", true);
                countreplies = 0;
                countsuccesses = 0;
                fullresolist.forEach(function (fileMeta) {
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
                alert("No full resolution files to process.");
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
        var percentcomplete = countreplies / fullresolist.length;
        percentCompleteStepThree.text(Math.round(100 * percentcomplete) + '%');

        // Handle the final reply
        if (countreplies === fullresolist.length) {
            if ((countreplies * 4) === countsuccesses) {  // This indicates all server replies were valid ones
                step = 4;
                alert("Requests sent to server: " + fullresolist.length
                    + "\nReplies from server: " + countreplies
                    + "\nSuccessful files generated: " + countsuccesses + " of " + (4 * countreplies) + " possible"
                    + "\n\nProceed to STEP 4...");
                changetabs(4)
            } else { // Some server replies were invalid - some files did not get generated so stay on this step
                alert("Requests sent to server: " + fullresolist.length
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

    function prepstep4(onoroff) {
        //  xml file structure is:
        //
        //    <div id="smooth-menu"  style="background-color: #F0F0F0"  >
        //        <ul>
        //            <li>
        //                <a href="#">Top level menu item displayed</a>
        //                <ul class="second-level">
        //                    <li>
        //                        <a  title="" href="PHP code with folder name">Submenu item displayed</a>
        //                    </li>
        //                        ..
        //                        ..
        //                        ..
        //                    <li>
        //                        <a  title="" href="PHP code with folder name">Submenu item displayed</a>
        //                    </li>
        //                </ul>
        //            </li>
        //                ..
        //                ..  more top level menu items
        //                ..
        //        </ul>
        //    </div>

        switch (onoroff) {  //  Set or clear all STEP 3 elements
            case 'on':
                var step4sourcepath = $("#filedeststep2").innerHTML;
                $("#filedeststep4").innerHTML = step4sourcepath;
                $("#filedeststep4").removeClass("hidden");
                $("#albumnamecontainer").removeClass("hidden");
                $("#newmenuinputdiv").addClass("hidden");  // Clear new first level menu entry items
                $("#newmenuinput").val("");
                $("#addmenubutton").prop("disabled", true);
                $("#newmenuitemcheckbox").prop("checked", false);
                var url = gon.photo_upload_page_url + "?substep=fetchalbummenu";
                callback = function (return_msg) {
                    var parser = new DOMParser();
                    return_msg = add_or_remove_escape_chars(return_msg, "remove");
                    xmlmenu = parser.parseFromString(return_msg, "text/xml");
                    update_option_menulist("");  // Add top level menu items from xmlmenu to displayed option list
                };
                // makeHTTPrequest(url, "GET", "SYNC");  // Must be synchronous request since prep STEP 3 is also making a request with a different callback fxn
                break;
            case 'off':
                $("#filedeststep4").innerHTML = "";
                $("#albumnamecontainer").addClass("hidden");
                break;
            default:
                break;
        }
    }

    function performstep4(event, userid) {  // Routine to create new albums on album submenus
        var step4sourcepath = $("#filedeststep4").innerHTML.replace("/full", "").replace(/'/g, "\\'");
        if (step4sourcepath !== "") {
            var selectedoptions = new Array();
            var menulist = $("#menuselector");
            if (menulist.selectedOptions == null) {  // Firefox has no selectedOptions method
                for (var i = 0; i < menulist.length; i++) {
                    if (menulist[i].selected) selectedoptions.push(menulist[i]);
                }
            } else {
                selectedoptions = menulist.selectedOptions;
            }
            var newalbumname = $("#newalbumname").value.replace(input_notallowed, "");
            var newalbumdesc = $("#newalbumdesc").value.replace(input_notallowed, "");
            if ((selectedoptions.length > 0) && (newalbumname !== "")) {
                for (var i = 0; i < selectedoptions.length; i++) {      // Loop through the selected top level menu option items and update xmlmenu
                    var oneoptionitemname = selectedoptions[i].innerHTML.replace(/&amp;/g, "##amp");  // InnerHTML returns &amp; for &
                    var atags = xmlmenu.getElementsByTagName("a");      // These are all of the "a" tags in the PHP album menu file
                    for (var j = 0; j < atags.length; j++) {            // Now we have only the first level "a" tags after this loop
                        // Find the top level menu node that matches the selected option menu item
                        if ((atags[j].getAttribute("href") === "#") && (atags[j].firstChild.nodeValue === oneoptionitemname)) {
                            var albumitemparent = atags[j].nextElementSibling; // This is the "ul" second class level
                            var submenuitem_li = xmlmenu.createElement("li");               // "li" goes under "ul" and "a" goes under "li"
                            var submenuitem_a = xmlmenu.createElement("a");
                            var submenuitem_atext = xmlmenu.createTextNode(add_or_remove_escape_chars(newalbumname, "remove"));
                            submenuitem_a.appendChild(submenuitem_atext);
                            submenuitem_a.setAttribute("title", add_or_remove_escape_chars(newalbumdesc, "remove"));
                            // var constructHref = "<" + "?php echo "myPicShow.php?folder=" + step4sourcepath + "&userid=' . $uid; ?" + ">";
                            constructHref = add_or_remove_escape_chars(constructHref, "remove");  // Make encoding same as rest of XML xmlmenu items
                            submenuitem_a.setAttribute("href", constructHref);
                            submenuitem_li.appendChild(submenuitem_a);
                            albumitemparent.appendChild(submenuitem_li);
                            break;  // Move on to next selected option
                        }
                    }
                }
                update_option_menulist();
                var xmlmenuupload = add_or_remove_escape_chars((new XMLSerializer()).serializeToString(xmlmenu), "add");

                var parser = new DOMParser();
                var xmlmediagroupdata =
                    parser.parseFromString("<" + "?xml version=\"1.0\"?" + "><mediaGroup><groupInfo><custom></custom></groupInfo></mediaGroup>", "text/xml");
                var customnode = xmlmediagroupdata.getElementsByTagName("custom")[0];
                customnode.appendChild(xmlmediagroupdata.createElement("groupTitle")).appendChild(xmlmediagroupdata.createTextNode(newalbumname));
                customnode.appendChild(xmlmediagroupdata.createElement("groupDescription")).appendChild(xmlmediagroupdata.createTextNode(newalbumdesc));
                var xmlmediagroupdataupload = (new XMLSerializer()).serializeToString(xmlmediagroupdata);

                var mediagroupdatafile = step4sourcepath.replace("/images", "");
                mediagroupdatafile = mediagroupdatafile.replace(/\\'/g, "'");  // Put apostrophe back for xml mediagroupdata file

                uploadform = new FormData();
                uploadform.append("step", 4);
                uploadform.append("substep", "uploadxml");
                uploadform.append("userid", userid);
                uploadform.append("xmlmenu", new Blob([xmlmenuupload], {type: "text/xml"}), "xmlmenufile.xml");
                uploadform.append("path", mediagroupdatafile);
                uploadform.append("xmlmediagroupdata", new Blob([xmlmediagroupdataupload], {type: "text/xml"}), "xmlmediagroupdatafile.xml");

                var url = gon.photo_upload_page_url;
                callback = function (return_msg) {
                    answers = return_msg.split("|");  // answer is wrote menudata success 0 or 1|wrote mediaGroupData file success 0 or 1
                    alert("Wrote updated album menu to server "
                        + ((answers[0] === "0") ? "un" : "") + "successfully"
                        + "\n\nWrote updated mediaGroupData file server "
                        + ((answers[1] === "0") ? "un" : "") + "successfully"
                        + "\n\nYou may now go to the home page to view the updated menu");
                };
                // makeHTTPrequest(url, "POST");
            } else {
                alert("You must select at least one top level menu items and enter an album name");
            }
        } else {
            alert("You must have a destination folder to associate with an album name");
        }
    }

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

    function addmenuitem() {  // Pertains to STEP 4 adding a first level menu item to list
        var newMenuInput = $("#newmenuinput");
        var newmenuname = add_or_remove_escape_chars(newMenuInput.val(replace(input_notallowed, "")), "remove");
        if (newmenuname !== "") {
            // First get the top "ul" tag and all its "li" children that hold the top level menu items and text nodes
            var top_ul_node = xmlmenu.firstChild.firstChild.nextSibling;        // Top "ul" tag node
            var menu_li_items = top_ul_node.childNodes;                         // These are the "li" and text nodes under the top "ul" tag

            // Check to see if entered name is already listed (the firstChild of the "a" tag node is the text node for the "a" tag)
            var top_menu_li_elements = Array.prototype.slice.call(menu_li_items);   // First convert nodelist to array so we can use filter method
            top_menu_li_elements = top_menu_li_elements.filter(function (value) {
                return (value.nodeName === "li")
            });  // Exclude the text nodes

            if (top_menu_li_elements.filter(function (value) {
                    return (value.firstChild.textContent === newmenuname)
                }).length === 0) {  // Test if name is new
                var topmenuitem_li = xmlmenu.createElement("li");               // Establish top level menu node items
                var topmenuitem_litext = xmlmenu.createTextNode("");            // Text node for "li"
                var topmenuitem_a = xmlmenu.createElement("a");                 // "a" and "ul" are siblings and are children of "li"
                var topmenuitem_atext = xmlmenu.createTextNode(newmenuname);    // Text node for "a"
                var topmenuitem_ul = xmlmenu.createElement("ul");
                topmenuitem_a.setAttribute("href", "#");
                topmenuitem_a.appendChild(topmenuitem_atext);
                topmenuitem_ul.setAttribute("class", "second-level");

                topmenuitem_li.appendChild(topmenuitem_a);                      // Make "a" and "ul" children of "li"
                topmenuitem_li.appendChild(topmenuitem_ul);

                // Find index of i on top level menu items list that should follow new entry
                var i = 1;
                while ((i < menu_li_items.length) && (newmenuname > menu_li_items[i].firstChild.firstChild.nodeValue)) i += 2;
                if (i === menu_li_items.length) {
                    top_ul_node.appendChild(topmenuitem_li);                        // Put this structure under the first "ul" tag at end of "li's"
                    top_ul_node.appendChild(topmenuitem_litext);                    // Add text node as well
                } else {
                    top_ul_node.insertBefore(topmenuitem_li, menu_li_items[i]);     // Put this structure in front of node having higher alphabetical text
                    top_ul_node.insertBefore(topmenuitem_litext, menu_li_items[i + 1]);   // Add text node as well
                }
                update_option_menulist(add_or_remove_escape_chars(newmenuname, "add"));     // Update displayed option list from xmlmenu
                alert("Added new top level menu item \"" + add_or_remove_escape_chars(newmenuname, "add") + "\"");
                $("#newmenuinputdiv").style.display = "none";    // Clear new first level menu entry items
                newMenuInput.value = "";
                $("#newmenuitemcheckbox").checked = false;
                $("#createalbumbutton").disabled = false;
                $("#menuselector").focus();
            } else {
                alert("That name is already on the list - Please choose another");
                newMenuInput.focus();
            }
        } else {
            alert("Please enter a new menu item name");
            newMenuInput.focus();
        }
    }

    function update_option_menulist(newmenuname) {  // Pertains to STEP 4 updating the top level menu displayed option list
        // Function parameter is string representing option item that should be highlighted as selected at end of creating new option list
        var menu_li_items = xmlmenu.getElementsByTagName("ul")[0].children;
        var selectorlist = $("#menuselector");         // The displayed option list
        while (selectorlist.hasChildNodes()) selectorlist.removeChild(selectorlist.childNodes[0]);  // Empty the list
        for (var i = 0; i < menu_li_items.length; i++) {
            var optionitem = document.createElement("option");                          // Now add new top level menu item to option list
            var menuitemtext = menu_li_items[i].firstChild.firstChild.nodeValue;        // The firstChild of the "li" tag is the "a" tag
            optionitem.value = add_or_remove_escape_chars(menuitemtext, "add");         //  and the firstChild of the "a" tag is "a's" text
            optionitem.innerHTML = add_or_remove_escape_chars(menuitemtext, "add");

            var optiontitles = "";
            var submenutags = menu_li_items[i].children[1].getElementsByTagName("li");  //  menu_li_items[i].children[1] is second level "ul" tag
            for (var j = 0; j < submenutags.length; j++) {
                // Construct physical folder name from a tag's href for hover information on menu item
                albumfolderfromhref = decodeURI(add_or_remove_escape_chars(submenutags[j].firstChild.getAttribute("href"), "add"));
                albumfolderfromhref = albumfolderfromhref.substring(albumfolderfromhref.search("=gallery") + 9, albumfolderfromhref.search("/images&"));
                optiontitles += submenutags[j].firstChild.firstChild.nodeValue + " (";  //  "a" tag for submenu item is under "ul" tag (firstChild)
                optiontitles += albumfolderfromhref + ")\n";                            //  and the firstChild of the "a" tag is the text node
            }
            optionitem.title = add_or_remove_escape_chars(optiontitles, "add").replace(/\\/g, "");

            if (optionitem.value === newmenuname) optionitem.selected = true;           // Select the new item if present
            selectorlist.appendChild(optionitem);
        }
    }

    function add_or_remove_escape_chars(inputstr, addorremove) {
        switch (addorremove) {
            case "add":
                inputstr = inputstr.replace(/##lt\?php/g, "<" + "?php");
                inputstr = inputstr.replace(/\?##gt/g, "?" + ">");
                inputstr = inputstr.replace(/##amp/g, "&");
                break;
            case "remove":
                inputstr = inputstr.replace(/<\?php/g, "##lt?php");
                inputstr = inputstr.replace(/\?>/g, "?##gt");
                inputstr = inputstr.replace(/&/g, "##amp");
                break;
        }
        return inputstr;
    }

    function changetabs(forcetabnumber) {
        if (forcetabnumber <= step) {
            for (var i = 1; i <= 4; i++) {
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
    };

    $("li a#step-1-tab").on("click", function () {
        changetabs(1)
    });
    $("li a#step-2-tab").on("click", function () {
        changetabs(2)
    });
    $("li a#step-3-tab").on("click", function () {
        changetabs(3)
    });
    $("li a#step-4-tab").on("click", function () {
        changetabs(4)
    });

});
