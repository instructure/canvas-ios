// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import fromPairs from 'lodash/fromPairs'
import { type UserProfileState } from '../users/reducer'

export const defaultEntities: EnrollmentsState = {}
const { refreshEnrollments } = Actions

export const enrollments: Reducer<EnrollmentsState, any> = handleActions({
  [refreshEnrollments.toString()]: handleAsync({
    resolved: (state, { result }) => {
      console.log('result:', result)
      const incoming = fromPairs(result.data
        .map(enrollment => [enrollment.id, enrollment]))
      return { ...state, ...incoming }
    },
  }),
}, {})

export const enrollmentUsers: Reducer<UserProfileState, any> = handleActions({
  [refreshEnrollments.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = fromPairs(result.data
        .map((enrollment) => {
          const incomingUser = enrollment.user
          let user = state[incomingUser.id]
          if (user) {
            Object.assign(user, incomingUser)
          } else {
            user = incomingUser
          }
          return [user.id, user]
        }))
      return { ...state, ...incoming }
    },
  }),
}, {})
