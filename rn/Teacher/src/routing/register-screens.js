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
import SpeedGrader from '../modules/speedgrader/SpeedGrader'
import RubricDescription from '../modules/speedgrader/RubricDescription'
import QuizzesList from '../modules/quizzes/list/QuizzesList'
import QuizDetails from '../modules/quizzes/details/QuizDetails'
import QuizEdit from '../modules/quizzes/edit/QuizEdit'
import RichTextEditor from '../common/components/rich-text-editor/RichTextEditor'
import QuizPreview from '../modules/quizzes/details/QuizPreview'
import QuizSubmissions from '../modules/quizzes/submissions/QuizSubmissionList'
import CourseDetailsSplitViewPlaceholder from '../modules/courses/details/components/CourseDetailsSplitViewPlaceholder'
import DiscussionsList from '../modules/discussions/list/DiscussionsList'
import AnnouncementsList from '../modules/announcements/list/AnnouncementsList'
import DiscussionDetails from '../modules/discussions/details/DiscussionDetails'

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
  registerScreen('/courses/:courseID/assignments/:assignmentID/submissions', wrap(SubmissionList), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/submissions/:userID', wrap(SpeedGrader), store)
  registerScreen('/courses/:courseID/assignments/:assignmentID/rubrics/:rubricID/description', wrap(RubricDescription), store)
  registerScreen('/courses/:courseID/quizzes', wrap(QuizzesList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/quizzes/:quizID', wrap(QuizDetails), store)
  registerScreen('/courses/:courseID/quizzes/:quizID/preview', wrap(QuizPreview), store)
  registerScreen('/courses/:courseID/quizzes/:quizID/edit', wrap(QuizEdit), store)
  registerScreen('/courses/:courseID/quizzes/:quizID/submissions', wrap(QuizSubmissions), store)
  registerScreen('/courses/:courseID/discussion_topics', wrap(DiscussionsList), store, { canBecomeMaster: true })
  registerScreen('/courses/:courseID/discussion_topics/:discussionID', wrap(DiscussionDetails), store)
  registerScreen('/conversations', wrap(Inbox), store)
  registerScreen('/profile', wrap(Profile), store)
  registerScreen('/beta-feedback', wrap(BetaFeedback), store)
  registerScreen('/staging', wrap(Staging))
  registerScreen('/rich-text-editor', wrap(RichTextEditor))
  registerScreen('/courses/:courseID/placeholder', wrap(CourseDetailsSplitViewPlaceholder), store)
  registerScreen('/courses/:courseID/announcements', wrap(AnnouncementsList), store)

  // This will never actually be routed to, but this makes it really easy to debug
  registerScreen('/courses/:courseID/assignee-picker', wrap(AssigneePicker), store)
  registerScreen('/courses/:courseID/assignee-search', wrap(AssigneeSearch), store)
}
