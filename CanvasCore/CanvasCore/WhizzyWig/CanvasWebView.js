//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// Post message when Quizzes Next 'Return' button is pressed.
var checkQuizzesNext = setInterval(function() {
  var buttons = document.querySelectorAll('header a[data-automation="sdk-return-button"]')
  if (buttons.length) {
    clearInterval(checkQuizzesNext)
  }
  buttons.forEach(a => {
     a.onclick = function (e) {
         e.preventDefault()
         window.webkit.messageHandlers.dismiss.postMessage(true)
     }
  })
}, 100)

// Replace all iframes with a button to launch in SFSafariViewController
const iframes = document.querySelectorAll('iframe');
// If there is only one iframe
// and id="cnvs_content"
// and the src is a canvas file
// reload the webview with an authenticated version of the iframe's src
if (iframes.length == 1 && /\/courses\/\d+\/files\/\d+\/download/.test(iframes[0].src) && iframes[0].id === "cnvs_content") {
    window.webkit.messageHandlers.loadFrameSource.postMessage(iframes[0].src)
} else {
    // Replace all iframes with a button to launch in SFSafariViewController
    iframes.forEach(iframe => {
        const replace = iframe => {
            const a = document.createElement('a')
            a.textContent = '{$LTI_LAUNCH_TEXT$}'
            a.classList.add('canvas-ios-lti-launch-button')
            a.href = iframe.src
            iframe.parentNode.replaceChild(a, iframe)
        }
        if (/\/courses\/\d+\/external_tools\/retrieve/.test(iframe.src)) {
            replace(iframe)
        } else if (/\/media_objects_iframe\/m-\w+/.test(iframe.src)) {
            const match = iframe.src.match(/\/media_objects_iframe\/(m-\w+)/)
            if (match.length == 2) {
                const mediaID = match[1]
                const video = document.createElement('video')
                video.src = 'https://canvas.instructure.com/users/self/media_download?entryId='+mediaID+'&media_type=video&redirect=1'
                video.setAttribute('poster', 'https://canvas.instructure.com/media_objects/'+mediaID+'/thumbnail?width=550&height=448')
                video.setAttribute('controls', '')
                video.setAttribute('preload', 'none')
                iframe.parentNode.parentNode.replaceChild(video, iframe.parentNode)
            }
        } else {
            iframe.addEventListener('error', event => replace(event.target))
        }
    })
}
