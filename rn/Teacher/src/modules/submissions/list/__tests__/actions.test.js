// @flow

import { Actions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

let template = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
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
