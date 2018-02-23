//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import fromPairs from 'lodash/fromPairs'
import { type UserProfileState } from '../users/reducer'

export const defaultEntities: EnrollmentsState = {}
const { refreshEnrollments, refreshUserEnrollments, acceptEnrollment, rejectEnrollment, hideInvite } = Actions

export const enrollments: Reducer<EnrollmentsState, any> = handleActions({
  [refreshEnrollments.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = fromPairs(result.data
        .map(enrollment => [enrollment.id, enrollment]))
      return { ...state, ...incoming }
    },
  }),
  [refreshUserEnrollments.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = fromPairs(result.data
        .map(enrollment => [enrollment.id, enrollment])
      )
      return { ...state, ...incoming }
    },
  }),
  [acceptEnrollment.toString()]: handleAsync({
    resolved: (state, { enrollmentID, result }) => {
      if (result.data.success) {
        return {
          ...state,
          [enrollmentID]: {
            ...state[enrollmentID],
            enrollment_state: 'active',
            displayState: 'acted',
          },
        }
      } else { return state }
    },
  }),
  [rejectEnrollment.toString()]: handleAsync({
    resolved: (state, { enrollmentID, result }) => {
      if (result.data.success) {
        return {
          ...state,
          [enrollmentID]: {
            ...state[enrollmentID],
            enrollment_state: 'rejected',
            displayState: 'acted',
          },
        }
      } else { return state }
    },
  }),
  [hideInvite.toString()]: (state, { payload }) => {
    let entity = { ...state[payload.enrollmentID] }
    entity.hidden = true
    return {
      ...state,
      ...{ [payload.enrollmentID]: entity },
    }
  },
}, {})

export const enrollmentUsers: Reducer<UserProfileState, any> = handleActions({
  [refreshEnrollments.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = fromPairs(result.data
        .map((enrollment) => {
          let incomingUser = enrollment.user
          let userState = state[incomingUser.id] || {}

          let newState = {
            ...userState,
            data: {
              ...userState.data,
              ...incomingUser,
            },
          }

          return [incomingUser.id, newState]
        }))
      return { ...state, ...incoming }
    },
  }),
}, {})
