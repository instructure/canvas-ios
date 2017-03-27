// @flow

import { combineReducers, Reducer } from 'redux'
import { courses } from '../modules/courses/courses-reducer'
import { favoriteCourses } from '../modules/courses/favorites/favorite-courses-reducer'
import { assignmentGroups } from '../modules/assignments/assignments-reducer'
import assignmentDetails from '../modules/assignment-details/reducer'
import logout from './logout-action'

const entities = combineReducers({
  courses,
  assignmentGroups,
})

const actualRootReducer: Reducer<AppState, Action> = combineReducers({
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
