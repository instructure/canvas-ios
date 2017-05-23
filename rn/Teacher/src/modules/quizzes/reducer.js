/* @flow */

import { Reducer, combineReducers } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { default as ListActions } from './list/actions'
import { default as DetailsActions } from './details/actions'
import { default as QuizSubmissionActions } from './submissions/actions'
import { default as EditActions } from './edit/actions'
import i18n from 'format-message'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const { refreshQuizzes } = ListActions
const { refreshQuiz } = DetailsActions
const { refreshQuizSubmissions } = QuizSubmissionActions
const { updateQuiz } = EditActions

export const refs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshQuizzes.toString(),
  i18n('There was a problem loading the quizzes.'),
  ({ result }) => result.data.map(quiz => quiz.id)
)

export const quizSubmissions: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshQuizSubmissions.toString(),
  i18n('There was a problem loading the quiz submissions.'),
  ({ result }) => result.data.quiz_submissions.map(qs => qs.id)
)

export const submissions: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshQuizSubmissions.toString(),
  i18n('There was a problem loading the quiz submissions.'),
  ({ result }) => result.data.submissions.map(s => s.id)
)

const quiz = quiz => quiz || {}
const pending = pending => pending || 0
const error = error => error || null

const quizContent = combineReducers({
  data: quiz,
  quizSubmissions,
  submissions,
  pending,
  error,
})

const defaultQuizContents = {
  quizSubmissions: { refs: [], pending: 0 },
  submissions: { refs: [], pending: 0 },
}

export const quizData: Reducer<QuizzesState, any> = handleActions({
  [refreshQuizzes.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const incoming = result.data
        .reduce((incoming, quiz) => ({
          ...incoming,
          [quiz.id]: {
            ...defaultQuizContents,
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

export function quizzes (state: any = {}, action: any): any {
  let newState = state
  if (action.payload && action.payload.quizID) {
    const quizID = action.payload.quizID
    const currentQuizState: any = state[quizID] || { pending: 0, data: {} }
    const quizState = quizContent(currentQuizState, action)
    newState = {
      ...state,
      [quizID]: quizState,
    }
  }
  return quizData(newState, action)
}
