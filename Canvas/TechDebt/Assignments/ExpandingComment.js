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

var last;
var locked = false;

var imageCount = 0;

function getText() {
    var comment = $("#comment").clone();
    var images = $("#comment").find("img");
    for (i = 0; i < images.length; i++) {
        var attachmentId = $(images[i]).attr('data-image-number');
        if (attachmentId) {
            comment.find("#"+$(images[i]).attr("id")).replaceWith("##IMAGE" + attachmentId + "##");
        }
    }
    
    // trim leading and trailing whitespace
    var trimmedComment = comment.html().replace(/^\s*/, '').replace(/\s*$/, '');
    return trimmedComment;
};

function grabImageIndexes() {
    var indexes = [];
    $("img").each(function(index, image) {
        var number = $(image).attr('data-image-number');
        if (number) {
            indexes.push(number);
        }
    });
    return JSON.stringify(indexes);
};

function insertImage(pathToImage, height) {
        
    var image = createImageTag(pathToImage, height) + "<br><br>";
    
    imageCount++;
    
    var comment = $("#comment");
    if ($("#comment :last-child").is("br")) {
        if (isEmptyComment(comment)) {
            comment.html(image);
        } else {
            comment.append(image);
        }
    } else {
        image = image = "<br>" + image;
        comment.append(image);
    }

    $('html, body').animate({scrollTop: $(document).height()}, 'fast');
    
    return imageCount - 1;
};

function insertImageReplacingImage(pathToImage, imageToReplace, height) {
    var image = createImageTag(pathToImage, height);
    
    imageCount++;

    replaceInComment(imageToReplace, image);
    
    return imageCount - 1;
}

function replaceInComment(oldText, newText){
    var commentHtml = $("#comment").html().replace(oldText, newText);
    $("#comment").html(commentHtml);
}

function createImageTag(pathToImage, height) {
    return "<a href='preview://" + imageCount + "'><img id='image" + imageCount
            + "' data-image-number=" + imageCount + " class='attachment' src='"
            + pathToImage + "' width='85' height='" + height + "' /></a>";
}

function isEmptyComment(comment) {
    if (comment.find("img").length === 0 && comment.text().replace(/\s+/, "") === "") {
        return true;
    }
    return false;
}

function setInitialText(html) {
    if (html) {
        $("#comment").html(html+'<div></div>');
    }
}

$(document).ready(function() {
                  
    $("#comment").bind("DOMSubtreeModified", function() { 
        try {
            if (locked===true) return;                       
            var selection = window.getSelection();
            var comment = $("#comment");
            var me = comment.html();
            if (last===me) return; else last=me; // prevent needless computations if no changes to selection
            //if (selection.rangeCount==0) return;
                           
            locked = true;
            var top;
            var bottom;

            // An image was probably inserted, but there's no selection
            if (selection.rangeCount == 0) {
                bottom = comment.height();
                top = bottom - 20;
            } else {                
                var range = selection.getRangeAt(0);
                var rect = range.getClientRects()[0];
                if (rect) {
                    top = rect.top + document.body.scrollTop;;
                    bottom = rect.bottom + document.body.scrollTop;
                }
                else {
                    // This is just a dummy span for sizing purposes
                    var $span= $("<span>z</span>");

                    newRange = document.createRange();
                    newRange.setStart(selection.focusNode, range.startOffset);
                    newRange.insertNode($span[0]); // using 'range' here instead of newRange unselects or causes flicker on chrome/webkit
                    
                    rect = $span.get(0).getBoundingClientRect();
                    top = rect.top + document.body.scrollTop;
                    bottom = rect.bottom + document.body.scrollTop;
                    
                    $span.remove();
                }
            }

            // Inform the CKCommentInputView that the comment text has changed and indicate whether or not to enable the send button
            var iframe = document.createElement("iframe");
            if (isEmptyComment(comment)) {
                iframe.setAttribute("src", "comment://commentHasNoText/");
            } else {
                iframe.setAttribute("src", "comment://commentHasText/");
            }
            document.documentElement.appendChild(iframe);
            iframe.parentNode.removeChild(iframe);
            iframe = null;

            if (bottom + 20 > window.pageYOffset + window.innerHeight)
                window.scrollTo(0, bottom + 20 - window.innerHeight);
            else if (top < window.pageYOffset)
                window.scrollTo(0, top);
            
            locked = false;
        } catch (err) {
            // Just in case of an error, release the lock
            locked = false;
            console.log(err);
        }

    });
});
