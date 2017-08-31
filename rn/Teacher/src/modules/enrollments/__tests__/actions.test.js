// @flow

import { EnrollmentsActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

let template = {
  ...require('../../../__templates__/enrollments'),
}

test('should refresh enrollments', async () => {
  const enrollments = [
    template.enrollment({ id: '45' }),
    template.enrollment({ id: '67' }),
  ]

  let actions = EnrollmentsActions({
    getCourseEnrollments: apiResponse(enrollments),
  })

  let result = await testAsyncAction(actions.refreshEnrollments('1'))

  expect(result).toMatchObject([
    {
      type: actions.refreshEnrollments.toString(),
      pending: true,
      payload: {
        courseID: '1',
      },
    },
    {
      type: actions.refreshEnrollments.toString(),
      payload: {
        result: { data: enrollments },
        courseID: '1',
      },
    },
  ])
})
