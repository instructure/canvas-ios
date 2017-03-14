/**
 * Registers all of the top level screens with the Navigation.registerComponent API
 * @flow
 */

import { Navigation } from 'react-native-navigation'
import { Store } from 'redux'
import { Provider } from 'react-redux'

import FavoritedCourseList from './course-list/FavoritedCourseList'
import AllCourseList from './course-list/AllCourseList'
import CourseDetails from './course-details/CourseDetails'
import Inbox from './inbox/Inbox'
import Profile from './profile/Profile'
import DefaultState from './default-state/DefaultState'
import LegoSets from './toys/legos/LegoSets'
import ActionFigures from './toys/action-figures/ActionFigures'

export function registerScreens (store: Store): void {
  Navigation.registerComponent('teacher.FavoritedCourseList', () => FavoritedCourseList, store, Provider)
  Navigation.registerComponent('teacher.AllCourseList', () => AllCourseList, store, Provider)
  Navigation.registerComponent('teacher.CourseDetails', () => CourseDetails, store, Provider)
  Navigation.registerComponent('teacher.Inbox', () => Inbox, store, Provider)
  Navigation.registerComponent('teacher.Profile', () => Profile, store, Provider)
  Navigation.registerComponent('teacher.DefaultState', () => DefaultState, store, Provider)
  Navigation.registerComponent('toys.LegoSets', () => LegoSets, store, Provider)
  Navigation.registerComponent('toys.ActionFigures', () => ActionFigures, store, Provider)
}
