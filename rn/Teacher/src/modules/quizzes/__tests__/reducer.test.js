/* @flow */

import { refs, entities } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as DetailsActions } from '../details/actions'

const { refreshQuizzes } = ListActions
const { refreshQuiz } = DetailsActions

const template = {
  ...require('../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../api/canvas-api/__templates__/error'),
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

describe('entities', () => {
  describe('refreshQuizzes', () => {
    it('handles resolved', () => {
      const one = template.quiz({ id: '1' })
      const two = template.quiz({ id: '2' })
      const resolved = {
        type: refreshQuizzes.toString(),
        payload: { result: { data: [one, two] } },
      }
      expect(
        entities({}, resolved)
      ).toEqual({
        '1': {
          data: one,
          pending: 0,
          error: null,
        },
        '2': {
          data: two,
          pending: 0,
          error: null,
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
          result: { data: quiz },
          courseID: '1',
          quizID: quiz.id,
        },
      }
      expect(
        entities({}, resolved)
      ).toEqual({
        '1': {
          data: quiz,
          pending: 0,
          error: null,
        },
      })
    })
  })
})
