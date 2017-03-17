// @flow

import FavoritedCourseList from '../modules/course-list/FavoritedCourseList'
import AllCourseList from '../modules/course-list/AllCourseList'
import FavoritesList from '../modules/favorites-list/FavoritesList'
import CourseDetails from '../modules/course-details/CourseDetails'
import AssignmentList from '../modules/assignments/AssignmentList'
import AssignmentDetails from '../modules/assignment-details/AssignmentDetails'
import Inbox from '../modules/inbox/Inbox'
import Profile from '../modules/profile/Profile'
import DefaultState from '../modules/default-state/DefaultState'
import BetaFeedback from '../modules/beta-feedback/BetaFeedback'
import LegoSets from '../modules/toys/legos/LegoSets'
import ActionFigures from '../modules/toys/action-figures/ActionFigures'

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
  registerScreen('/default', () => DefaultState, store)
  registerScreen('/beta-feedback', () => BetaFeedback, store)
  registerScreen('/toys/legosets', () => LegoSets, store)
  registerScreen('/toys/actionfigures', () => ActionFigures, store)
}
