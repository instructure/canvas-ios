//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* @flow */

import { refs, quizData } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as DetailsActions } from '../details/actions'
import { default as EditActions } from '../edit/actions'

const { refreshQuizzes } = ListActions
const { refreshQuiz } = DetailsActions
const { quizUpdated } = EditActions

const template = {
  ...require('../../../__templates__/quiz'),
  ...require('../../../__templates__/error'),
}

describe('refs', () => {
  describe('refreshQuizzes', () => {
    const data = [
      template.quiz({ id: '1' }),
      template.quiz({ id: '2' }),
    ]

    const pending = {
      type: refreshQuizzes.toString(),
      pending: true,
    }

    it('handles pending', () => {
      expect(
        refs(undefined, pending)
      ).toEqual({
        refs: [],
        pending: 1,
      })
    })

    it('handles resolved', () => {
      const initialState = refs(undefined, pending)
      const resolved = {
        type: refreshQuizzes.toString(),
        payload: { result: { data } },
      }
      expect(
        refs(initialState, resolved)
      ).toEqual({
        pending: 0,
        refs: ['1', '2'],
      })
    })

    it('handles rejected', () => {
      const initialState = refs(undefined, pending)
      const rejected = {
        type: refreshQuizzes.toString(),
        error: true,
        payload: { error: template.error('User not authorized') },
      }
      expect(
        refs(initialState, rejected)
      ).toEqual({
        refs: [],
        pending: 0,
        error: `There was a problem loading the quizzes.

User not authorized`,
      })
    })
  })
})

describe('quizData', () => {
  describe('refreshQuizzes', () => {
    it('handles resolved', () => {
      const one = template.quiz({ id: '1' })
      const two = template.quiz({ id: '2' })
      const resolved = {
        type: refreshQuizzes.toString(),
        payload: { result: { data: [one, two] } },
      }

      expect(
        quizData({}, resolved)
      ).toEqual({
        '1': {
          data: one,
          pending: 0,
          error: null,
          quizSubmissions: {
            pending: 0,
            refs: [],
          },
          submissions: {
            pending: 0,
            refs: [],
          },
        },
        '2': {
          data: two,
          pending: 0,
          error: null,
          quizSubmissions: {
            pending: 0,
            refs: [],
          },
          submissions: {
            pending: 0,
            refs: [],
          },
        },
      })
    })
  })

  describe('refreshQuiz', () => {
    it('handles resolved', () => {
      const quiz = template.quiz({ id: '1' })
      const resolved = {
        type: refreshQuiz.toString(),
        payload: {
          result: [{ data: quiz }],
          courseID: '1',
          quizID: quiz.id,
        },
      }
      expect(
        quizData({}, resolved)
      ).toEqual({
        '1': {
          data: quiz,
          pending: 0,
          error: null,
        },
      })
    })
  })

  describe('quizUpdated', () => {
    it('should update the quiz in the store', () => {
      const updatedQuiz = template.quiz({ id: '1' })
      const resolved = {
        type: quizUpdated.toString(),
        payload: {
          updatedQuiz,
        },
      }

      const result = quizData({ '1': {} }, resolved)
      expect(result['1'].data).toMatchObject(updatedQuiz)
    })
  })
})
