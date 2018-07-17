//
// Copyright (C) 2018-present Instructure, Inc.
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
