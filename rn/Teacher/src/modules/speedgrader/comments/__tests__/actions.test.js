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
