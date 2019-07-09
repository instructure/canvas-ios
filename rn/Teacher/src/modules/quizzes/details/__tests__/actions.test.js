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

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../__templates__/assignments'),
}

describe('refreshQuiz', () => {
  it('should refresh quiz', async () => {
    const quiz = template.quiz({
      title: 'refreshed',
      assignment_id: '32',
    })
    const assignmentGroups = [template.assignmentGroup()]
    const assignment = template.assignment({ id: '32' })
    const api = {
      getQuiz: apiResponse(quiz),
      getAssignmentGroups: apiResponse(assignmentGroups),
      getAssignment: apiResponse(assignment),
    }
    const actions = Actions(api)
    const action = actions.refreshQuiz('21', '11509', '32')
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.refreshQuiz.toString(),
        pending: true,
      },
      {
        type: actions.refreshQuiz.toString(),
        payload: {
          result: [{ data: quiz }, { data: assignmentGroups }, { data: assignment }],
          courseID: '21',
          quizID: '11509',
        },
      },
    ])
  })
})
