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


function load(method,param1) {
    window.location = "speedgrader://speedgrader/" + method + ":" + param1;
}

function stopAllMedia() {
    var videos = document.getElementsByTagName('video');
    for (var i = 0; i < videos.length; i++) {
        var video = videos[i];
        video.pause();
    }
}

/*
addComment({
           "createdAt": "Jun 04 at 09:53 AM",
           "attachments": [{
                           "isMedia": false,
                           "directURL": "http://canvas.instructure.com/courses/20513/assignments/3089/submissions/232617?download=13426",
                           "filename": "Distributed+B-Trees.pdf",
                           "ident": "13426"
                           }, {
                           "isMedia": false,
                           "directURL": "http://canvas.instructure.com/courses/20513/assignments/3089/submissions/232617?download=13427",
                           "filename": "ec2+dynomite.txt",
                           "ident": "13427"
                           }],
           "author": "Zach Wily",
           "body": "dfafdsa"
           });
 
 2010-06-23 16:30:18.758 Speed Grader[17168:207] addComment({"createdAt":"May 13 at 02:08 PM","attachments":[{"isMedia":true,"directURL":"http://canvas.instructure.com/courses/20513/media_download?entryId=0_b067yibv&type=mp4&redirect=1","filename":"unknown","ident":"20513-3089-19755--1878586411"}],"author":"Zach Wily","body":"This is a media comment."});

*/

function addComment(comment) {
    var newComment = document.createElement('div');
    var commentClass = comment['isMe'] ? "comment me" : "comment";
    newComment.setAttribute("class", commentClass);
    
    var newCommentHeader = document.createElement('div');
    newCommentHeader.setAttribute("class", "header");
    
    var newTime = document.createElement('span');
    newTime.setAttribute("class", "posted_at");
    newTime.appendChild(document.createTextNode(comment['createdAt']));
    newCommentHeader.appendChild(newTime);
    
    var newAuthor = document.createElement('div');
    var authorClass = comment['isMe'] ? "author me" : "author";
    newAuthor.setAttribute("class", authorClass);
    newAuthor.appendChild(document.createTextNode(comment['author']));
    newCommentHeader.appendChild(newAuthor);
    
    newComment.appendChild(newCommentHeader);
    
    // Yeah this is kinda hacky, but this is a dumb message to show.
    if (comment['body'] != "This is a media comment.") {
        var newCommentBody = document.createElement('div');
        newCommentBody.setAttribute("class","body");
        newCommentBody.innerHTML = comment['body'];
        newComment.appendChild(newCommentBody);
    }
    
    var attachments = comment['attachments'];
    if (!attachments) {
        attachments = [];
    }
    for (var i = 0; i < attachments.length; i++) {
        var attachment = attachments[i];
        var newAttachment = document.createElement('div');
        newAttachment.setAttribute("class", "attachment");
        
        var thingy;
        if (attachment['isMedia'] && attachment['mediaType'] == 'audio') {
            thingy = document.createElement('a');
			thingy.setAttribute("id", attachment['mediaId']);
            thingy.setAttribute("href", "javascript:load('getAttachmentURLForAttachmentId', '" + attachment['ident'] + "');");
			thingy.appendChild(document.createTextNode("Listen"));
			newAttachment.setAttribute("class", "attachment audio");
        }
        else if (attachment['isMedia']) {
            thingy = document.createElement('a');
			thingy.setAttribute("id", attachment['mediaId']);
            thingy.setAttribute("href", "javascript:load('getAttachmentURLForAttachmentId', '" + attachment['ident'] + "');");
			thingy.appendChild(document.createTextNode("Watch"));
			newAttachment.setAttribute("class", "attachment video");
		}
        else {
            thingy = document.createElement('a');
            thingy.setAttribute("href", "javascript:load('getAttachmentURLForAttachmentId', '" + attachment['ident'] + "');");
            downloadImage = document.createElement('img');
            downloadImage.setAttribute("src","download_arrow.png");
            thingy.appendChild(downloadImage);
            thingy.appendChild(document.createTextNode(attachment['displayName']));
        }
        
        newAttachment.appendChild(thingy);
        newComment.appendChild(newAttachment);
    }
    
    if (comment['footer']) {
        var newCommentFooter = document.createElement('div');
        newCommentFooter.setAttribute("class","footer");
        newCommentFooter.innerHTML = comment['footer'];
        newComment.appendChild(newCommentFooter);
    }
    
    var theComments = document.getElementById('comments');
    theComments.appendChild(newComment);
}

function loadThumbnailForMediaAttachment(attachment,url) {
	var elementId = '#' + attachment['mediaId'];
	$(elementId).html('');
	
	$('<img />')
	    .attr('src', url)
	    .load(function() {
	        // Comment out the next line if running test_comments.html
	        load('setCommentsHeightFromJavascript');
	    })
	    .appendTo(elementId);
}

