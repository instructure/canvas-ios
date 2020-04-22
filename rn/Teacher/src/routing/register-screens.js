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
import React from 'react'
import AllCourseList from '../modules/courses/all/AllCourseList'
import EditFavorites from '../modules/courses/edit-favorites/EditFavorites'
import CourseNavigation from '../modules/courses/CourseNavigation'
import CourseSettings from '../modules/courses/settings/CourseSettings'
import UserCoursePreferences from '../modules/courses/user-prefs/UserCoursePreferences'
import AssignmentList from '../modules/assignments/AssignmentList'
import AssignmentDetails from '../modules/assignment-details/AssignmentDetails'
import AssignmentDueDates from '../modules/assignment-due-dates/AssignmentDueDates'
import AssignmentDetailsEdit from '../modules/assignment-details/AssignmentDetailsEdit'
import Inbox from '../modules/inbox/Inbox'
import Compose from '../modules/inbox/Compose'
import AddressBook from '../modules/address-book/AddressBook'
import CourseSelect from '../modules/inbox/CourseSelect'
import ConversationDetails from '../modules/inbox/detail/ConversationDetails'
import DeveloperMenu from '../modules/developer-menu/DeveloperMenu'
import SubmissionList from '../modules/submissions/list/SubmissionList'
import AssigneePicker from '../modules/assignee-picker/AssigneePicker'
import AssigneeSearch from '../modules/assignee-picker/AssigneeSearch'
import SpeedGrader from '../modules/speedgrader/SpeedGrader'
import GraphqlSpeedGrader from '../modules/graphql-speed-grader/SpeedGrader'
import RubricDescription from '../modules/speedgrader/RubricDescription'
import QuizzesList from '../modules/quizzes/list/QuizzesList'
import QuizDetails from '../modules/quizzes/details/QuizDetails'
import QuizEdit from '../modules/quizzes/edit/QuizEdit'
import RichTextEditor from '../modules/rich-text-editor/RichTextEditor'
import LinkModal from '../common/components/rich-text-editor/LinkModal'
import QuizPreview from '../modules/quizzes/details/QuizPreview'
import QuizSubmissions from '../modules/quizzes/submissions/QuizSubmissionList'
import CourseDetailsSplitViewPlaceholder from '../modules/courses/details/components/CourseDetailsSplitViewPlaceholder'
import DiscussionsList from '../modules/discussions/list/DiscussionsList'
import DiscussionDetails from '../modules/discussions/details/DiscussionDetails'
import DiscussionEdit from '../modules/discussions/edit/DiscussionEdit'
import AnnouncementsList from '../modules/announcements/list/AnnouncementsList'
import AnnouncementEdit from '../modules/announcements/edit/AnnouncementEdit'
import EditReply from '../modules/discussions/details/EditReply'
import AttachmentView from '../common/components/AttachmentView'
import GroupList from '../modules/groups/GroupList'
import Attachments from '../modules/attachments/Attachments'
import ContextCard from '../modules/users/ContextCard'
import { StudentContextCardCourse, StudentContextCardGroup } from '../modules/users/StudentContextCard'
import Filter from '../modules/filter/Filter'
import ToDoList from '../modules/to-do/list/ToDoList'
import FilesList from '../modules/files/FilesList'
import EditFile from '../modules/files/EditFile'
import EditFolder from '../modules/files/EditFolder'
import ViewFile from '../modules/files/ViewFile'
import PageEdit from '../modules/pages/edit/PageEdit'
import PickerPage from '../common/components/PickerPage'
import Dashboard from '../modules/dashboard/Dashboard'
import TermsOfUse from '../modules/tos/TermsOfUse'
import PushNotifications from '../modules/developer-menu/PushNotifications'
import SectionSelector from '../modules/announcements/edit/SectionSelector'
import ExperimentalFeature from '../common/ExperimentalFeature'
import RatingRequest from '../modules/developer-menu/RatingRequest'
import PageViewEvents from '../modules/developer-menu/PageViewEvents'

import { Store } from 'redux'
import { registerScreen } from './'
import { isTeacher, isStudent } from '../modules/app'

export function wrap (name: any): Function {
  return () => name
}

function fileListRouter (props: any) {
  if (props.preview) {
    return (props) => <ViewFile {...props} fileID={props.preview} />
  }
  return FilesList
}

export function registerScreens (store: Store): void {
  registerScreen('', wrap(Dashboard), store, { deepLink: true })
  registerScreen('/', wrap(Dashboard), store, { deepLink: true })
  if (ExperimentalFeature.nativeDashboard.isEnabled) {
    registerScreen('/courses', null, store, { canBecomeMaster: true, deepLink: true })
  } else {
    registerScreen('/courses', wrap(AllCourseList), store, { canBecomeMaster: true, deepLink: true })
  }
  registerScreen('/course_favorites', wrap(EditFavorites), store, { deepLink: true })
  registerScreen('/courses/:courseID', wrap(CourseNavigation), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/tabs', wrap(CourseNavigation), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/settings', wrap(CourseSettings), store)
  registerScreen('/courses/:courseID/user_preferences', wrap(UserCoursePreferences), store)
  registerScreen('/courses/:courseID/assignments', wrap(AssignmentList), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/collaborations', null, store, { showInWebView: true, deepLink: true })
  registerScreen('/courses/:courseID/lti_collaborations', null, store, { showInWebView: true, deepLink: true })
  registerScreen('/:context/:contextID/discussions', wrap(DiscussionsList), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/discussion_topics', wrap(DiscussionsList), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/discussion_topics/new', wrap(DiscussionEdit), store)
  registerScreen('/:context/:contextID/discussion_topics/:discussionID/reply', wrap(EditReply), store)
  registerScreen('/:context/:contextID/discussion_topics/:discussionID/edit', wrap(DiscussionEdit), store)
  registerScreen('/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies', wrap(EditReply), store, { deepLink: true })
  registerScreen('/courses/:courseID/users', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/address-book', wrap(AddressBook), store)
  registerScreen('/:context/:contextID/files', fileListRouter, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/files/folder/*subFolder', fileListRouter, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/folders/*subFolder', fileListRouter, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/files/:fileID/edit', wrap(EditFile), store)
  registerScreen('/folders/:folderID/edit', wrap(EditFolder), store)
  registerScreen('/picker', wrap(PickerPage), store)
  registerScreen('/conversations', wrap(Inbox), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/conversations/compose', wrap(Compose), store)
  registerScreen('/conversations/:conversationID/add_message', wrap(Compose), store)
  registerScreen('/conversations/course-select', wrap(CourseSelect), store)
  registerScreen('/conversations/:conversationID', wrap(ConversationDetails), store, { deepLink: true })
  registerScreen('/address-book', wrap(AddressBook), store)
  registerScreen('/profile')
  registerScreen('/dev-menu', wrap(DeveloperMenu), store)
  registerScreen('/rich-text-editor', wrap(RichTextEditor), store)
  registerScreen('/rich-text-editor/link', wrap(LinkModal), store)
  registerScreen('/attachment', wrap(AttachmentView), store)
  registerScreen('/attachments', wrap(Attachments), store)
  registerScreen('/courses/:courseID/placeholder', wrap(CourseDetailsSplitViewPlaceholder), store)
  registerScreen('/:context/:contextID/announcements', wrap(AnnouncementsList), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/announcements/new', wrap(AnnouncementEdit), store)
  registerScreen('/:context/:contextID/announcements/:announcementID', wrap(DiscussionDetails), store, { deepLink: true })
  registerScreen('/:context/:contextID/announcements/:announcementID/edit', wrap(AnnouncementEdit), store)
  registerScreen('/courses/:courseID/section-selector', wrap(SectionSelector), store)
  registerScreen('/wrong-app', null, store)
  registerScreen('/filter', wrap(Filter), store)
  registerScreen('/to-do', wrap(ToDoList), store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/courses/:courseID/wiki', null, store, { deepLink: true })
  registerScreen('/:context/:contextID/pages/:url/edit', wrap(PageEdit), store, { deepLink: true })
  registerScreen('/:context/:contextID/wiki/:url/edit', wrap(PageEdit), store, { deepLink: true })
  registerScreen('/accounts/:accountID/terms_of_service', wrap(TermsOfUse), store)
  registerScreen('/profile/settings')
  registerScreen('/support/:type', undefined, undefined, { deepLink: true })
  registerScreen('/push-notifications', wrap(PushNotifications), store)
  registerScreen('/page-view-events', wrap(PageViewEvents), store)
  registerScreen('/dev-menu/experimental-features', null, store)
  registerScreen('/rating-request', wrap(RatingRequest), store)
  registerScreen('/logs')
  registerScreen('/act-as-user')
  registerScreen('/act-as-user/:userID')

  registerScreen('/courses/:courseID/pages', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/groups/:groupID/pages', null, store, { canBecomeMaster: true, deepLink: true })
  registerScreen('/:context/:contextID/pages/new', wrap(PageEdit), store)

  if (isTeacher()) {
    // Files
    registerScreen('/files/:fileID', wrap(ViewFile), store, { deepLink: true })
    registerScreen('/files/:fileID/download', wrap(ViewFile), store, { deepLink: true })
    registerScreen('/:context/:contextID/files/:fileID', wrap(ViewFile), store, { deepLink: true })
    registerScreen('/:context/:contextID/files/:fileID/download', wrap(ViewFile), store, { deepLink: true })

    registerScreen('/courses/:courseID/assignments/syllabus', null, store, { showInWebView: true, deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID', wrap(AssignmentDetails), store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID/edit', wrap(AssignmentDetailsEdit), store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/due_dates', wrap(AssignmentDueDates), store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/assignee-picker', wrap(AssigneePicker), store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/assignee-search', wrap(AssigneeSearch), store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/submissions', wrap(SubmissionList), store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID/post_policy')
    registerScreen('/courses/:courseID/attendance/:toolID')
    registerScreen('/courses/:courseID/gradebook/speed_grader', wrap(SpeedGrader), store)
    registerScreen('/courses/:courseID/assignments/:assignmentID/rubrics/:rubricID/description', wrap(RubricDescription), store)
    registerScreen('/:context/:contextID/discussions/:discussionID', wrap(DiscussionDetails), store, { deepLink: true })
    registerScreen('/:context/:contextID/discussion_topics/:discussionID', wrap(DiscussionDetails), store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes', wrap(QuizzesList), store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID', wrap(QuizDetails), store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID/preview', wrap(QuizPreview), store)
    registerScreen('/courses/:courseID/quizzes/:quizID/edit', wrap(QuizEdit), store)
    registerScreen('/courses/:courseID/quizzes/:quizID/submissions', wrap(QuizSubmissions), store, { deepLink: true })
    registerScreen('/courses/:courseID/users/:userID', wrap(ContextCard), store, { deepLink: true })

    registerScreen('/courses/:courseID/modules', null, null, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/modules/:moduleID', null, null, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/modules/items/:itemID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules/:moduleID/items/:itemID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/module_item_redirect/:itemID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/pages/:url', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/wiki/:url', null, store, { deepLink: true })
    registerScreen('/groups/:groupID/pages/:url', null, store, { deepLink: true })
    registerScreen('/groups/:groupID/wiki/:url', null, store, { deepLink: true })

    if (ExperimentalFeature.graphqlSpeedGrader.isEnabled) {
      registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', wrap(GraphqlSpeedGrader), store, { deepLink: true })
    } else {
      registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', wrap(SpeedGrader), store, { deepLink: true })
    }
  }

  if (isStudent()) {
    // Files
    registerScreen('/files/:fileID', null, store, { deepLink: true })
    registerScreen('/files/:fileID/download', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/files/:fileID', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/files/:fileID/download', null, store, { deepLink: true })

    registerScreen('/courses/:courseID/assignments/:assignmentID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/conferences', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/:context/:contextID/conferences/:conferenceID', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/conferences/:conferenceID/join', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/discussions/:discussionID', wrap(DiscussionDetails), store, { deepLink: true })
    registerScreen('/:context/:contextID/discussion_topics/:discussionID', wrap(DiscussionDetails), store, { deepLink: true })
    registerScreen('/:context/:contextID/pages/:url', null, store, { deepLink: true })
    registerScreen('/:context/:contextID/wiki/:url', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID/take', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes/:quizID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/quizzes', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules/:moduleID', null, store, { deepLink: true })
    registerScreen('/courses/:courseID/modules/items/:itemID', null, store, { deepLink: true })
    registerScreen('/groups/:groupID', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/groups/:groupID/tabs', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/groups/:groupID/users', wrap(GroupList), store)
    registerScreen('/courses/:courseID/grades', null, store, { canBecomeMaster: true, deepLink: true })
    registerScreen('/courses/:courseID/users/:userID', wrap(StudentContextCardCourse), store, { deepLink: true })
    registerScreen('/groups/:groupID/users/:userID', wrap(StudentContextCardGroup), store, { deepLink: true })
    registerScreen('/courses/:courseID/users', null, store)
    registerScreen('/groups/:groupID/users', null, store)

    // Calls the old routing method
    registerScreen('/native-route/*route')
    // Calls the old routing method as well, but with the canBecomeMaster option
    registerScreen('/native-route-master/*route', null, null, { canBecomeMaster: true })
  }
}
