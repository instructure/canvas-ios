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

const { refreshQuizzes } = ListActions
const { refreshQuiz } = DetailsActions
const { refreshQuizSubmissions } = QuizSubmissionActions
const { quizUpdated } = EditActions

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
  [quizUpdated.toString()]: (state, { payload }) => {
    const quiz = payload.updatedQuiz
    return {
      ...state,
      [quiz.id]: {
        ...state[quiz.id],
        data: quiz,
      },
    }
  },
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
