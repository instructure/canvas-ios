/**
 * Registers all of the top level screens with the Navigation.registerComponent API
 * @flow
 */

import { Navigation } from 'react-native-navigation'

import CourseList from './course-list/CourseList'
import Inbox from './inbox/Inbox'
import Profile from './profile/Profile'
import DefaultState from './default-state/DefaultState'

export function registerScreens () {
  Navigation.registerComponent('teacher.CourseList', () => CourseList)
  Navigation.registerComponent('teacher.Inbox', () => Inbox)
  Navigation.registerComponent('teacher.Profile', () => Profile)
  Navigation.registerComponent('teacher.DefaultState', () => DefaultState)
}
