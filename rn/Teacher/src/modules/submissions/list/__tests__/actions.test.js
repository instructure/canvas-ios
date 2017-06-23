// @flow

import { SubmissionActions } from '../actions'
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

  let actions = SubmissionActions({
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
