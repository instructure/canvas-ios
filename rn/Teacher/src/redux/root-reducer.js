// @flow

import { combineReducers, Reducer } from 'redux'
import { courses } from '../modules/courses/courses-reducer'
import { favoriteCourses } from '../modules/courses/favorites/favorite-courses-reducer'
import assignments from '../modules/assignments/reducer'
import assignmentDetails from '../modules/assignment-details/reducer'
import logout from './logout-action'

const entities = combineReducers({
  courses,
})

const actualRootReducer: Reducer<AppState, Action> = combineReducers({
  assignments,
  assignmentDetails,
  favoriteCourses,
  entities,
})

export default function rootReducer (state: ?AppState, action: Action): AppState {
  if (action.type === logout.type) {
    state = undefined
  }
  return actualRootReducer(state, action)
}
