/* @flow */

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { default as ListActions } from './list/actions'
import { default as DetailsActions } from './details/actions'
import { default as EditActions } from './edit/actions'
import i18n from 'format-message'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const { refreshQuizzes } = ListActions
const { refreshQuiz } = DetailsActions
const { updateQuiz } = EditActions

export const refs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshQuizzes.toString(),
  i18n('There was a problem loading the quizzes.'),
  ({ result }) => result.data.map(quiz => quiz.id)
)

export const entities: Reducer<QuizzesState, any> = handleActions({
  [refreshQuizzes.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, quiz) => ({
          ...incoming,
          [quiz.id]: {
            data: quiz,
            pending: 0,
            error: null,
          },
        }), {})
      return { ...state, ...incoming }
    },
  }),
  [refreshQuiz.toString()]: handleAsync({
    resolved: (state, { result: [quiz], quizID }) => ({
      ...state,
      [quizID]: {
        ...state[quizID],
        data: quiz.data,
        pending: state[quizID] && state[quizID].pending ? state[quizID].pending - 1 : 0,
        error: null,
      },
    }),
  }),
  [updateQuiz.toString()]: handleAsync({
    pending: (state, { originalQuiz }) => ({
      ...state,
      [originalQuiz.id]: {
        ...state[originalQuiz.id],
        pending: state[originalQuiz.id] && state[originalQuiz.id].pending ? state[originalQuiz.id].pending + 1 : 1,
      },
    }),
    rejected: (state, { originalQuiz, error }) => ({
      ...state,
      [originalQuiz.id]: {
        ...state[originalQuiz.id],
        data: originalQuiz,
        pending: state[originalQuiz.id].pending - 1,
        error: parseErrorMessage(error),
      },
    }),
    resolved: (state, { updatedQuiz }) => ({
      ...state,
      [updatedQuiz.id]: {
        ...state[updatedQuiz.id],
        data: updatedQuiz,
        pending: state[updatedQuiz.id].pending - 1,
        error: null,
      },
    }),
  }),
}, {})
