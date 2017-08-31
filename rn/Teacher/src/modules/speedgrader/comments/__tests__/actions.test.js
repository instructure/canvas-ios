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

import { SubmissionCommentActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

let template = {
  ...require('../../../../__templates__/submissions'),
}

test('should refresh submissions', async () => {
  const submission = template.submissionHistory()

  const actions = SubmissionCommentActions({
    commentOnSubmission: apiResponse(submission),
  })

  const comment = { type: 'text', message: 'Hello!', groupComment: false }
  const result = await testAsyncAction(
    actions.makeAComment('1', '10', '100', comment)
  )

  expect(result).toMatchObject([
    {
      type: actions.makeAComment.toString(),
      pending: true,
      payload: {
        assignmentID: '10',
        userID: '100',
        comment,
        handlesError: true,
      },
    },
    {
      type: actions.makeAComment.toString(),
      payload: {
        result: { data: submission },
        assignmentID: '10',
        userID: '100',
        comment,
        handlesError: true,
      },
    },
  ])

  expect(result[0].payload.timestamp).toBeDefined()
  expect(result[1].payload.timestamp).toBeDefined()
  expect(result[0].payload.localID).toBeDefined()
  expect(result[1].payload.localID).toBeDefined()
})

test('deletePendingComment parameters get included in the payload', () => {
  const actions = SubmissionCommentActions({})
  let result = actions.deletePendingComment('1', '2', '3')
  expect(result).toEqual({
    type: actions.deletePendingComment.toString(),
    payload: {
      assignmentID: '1',
      userID: '2',
      localID: '3',
    },
  })
})
