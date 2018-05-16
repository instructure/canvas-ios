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

// @flow

const images = {
  course: {
    announcements: require('./course/Announcement.png'),
    assignments: require('./course/Assignment.png'),
    discussions: require('./course/Discussions.png'),
    collaborations: require('./course/Collaboration.png'),
    conferences: require('./course/Conferences.png'),
    grades: require('./course/Grades.png'),
    pages: require('./course/Pages.png'),
    people: require('./course/People.png'),
    modules: require('./course/Modules.png'),
    quizzes: require('./course/Quiz.png'),
    home: require('./course/Home.png'),
    syllabus: require('./course/Syllabus.png'),
    files: require('./course/Files.png'),
    lti: require('./course/LTI.png'),
    settings: require('./course/Settings.png'),
    placeholder: require('./course/Placeholder.png'),
    attendance: require('./course/attendance-icon.png'),
  },
  dashboard: {
    calendar: require('./dashboard/calendar.png'),
    help: require('./dashboard/help.png'),
    info: require('./dashboard/info.png'),
    warning: require('./Warning.png'),
    invite: require('./dashboard/invite.png'),
  },
  tabbar: {
    courses: require('./tabbar/courses.png'),
    inbox: require('./tabbar/inbox.png'),
    profile: require('./tabbar/profile.png'),
    staging: require('./tabbar/link.png'),
  },
  assignments: {
    calendar: require('./assignments/Calendar.png'),
  },
  rce: {
    bold: require('./rce/bold.png'),
    embedImage: require('./rce/embed-image.png'),
    italic: require('./rce/italic.png'),
    link: require('./rce/link.png'),
    orderedList: require('./rce/ordered-list.png'),
    unorderedList: require('./rce/unordered-list.png'),
    redo: require('./rce/redo.png'),
    undo: require('./rce/undo.png'),
    active: {
      bold: require('./rce/bold-active.png'),
      italic: require('./rce/italic-active.png'),
      orderedList: require('./rce/ordered-list-active.png'),
      unorderedList: require('./rce/unordered-list-active.png'),
    },
  },
  speedGrader: {
    chatBubbleMe: require('./speedgrader/bubble-me.png'),
    chatBubbleThem: require('./speedgrader/bubble-them.png'),
    audio: require('./speedgrader/icon_audio.png'),
    video: require('./speedgrader/icon_video_clip.png'),
    page: require('./speedgrader/page.png'),
    pdf: require('./speedgrader/pdf-icon.png'),
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
  noTeacher: {
    parent: require('./Canvas-Parent.png'),
    student: require('./Canvas-Student.png'),
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
  files: {
    folder: require('./files/folder.png'),
    media: require('./files/media-icon.png'),
  },
  masquerade: {
    redPanda: require('./masquerade/red-panda.png'),
    whitePanda: require('./masquerade/white-panda.png'),
  },
  discussions: {
    rate: require('./discussions/Like.png'),
    rated: require('./discussions/Liked.png'),
  },
  canvasLogo: require('./canvas-logo.png'),
  feedback: require('./feedback.png'),
  kabob: require('./kabob.png'),
  chevronUp: require('./chevron-up.png'),
  backIcon: require('./Back-icon.png'),
  check: require('./check-white.png'),
  starFilled: require('./star-filled.png'),
  starLined: require('./star-lined.png'),
  add: require('./Add.png'),
  x: require('./x-icon.png'),
  clear: require('./Clear.png'),
  edit: require('./edit.png'),
  pencilBG: require('./Pencil-BG.jpg'),
  pickerArrow: require('./picker-arrow.png'),
  profile: require('./profile.png'),
  published: require('./publish.png'),
  unpublished: require('./unpublish.png'),
  publishedSmall: require('./publish-small.png'),
  unpublishedSmall: require('./unpublish-small.png'),
  restricted: require('./Restricted.png'),
  upArrow: require('./mini-arrow-up.png'),
  document: require('./Document.png'),
  attachment: require('./attachment.png'),
  attachmentLarge: require('./attachment-large.png'),
  attachment80: require('./attachment-80.png'),
  mail: require('./Mail.png'),
  smallMail: require('./mail-small.png'),
  group: require('./group.png'),
  trash: require('./trash.png'),
  share: require('./share.png'),
  relax: require('./relax.png'),
  hamburger: require('./hamburger.png'),
}

export default (images: *)
