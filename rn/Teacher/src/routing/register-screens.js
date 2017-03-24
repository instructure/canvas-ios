// @flow

import FavoritedCourseList from '../modules/courses/favorites/FavoritedCourseList'
import AllCourseList from '../modules/courses/all/AllCourseList'
import FavoritesList from '../modules/courses/edit-favorites/EditFavorites'
import CourseDetails from '../modules/courses/details/CourseDetails'
import AssignmentList from '../modules/assignments/AssignmentList'
import AssignmentDetails from '../modules/assignment-details/AssignmentDetails'
import Inbox from '../modules/inbox/Inbox'
import Profile from '../modules/profile/Profile'
import BetaFeedback from '../modules/beta-feedback/BetaFeedback'

import { Store } from 'redux'
import { registerScreen } from './'

export function registerScreens (store: Store): void {
  registerScreen('/', () => FavoritedCourseList, store)
  registerScreen('/courses', () => AllCourseList, store)
  registerScreen('/course_favorites', () => FavoritesList, store)
  registerScreen('/courses/:courseID', () => CourseDetails, store)
  registerScreen('/courses/:courseID/assignments', () => AssignmentList, store)
  registerScreen('/courses/:courseID/assignments/:assignmentID', () => AssignmentDetails, store)
  registerScreen('/conversations', () => Inbox, store)
  registerScreen('/profile', () => Profile, store)
  registerScreen('/beta-feedback', () => BetaFeedback, store)
}
