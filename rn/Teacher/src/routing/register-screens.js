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
import Profile from '../modules/profile/Profile'
import BetaFeedback from '../modules/beta-feedback/BetaFeedback'
import Staging from '../modules/staging/Staging'
import SubmissionList from '../modules/submissions/list/SubmissionList'
import AssigneePicker from '../modules/assignee-picker/AssigneePicker'
import AssigneeSearch from '../modules/assignee-picker/AssigneeSearch'
import Speedgrader from '../modules/speedgrader/Speedgrader'

import { Store } from 'redux'
import { registerScreen } from './'

export function registerScreens (store: Store): void {
  registerScreen('/', () => FavoritedCourseList, store)
  registerScreen('/courses', () => AllCourseList, store)
  registerScreen('/course_favorites', () => EditFavorites, store)
  registerScreen('/courses/:courseID', () => CourseDetails, store)
  registerScreen('/courses/:courseID/settings', () => CourseSettings, store)
  registerScreen('/courses/:courseID/user_preferences', () => UserCoursePreferences, store)
  registerScreen('/courses/:courseID/assignments', () => AssignmentList, store)
  registerScreen('/courses/:courseID/assignments/:assignmentID', () => AssignmentDetails, store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/edit', () => AssignmentDetailsEdit, store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/due_dates', () => AssignmentDueDates, store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/submissions', () => SubmissionList, store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', () => Speedgrader, store)
  registerScreen('/conversations', () => Inbox, store)
  registerScreen('/profile', () => Profile, store)
  registerScreen('/beta-feedback', () => BetaFeedback, store)
  registerScreen('/staging', () => Staging)

  // This will never actually be routed to, but this makes it really easy to debug
  registerScreen('/courses/:courseID/assignee-picker', () => AssigneePicker, store)
  registerScreen('/courses/:courseID/assignee-search', () => AssigneeSearch, store)
}
