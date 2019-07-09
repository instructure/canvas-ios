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
