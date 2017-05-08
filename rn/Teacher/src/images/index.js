// @flow

type Images = {
  course: {[name: string]: any},
  tabbar: {[name: string]: any},
  assignments: {[name: string]: any},
  rce: {[name: string]: any},
  [name: string]: any,
}

const images = {
  course: {
    announcements: require('./course/Announcements.png'),
    assignments: require('./course/Assignments.png'),
    discussions: require('./course/Discussions.png'),
    pages: require('./course/Pages.png'),
    people: require('./course/People.png'),
    quizzes: require('./course/Quiz.png'),
    syllabus: require('./course/Syllabus.png'),
    files: require('./course/Files.png'),
    settings: require('./course/Settings.png'),
  },
  tabbar: {
    courses: require('./tabbar/courses.png'),
    inbox: require('./tabbar/inbox.png'),
    profile: require('./tabbar/profile.png'),
    staging: require('./tabbar/link.png'),
    stagingFilled: require('./tabbar/link-solid.png'),
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
  },
  canvasLogo: require('./canvas-logo.png'),
  feedback: require('./feedback.png'),
  kabob: require('./kabob.png'),
  backIcon: require('./Back-icon.png'),
  check: require('./check-white.png'),
  starFilled: require('./star-filled.png'),
  starLined: require('./star-lined.png'),
  add: require('./Add.png'),
  x: require('./x-icon.png'),
  clear: require('./Clear.png'),
  edit: require('./edit.png'),
  pickerArrow: require('./picker-arrow.png'),
  published: require('./Published.png'),
  unpublished: require('./Unpublished.png'),
}

export default (images: Images)
