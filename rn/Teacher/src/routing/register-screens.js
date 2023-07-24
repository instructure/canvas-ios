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
import Inbox from '../modules/inbox/Inbox'
import Compose from '../modules/inbox/Compose'
import AddressBook from '../modules/address-book/AddressBook'
import CourseSelect from '../modules/inbox/CourseSelect'
import ConversationDetails from '../modules/inbox/detail/ConversationDetails'
import AttachmentView from '../common/components/AttachmentView'
import Attachments from '../modules/attachments/Attachments'
import ExperimentalFeature from '../common/ExperimentalFeature'

import { Store } from 'redux'
import { registerScreen } from './'
import { isTeacher, isStudent } from '../modules/app'

export function registerScreens (store: Store): void {
  registerScreen('/courses/:courseID/address-book', AddressBook, store)
  registerScreen('/conversations', Inbox, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/conversations/compose', Compose, store)
  registerScreen('/conversations/:conversationID/add_message', Compose, store)
  registerScreen('/conversations/course-select', CourseSelect, store)
  registerScreen('/conversations/:conversationID', ExperimentalFeature.nativeStudentInbox.isEnabled ? null : ConversationDetails, store, { deepLink: true })
  registerScreen('/address-book', AddressBook, store)
  registerScreen('/attachment', AttachmentView, store)
  registerScreen('/attachments', Attachments, store)

  registerScreen('/dev-menu', null, store)
  registerScreen('/rating-request', null, store)
  registerScreen('/push-notifications', null, store)
  registerScreen('/page-view-events', null, store)
  registerScreen('/courses', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/placeholder', null, store)
  registerScreen('/courses/:courseID', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/tabs', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/settings', null, store)
  registerScreen('/courses/:courseID/assignments', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/collaborations', null, store, { showInWebView: true, deepLink: true })
  registerScreen('/courses/:courseID/lti_collaborations', null, store, { showInWebView: true, deepLink: true })
  registerScreen('/:context/:contextID/discussions', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/discussion_topics', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/discussion_topics/new', null, store)
  registerScreen('/:context/:contextID/discussion_topics/:discussionID/reply', null, store)
  registerScreen('/:context/:contextID/discussion_topics/:discussionID/edit', null, store)
  registerScreen('/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies', null, store, { deepLink: true })
  registerScreen('/courses/:courseID/users', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/profile')
  registerScreen('/:context/:contextID/announcements', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/announcements/new', null, store)
  registerScreen('/:context/:contextID/announcements/:announcementID', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/announcements/:announcementID/edit', null, store)
  registerScreen('/:context/:contextID/discussions/:discussionID', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/discussion_topics/:discussionID', null, store, { deepLink: true })
  registerScreen('/files', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/files', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/files/folder/*subFolder', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/files/folder/*subFolder', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/folders/:folderID/edit', null, store)
  registerScreen('/files/:fileID', null, store, { deepLink: true })
  registerScreen('/files/:fileID/download', null, store, { deepLink: true })
  registerScreen('/files/:fileID/preview', null, store, { deepLink: true })
  registerScreen('/files/:fileID/edit', null, store)
  registerScreen('/:context/:contextID/files/:fileID', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/files/:fileID/download', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/files/:fileID/preview', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/files/:fileID/edit', null, store)
  registerScreen('/wrong-app', null, store)
  registerScreen('/:context/:contextID/pages', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/pages/new', null, store)
  registerScreen('/:context/:contextID/pages/:url', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/pages/:url/edit', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/wiki', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/wiki/:url', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/wiki/:url/edit', null, store, { deepLink: true })
  registerScreen('/accounts/:accountID/terms_of_service', null, store, { deepLink: true })
  registerScreen('/profile/settings')
  registerScreen('/support/problem', undefined, undefined, { deepLink: true })
  registerScreen('/support/feature', undefined, undefined, { deepLink: true })
  registerScreen('/dev-menu/experimental-features', null, store)
  registerScreen('/dev-menu/pandas', null, store)
  registerScreen('/dev-menu/website-preview', null, store)
  registerScreen('/dev-menu/snackbar', null, store)
  registerScreen('/logs')
  registerScreen('/act-as-user')
  registerScreen('/act-as-user/:userID')
  registerScreen('/courses/:courseID/assignments/syllabus', null, store, { deepLink: true })
  registerScreen('/courses/:courseID/syllabus', null, store, { deepLink: true })

  if (isTeacher()) {
    registerScreen('/courses/:courseID/assignments/:assignmentID/assignee-picker', null, store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/assignee-search', null, store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/submissions', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID/edit', null, store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/post_policy')
    registerScreen('/courses/:courseID/attendance/:toolID')
    registerScreen('/courses/:courseID/quizzes', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID/preview', null, store)
    registerScreen('/courses/:courseID/quizzes/:quizID/edit', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID/submissions', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/users/:userID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules', null, null, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/modules/:moduleID', null, null, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/modules/items/:itemID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules/:moduleID/items/:itemID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/module_item_redirect/:itemID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', null, store, { deepLink: true })
  }

  if (isStudent()) {
    registerScreen('/courses/:courseID/assignments/:assignmentID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/conferences', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/:context/:contextID/conferences/:conferenceID', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/conferences/:conferenceID/join', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules/:moduleID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules/items/:itemID', null, store, { deepLink: true })
    registerScreen('/groups/:groupID', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/groups/:groupID/tabs', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/grades', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/users/:userID', null, store, { deepLink: true })
    registerScreen('/groups/:groupID/users/:userID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/users', null, store)
    registerScreen('/groups/:groupID/users', null, store)
    // Calls the old routing method
    registerScreen('/native-route/*route')
    // Calls the old routing method as well, but with the canBecomeMaster option
    registerScreen('/native-route-master/*route', null, null, { canBecomeMaster: true })
  }
}
