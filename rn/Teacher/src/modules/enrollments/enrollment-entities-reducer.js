// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import fromPairs from 'lodash/fromPairs'

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
