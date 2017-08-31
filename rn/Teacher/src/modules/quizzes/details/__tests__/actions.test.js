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
