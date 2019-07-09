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

import { Actions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

let template = {
  ...require('../../../../__templates__/submissions'),
}

test('should refresh submissions', async () => {
  const submissions = [
    template.submissionHistory([{ id: '45' }], []),
    template.submissionHistory([{ id: '67' }], []),
  ]

  let actions = Actions({
    getSubmissions: apiResponse(submissions),
  })

  let result = await testAsyncAction(actions.refreshSubmissions('1', '4', false))

  expect(result).toMatchObject([
    {
      type: actions.refreshSubmissions.toString(),
      pending: true,
      payload: {
        assignmentID: '4',
      },
    },
    {
      type: actions.refreshSubmissions.toString(),
      payload: {
        result: { data: submissions },
        assignmentID: '4',
      },
    },
  ])
})

test('should refresh submission summary', async () => {
  let summary = template.submissionSummary({ graded: 1, ungraded: 1, not_submitted: 1 })

  let actions = Actions({
    refreshSubmissionSummary: apiResponse(summary),
  })

  let result = await testAsyncAction(actions.refreshSubmissionSummary('1', '1', false))

  expect(result).toMatchObject([
    {
      type: actions.refreshSubmissionSummary.toString(),
      pending: true,
      payload: {
        courseID: '1', assignmentID: '1',
      },
    },
    {
      type: actions.refreshSubmissionSummary.toString(),
      payload: {
        result: { data: summary },
        courseID: '1',
        assignmentID: '1',
      },
    },
  ])
})

test('it should refresh user submissions', async () => {
  let submissions = [
    template.submissionHistory([{ id: '1' }], []),
    template.submissionHistory([{ id: '2' }], []),

  ]
  let actions = Actions({
    getSubmissionsForUsers: apiResponse(submissions),
  })

  let result = await testAsyncAction(actions.getUserSubmissions('1', '2'))

  expect(result).toMatchObject([
    {
      type: actions.getUserSubmissions.toString(),
      pending: true,
    },
    {
      type: actions.getUserSubmissions.toString(),
      payload: {
        result: {
          data: submissions,
        },
      },
    },
  ])
})
