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
