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

import { QuizSubmissionActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

test('should refresh submissions', async () => {
  const response = [{ data: 'hi' }]

  let actions = QuizSubmissionActions({
    getQuizSubmissions: apiResponse(response),
  })

  let result = await testAsyncAction(actions.refreshQuizSubmissions('1', '4'))

  expect(result).toMatchObject([
    {
      type: actions.refreshQuizSubmissions.toString(),
      pending: true,
      payload: {
        quizID: '4',
      },
    },
    {
      type: actions.refreshQuizSubmissions.toString(),
      payload: {
        result: { data: response },
        quizID: '4',
      },
    },
  ])
})

test('refresh includes assignmentID if provided', () => {
  const actions = QuizSubmissionActions({
    getQuizSubmissions: () => {},
  })
  let result = actions.refreshQuizSubmissions('1', '2', '3')
  expect(result).toMatchObject({
    type: actions.refreshQuizSubmissions.toString(),
    payload: {
      quizID: '2',
      assignmentID: '3',
    },
  })
})
