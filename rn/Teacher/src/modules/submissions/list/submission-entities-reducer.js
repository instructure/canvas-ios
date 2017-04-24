// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import SpeedgraderActions from '../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment } = SpeedgraderActions

export const submissions: Reducer<SubmissionsState, any> = handleActions({
  [refreshSubmissions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, submission) => ({
          ...incoming,
          [submission.id]: submission,
        }), {})
      return { ...state, ...incoming }
    },
  }),
  [excuseAssignment.toString()]: handleAsync({
    pending: (state, { submissionID }) => {
      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          excused: true,
        },
      }
    },
    rejected: (state, { submissionID }) => {
      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          excused: false,
        },
      }
    },
  }),
}, {})
