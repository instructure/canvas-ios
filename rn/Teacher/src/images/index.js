//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

// @flow

const images = {
  course: {
    settings: require('./course/Settings.png'),
  },
  dashboard: {
    calendar: require('./dashboard/calendar.png'),
    help: require('./dashboard/help.png'),
    info: require('./dashboard/info.png'),
    warning: require('./Warning.png'),
    invite: require('./dashboard/invite.png'),
  },
  assignments: {
    calendar: require('./assignments/Calendar.png'),
  },
  speedGrader: {
    warning: require('./Warning.png'),
    longPress: require('./speedgrader/Longpress.png'),
    swipe: require('./speedgrader/Swipe.png'),
    submissions: {
      lti: require('./speedgrader/submission-types/LTI.png'),
      text: require('./speedgrader/submission-types/document.png'),
      document: require('./speedgrader/submission-types/document.png'),
      discussion: require('./speedgrader/submission-types/discussion.png'),
      quiz: require('./speedgrader/submission-types/quiz.png'),
      video: require('./speedgrader/submission-types/video.png'),
      audio: require('./speedgrader/submission-types/audio.png'),
      url: require('./speedgrader/submission-types/link.png'),
    },
    turnitin: {
      error: require('./Warning.png'),
      pending: require('./clock.png'),
    },
  },
  attachments: {
    complete: require('./attachments/complete-icon.png'),
    error: require('./attachments/warning-icon.png'),
  },
  mediaComments: {
    x: require('./media-comments/Close.png'),
    trash: require('./media-comments/Trash.png'),
    send: require('./media-comments/Send.png'),
  },
  kabob: require('./kabob.png'),
  check: require('./check-white.png'),
  add: require('./Add.png'),
  x: require('./x-icon.png'),
  clear: require('./Clear.png'),
  pickerArrow: require('./picker-arrow.png'),
  published: require('./publish.png'),
  unpublished: require('./unpublish.png'),
  upArrow: require('./mini-arrow-up.png'),
  paperclip: require('./paperclip-icon.png'),
  attachment80: require('./attachment-80.png'),
  smallMail: require('./mail-small.png'),
  share: require('./share.png'),
  invisible: require('./invisible.png'),
  off: require('./off.png'),
}

export default (images: *)
