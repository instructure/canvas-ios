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

// @flow

import Actions from '../actions'
import { quizSubmissions, quizAssignmentSubmissions } from '../reducer'

const { refreshQuizSubmissions } = Actions
const template = {
  ...require('../../../../__templates__/quizSubmission'),
  ...require('../../../../__templates__/submissions'),
}
describe('QuizSubmissionList reducer', () => {
  test('it captures entities for quiz submissions', () => {
    const qs1 = template.quizSubmission({ id: '1' })
    const qs2 = template.quizSubmission({ id: '2' })

    let data = {
      quiz_submissions: [
        qs1,
        qs2,
      ],
    }

    const action = {
      type: refreshQuizSubmissions.toString(),
      payload: { result: { data } },
    }

    expect(quizSubmissions({}, action)).toEqual({
      [qs1.id]: {
        data: qs1,
        pending: 0,
        error: null,
      },
      [qs2.id]: {
        data: qs2,
        pending: 0,
        error: null,
      },
    })
  })

  test('it captures entities for quiz submissions', () => {
    const s1 = template.submission({ id: '1' })

    let data = {
      submissions: [s1],
    }

    const action = {
      type: refreshQuizSubmissions.toString(),
      payload: { result: { data } },
    }

    expect(quizAssignmentSubmissions({}, action)).toEqual({
      [s1.id]: {
        submission: s1,
        pending: 0,
        error: null,
      },
    })
  })
})
