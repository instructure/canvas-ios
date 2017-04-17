// @flow

import { combineReducers, Reducer, Action } from 'redux'
import { courses } from '../modules/courses/courses-reducer'
import { favoriteCourses } from '../modules/courses/favorites/favorite-courses-reducer'
import { gradingPeriods } from '../modules/assignments/grading-periods-reducer'
import { assignments } from '../modules/assignments/assignment-entities-reducer'
import { assignmentGroups } from '../modules/assignments/assignment-group-entities-reducer'
import { users } from '../modules/users/reducer'
import { sections } from '../modules/assignee-picker/reducer'
import { enrollments, enrollmentUsers } from '../modules/enrollments/enrollment-entities-reducer'
import logout from './logout-action'
import { HYDRATE_ACTION } from './hydrate-action'
import resetPending from '../utils/reset-pending'
import composeReducers from './compose-reducers'

const entities = combineReducers({
  courses,
  assignmentGroups,
  gradingPeriods,
  assignments,
  users: composeReducers(users, enrollmentUsers),
  sections,
  enrollments,
})

const actualRootReducer: Reducer<AppState, Action> = combineReducers({
  favoriteCourses,
  entities,
})

export default function rootReducer (state: ?AppState, action: Action): AppState {
  if (action.type === logout.type) {
    state = undefined
  }

  if (action.type === HYDRATE_ACTION) {
    if (action.payload) {
      let today = new Date()
      let expires = new Date(action.payload.expires)
      if (action.payload && today < expires) {
        state = resetPending(action.payload.state)
      }
    }
  }
  return actualRootReducer(state, action)
}
