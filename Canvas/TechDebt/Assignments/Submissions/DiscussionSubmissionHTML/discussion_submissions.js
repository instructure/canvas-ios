//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//


function load(method,param1,param2) {
    window.location = "speedgrader://speedgrader/" + method + "sgmethodcomponents/" + param1 + "sgmethodcomponents/" + param2;
}

function stopAllMedia() {
    var videos = document.getElementsByTagName('video');
    for (var i = 0; i < videos.length; i++) {
        var video = videos[i];
        video.pause();
    }
    
    // YouTube currently doesn't have api support for their iframe. lamewads.
    // When they do, pause the video here.
    // Oh, and implement pausing of vimeo as well. They currently don't play in iOS. lamewads.
}

/*
2010-11-08 11:58:06.174 SpeedGrader[22797:40b] Discussion entry info: {
    "attachment_id" = "<null>";
    "created_at" = "2010-11-08T11:10:04-07:00";
    "deleted_at" = "<null>";
    "discussion_topic_id" = 64801;
    id = 46877;
    message = "<p>ohai. share your recipes.</p>";
    "migration_id" = "<null>";
    "parent_id" = 0;
    permissions =     {
        attach = 1;
        create = 1;
        delete = 1;
        read = 1;
        reply = 1;
        update = 1;
    };
    "updated_at" = "2010-11-08T11:10:04-07:00";
    "user_id" = 242527;
    "user_name" = "Mark Suman";
    "workflow_state" = active;
}
*/

function addEntry(entry) {
    var newEntry = document.createElement('div');
    newEntry.setAttribute("id", entry['internalIdent']);
    newEntry.setAttribute("class", "entry");
    
    var newEntryHeader = document.createElement('div');
    newEntryHeader.setAttribute("class", "header");
    
    var newTime = document.createElement('span');
    newTime.setAttribute("class", "posted_at");
    newTime.appendChild(document.createTextNode(entry['date']));
    newEntryHeader.appendChild(newTime);
    
    var newAuthor = document.createElement('div');
    newAuthor.setAttribute("class", "author");
    newAuthor.appendChild(document.createTextNode(entry['userName']));
    newEntryHeader.appendChild(newAuthor);
    
    newEntry.appendChild(newEntryHeader);
    
    var newEntryBody = document.createElement('p');
    newEntryBody.innerHTML = entry['entryMessage'];
    newEntry.appendChild(newEntryBody);
    
    var attachments = entry['attachments'];
    if (!attachments) {
        attachments = [];
    }
    for (var i=0; i<attachments.length; i++) {
        var attachment = attachments[i];
        var newAttachment = document.createElement('div');
        newAttachment.setAttribute("class", "attachment");
        var thingy = document.createElement('a');
        thingy.setAttribute("href", "javascript:load('displayAttachmentWithId'," + attachment['ident'] + ",'" + entry['internalIdent'] + "');");
        // var downloadImage = document.createElement('img');
        // downloadImage.setAttribute("src","images/download_arrow.png");
        // thingy.appendChild(downloadImage);
        thingy.appendChild(document.createTextNode(attachment['displayName']));
        newAttachment.appendChild(thingy);
        newEntry.appendChild(newAttachment);
    }
    
    var theEntries = document.getElementById('entries');
    theEntries.appendChild(newEntry);
    
    expandFileURLs(newEntry);
}

function loadThumbnailForMediaAttachment(attachment,url) {
    var mediaAttachment = document.getElementById(attachment['mediaId']);
    var thumbnail = document.createElement('img');
    thumbnail.setAttribute('src',url);
    mediaAttachment.innerHTML = '';
    mediaAttachment.appendChild(thumbnail);
}

function expandFileURLs(element) {
    var elementId = $(element).attr("id");
    $("#" + elementId + " .instructure_file_link").each(function(index,fileElement) {
        var fileName = $(fileElement).text();
        var fileURL = $(fileElement).attr("href");
        var fileId;
        var urlComponents = fileURL.split("/");
        for (var i=0; i<urlComponents.length; i++) {
            var component = urlComponents[i];
            if (component == "files") {
                fileId = urlComponents[i+1];
                break;
            }
        }
        
        var attachmentInfo = {"id":fileId,"filename":fileName,"relativeURL":fileURL,"index":index};
        
        var javascriptURL = 'javascript:load("displayAttachmentWithInfo","' + elementId + '",\'' + $.toJSON(attachmentInfo) + '\')';
        $(fileElement).attr("href",javascriptURL);
    });
}

function replaceFlashVideoObjects() {
    $("object").each(function() {
        var url;
        var mediaId;
        var width;
        var height;

        $(this).children("param").each(function(index,element) {
            var tempURL;
            if ($(element).attr("name") == "src") {
                tempURL = $(element).attr("value");
                if (tempURL.indexOf("youtube.com") != -1) {
                    type = "youtube";
                    url = tempURL;
                    return;
                }
                else if (tempURL.indexOf("vimeo.com") != -1) {
                    type = "vimeo";
                    url = tempURL;
                    return;
                }
            }
            else if ($(element).attr("name") == "movie") {
                tempURL = $(element).attr("value");
                if (tempURL.indexOf("vimeo.com") != -1) {
                    type = "vimeo";
                    url = tempURL;
                    return;
                }
            }
        });

        if (type) {
            mediaId = idFromURL(type,url);
            width = $(this).attr("width");
            height = $(this).attr("height");
            $(this).replaceWith(videoCode(type,mediaId,width,height));
        }

    });
}

function idFromURL(type,url) {
    if (type == "youtube") {
        return mediaId = youTubeIdFromURL(url);
    }
    else if (type == "vimeo") {
        return mediaId = vimeoIdFromURL(url);
    }
}

function videoCode(type,mediaId,width,height) {
    if (type == "youtube") {
        return youTubeVideoCode(mediaId,width,height);
    }
    else if (type == "vimeo") {
        return vimeoVideoCode(mediaId,width,height);
    }
}


// YouTube support

function youTubeIdFromURL(url) {
    // http://www.youtube.com/v/Q5im0Ssyyus?fs=1&amp;hl=en_US
    var split = url.split("?");
    return split[0].split("/").pop();
}

function youTubeVideoCode(mediaId,width,height) {
    return "<iframe class='youtube-player' type='text/html' width='" + width + "' height='" + height + "' src='http://www.youtube.com/embed/" + mediaId + "' frameborder='0''></iframe>";
}


// Vimeo support

function vimeoIdFromURL(url) {
    // http://vimeo.com/moogaloop.swf?clip_id=17891444&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=1&amp;color=00ADEF&amp;fullscreen=1&amp;autoplay=0&amp;loop=0
    var urlParts = url.split("?");
    var urlParams = urlParts[1].split("&");

    for (index in urlParams) {
        var param = urlParams[index];
        if (param.indexOf("clip_id=") == 0) {
            return param.split("=").pop();
        }
    }
}

function vimeoVideoCode(mediaId,width,height) {
    return "<iframe class='vimeo-player' src='http://player.vimeo.com/video/" + mediaId + "' width='" + width + "' height='" + height + "' frameborder='0'></iframe>";
}
