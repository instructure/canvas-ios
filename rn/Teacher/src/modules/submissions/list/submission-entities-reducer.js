// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import SpeedGraderActions from '../../speedgrader/actions'

const { refreshSubmissions } = Actions
const { excuseAssignment } = SpeedGraderActions

export const submissions: Reducer<SubmissionsState, any> = handleActions({
  [refreshSubmissions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, submission) => ({
          ...incoming,
          [submission.id]: {
            submission,
            pending: 0,
            error: null,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),

  [excuseAssignment.toString()]: handleAsync({
    pending: (state, { submissionID }) => {
      if (!submissionID) { return state }
      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          submission: {
            ...state.submission,
            excused: true,
          },
        },
      }
    },
    resolved: (state, { submissionID, result }) => {
      if (submissionID) return state

      return {
        ...state,
        [result.data.id]: {
          submission: result.data,
          pending: 0,
          error: null,
        },
      }
    },
    rejected: (state, { submissionID }) => {
      if (!submissionID) { return state }
      return {
        ...state,
        [submissionID]: {
          ...state[submissionID],
          submission: {
            ...state.submission,
            excused: false,
          },
        },
      }
    },
  }),
}, {})
