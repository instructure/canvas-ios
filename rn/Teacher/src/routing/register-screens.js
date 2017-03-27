// @flow

import FavoritedCourseList from '../modules/courses/favorites/FavoritedCourseList'
import AllCourseList from '../modules/courses/all/AllCourseList'
import EditFavorites from '../modules/courses/edit-favorites/EditFavorites'
import UserCoursePreferences from '../modules/user-course-preferences/UserCoursePreferences'
import CourseDetails from '../modules/courses/details/CourseDetails'
import AssignmentList from '../modules/assignments/AssignmentList'
import Inbox from '../modules/inbox/Inbox'
import Profile from '../modules/profile/Profile'
import BetaFeedback from '../modules/beta-feedback/BetaFeedback'

import { Store } from 'redux'
import { registerScreen } from './'

export function registerScreens (store: Store): void {
  registerScreen('/', () => FavoritedCourseList, store)
  registerScreen('/courses', () => AllCourseList, store)
  registerScreen('/course_favorites', () => EditFavorites, store)
  registerScreen('/courses/:courseID', () => CourseDetails, store)
  registerScreen('/courses/:courseID/user_preferences', () => UserCoursePreferences, store)
  registerScreen('/courses/:courseID/assignments', () => AssignmentList, store)
  registerScreen('/conversations', () => Inbox, store)
  registerScreen('/profile', () => Profile, store)
  registerScreen('/beta-feedback', () => BetaFeedback, store)
}
