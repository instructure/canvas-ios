// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'

const { refreshQuizSubmissions } = Actions

export const quizSubmissions: Reducer<SubmissionsState, any> = handleActions({
  [refreshQuizSubmissions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data.quiz_submissions
        .reduce((incoming, submission) => ({
          ...incoming,
          [submission.id]: {
            data: submission,
            pending: 0,
            error: null,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),
}, {})

export const quizAssignmentSubmissions: Reducer<SubmissionsState, any> = handleActions({
  [refreshQuizSubmissions.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data.submissions
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
}, {})
