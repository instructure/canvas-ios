// @flow

import { combineReducers, Reducer, Action } from 'redux'
import { courses, courseDetailsTabSelectedRow } from '../modules/courses/courses-reducer'
import { favoriteCourses } from '../modules/courses/favorites/favorite-courses-reducer'
import { gradingPeriods } from '../modules/assignments/grading-periods-reducer'
import { assignments } from '../modules/assignments/assignment-entities-reducer'
import { assignmentGroups } from '../modules/assignments/assignment-group-entities-reducer'
import { users } from '../modules/users/reducer'
import { sections } from '../modules/assignee-picker/reducer'
import { enrollments, enrollmentUsers } from '../modules/enrollments/enrollment-entities-reducer'
import logout from './logout-action'
import { HYDRATE_ACTION } from './hydrate-action'
import resetStoreKeys from '../utils/reset-store-keys'
import composeReducers from './compose-reducers'
import { submissions } from '../modules/submissions/list/submission-entities-reducer'
import { quizzes } from '../modules/quizzes/reducer'
import { quizSubmissions, quizAssignmentSubmissions } from '../modules/quizzes/submissions/reducer'
import { discussions } from '../modules/discussions/reducer'
import inbox from '../modules/inbox/reducer'

const entities = combineReducers({
  courses,
  assignmentGroups,
  gradingPeriods,
  assignments,
  users: composeReducers(users, enrollmentUsers),
  sections,
  enrollments,
  submissions: composeReducers(submissions, quizAssignmentSubmissions),
  quizzes,
  quizSubmissions,
  discussions,
  courseDetailsTabSelectedRow,
})

const actualRootReducer: Reducer<AppState, Action> = combineReducers({
  favoriteCourses,
  inbox,
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
        state = resetStoreKeys(action.payload.state)
      }
    }
  }
  return actualRootReducer(state, action)
}
