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

import FavoritedCourseList from '../modules/courses/favorites/FavoritedCourseList'
import AllCourseList from '../modules/courses/all/AllCourseList'
import EditFavorites from '../modules/courses/edit-favorites/EditFavorites'
import CourseDetails from '../modules/courses/details/CourseDetails'
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
import Profile from '../modules/profile/Profile'
import Staging from '../modules/staging/Staging'
import SubmissionList from '../modules/submissions/list/SubmissionList'
import SubmissionSettings from '../modules/submissions/list/SubmissionSettings'
import AssigneePicker from '../modules/assignee-picker/AssigneePicker'
import AssigneeSearch from '../modules/assignee-picker/AssigneeSearch'
import SpeedGrader from '../modules/speedgrader/SpeedGrader'
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
import NoATeacher from '../modules/courses/components/NotATeacher'
import GroupList from '../modules/groups/GroupList'
import Attachments from '../modules/attachments/Attachments'
import ContextCard from '../modules/users/ContextCard'
import PeopleList from '../modules/people/PeopleList'
import Filter from '../modules/filter/Filter'
import ToDoList from '../modules/to-do/list/ToDoList'
import CourseFilesList from '../modules/files/CourseFilesList'
import PagesList from '../modules/pages/list/PagesList'
import PageDetails from '../modules/pages/details/PageDetails'
import PageEdit from '../modules/pages/edit/PageEdit'
import UI from '../common/UI'

import { Store } from 'redux'
import { registerScreen } from './'

export function wrap (name: any): Function {
  return () => name
}

export function registerScreens (store: Store): void {
  registerScreen('/', wrap(FavoritedCourseList), store)
  registerScreen('/courses', wrap(AllCourseList), store, { canBecomeMaster: true })
  registerScreen('/course_favorites', wrap(EditFavorites), store)
  registerScreen('/courses/:courseID', wrap(CourseDetails), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/settings', wrap(CourseSettings), store)
  registerScreen('/courses/:courseID/user_preferences', wrap(UserCoursePreferences), store)
  registerScreen('/courses/:courseID/assignments', wrap(AssignmentList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/assignments/:assignmentID', wrap(AssignmentDetails), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/edit', wrap(AssignmentDetailsEdit), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/due_dates', wrap(AssignmentDueDates), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/assignee-picker', wrap(AssigneePicker), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/assignee-search', wrap(AssigneeSearch), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/submissions', wrap(SubmissionList), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/submission_settings', wrap(SubmissionSettings), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', wrap(SpeedGrader), store)
  registerScreen('/courses/:courseID/gradebook/speed_grader', wrap(SpeedGrader), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/rubrics/:rubricID/description', wrap(RubricDescription), store)
  registerScreen('/courses/:courseID/quizzes', wrap(QuizzesList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/quizzes/:quizID', wrap(QuizDetails), store)
  registerScreen('/courses/:courseID/quizzes/:quizID/preview', wrap(QuizPreview), store)
  registerScreen('/courses/:courseID/quizzes/:quizID/edit', wrap(QuizEdit), store)
  registerScreen('/courses/:courseID/quizzes/:quizID/submissions', wrap(QuizSubmissions), store)
  registerScreen('/courses/:courseID/discussion_topics', wrap(DiscussionsList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/discussion_topics/new', wrap(DiscussionEdit), store)
  registerScreen('/courses/:courseID/discussion_topics/:discussionID', wrap(DiscussionDetails), store)
  registerScreen('/courses/:courseID/discussion_topics/:discussionID/reply', wrap(EditReply), store)
  registerScreen('/courses/:courseID/discussion_topics/:discussionID/edit', wrap(DiscussionEdit), store)
  registerScreen('/courses/:courseID/discussion_topics/:discussionID/entries/:entryID/replies', wrap(EditReply), store)
  registerScreen('/courses/:courseID/users', wrap(PeopleList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/address-book', wrap(AddressBook), store)
  registerScreen('/courses/:courseID/files', wrap(CourseFilesList), store)
  registerScreen('/courses/:courseID/files/folder/*subFolder', wrap(CourseFilesList), store)
  registerScreen('/courses/:courseID/file/:fileID', wrap(CourseFilesList), store)
  registerScreen('/groups/:groupID/users', wrap(GroupList), store)
  registerScreen('/conversations', wrap(Inbox), store, { canBecomeMaster: true })
  registerScreen('/conversations/compose', wrap(Compose), store)
  registerScreen('/conversations/:conversationID/add_message', wrap(Compose), store)
  registerScreen('/conversations/course-select', wrap(CourseSelect), store)
  registerScreen('/conversations/:conversationID', wrap(ConversationDetails), store)
  registerScreen('/address-book', wrap(AddressBook), store)
  registerScreen('/profile', wrap(Profile), store)
  registerScreen('/staging', wrap(Staging), store)
  registerScreen('/rich-text-editor', wrap(RichTextEditor), store)
  registerScreen('/rich-text-editor/link', wrap(LinkModal), store)
  registerScreen('/attachment', wrap(AttachmentView), store)
  registerScreen('/attachments', wrap(Attachments), store)
  registerScreen('/courses/:courseID/placeholder', wrap(CourseDetailsSplitViewPlaceholder), store)
  registerScreen('/courses/:courseID/announcements', wrap(AnnouncementsList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/announcements/new', wrap(AnnouncementEdit), store)
  registerScreen('/courses/:courseID/announcements/:announcementID/edit', wrap(AnnouncementEdit), store)
  registerScreen('/notATeacher', wrap(NoATeacher), store)
  registerScreen('/courses/:courseID/users/:userID', wrap(ContextCard), store)
  registerScreen('/attendance')
  registerScreen('/filter', wrap(Filter), store)
  registerScreen('/to-do', wrap(ToDoList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/wiki', wrap(PagesList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/pages', wrap(PagesList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/pages/new', wrap(PageEdit), store)
  registerScreen('/courses/:courseID/wiki/:url', wrap(PageDetails), store)
  registerScreen('/courses/:courseID/pages/:url', wrap(PageDetails), store)
  registerScreen('/courses/:courseID/pages/:url/edit', wrap(PageEdit), store)
  registerScreen('/ui', wrap(UI), store)
}
