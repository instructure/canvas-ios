//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import { combineReducers, Reducer, Action } from 'redux'
import { accountNotifications } from '../modules/dashboard/account-notification-reducer'
import { courses, courseDetailsTabSelectedRow } from '../modules/courses/courses-reducer'
import { favoriteCourses } from '../modules/courses/favorites/favorite-courses-reducer'
import { favoriteGroups } from '../modules/groups/favorites/favorite-groups-reducer'
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
import { groups } from '../modules/groups/group-entities-reducer'
import { asyncActions } from './actions/async-tracker'
import { userInfo } from '../modules/userInfo/reducer'

const entities = combineReducers({
  accountNotifications,
  courses,
  groups,
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
  favoriteGroups,
  inbox,
  entities,
  asyncActions,
  userInfo,
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
