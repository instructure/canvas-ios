//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import { quizData } from '../reducer'
import { default as DetailsActions } from '../details/actions'
import { default as EditActions } from '../edit/actions'
import * as template from '../../../__templates__'

const { refreshQuiz } = DetailsActions
const { quizUpdated } = EditActions

describe('quizData', () => {
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
