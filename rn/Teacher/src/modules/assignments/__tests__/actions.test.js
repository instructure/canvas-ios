/* @flow */

import { AssignmentListActions } from '../actions'
import { defaultState } from '../assignments-reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
}

test('refresh assignment list', async () => {
  const course = template.course()
  const groups = [template.assignmentGroup()]
  let actions = AssignmentListActions({ getCourseAssignmentGroups: apiResponse(groups) })
  const result = await testAsyncAction(actions.refreshAssignmentList(course.id), defaultState)

  expect(result).toMatchObject([{
    type: actions.refreshAssignmentList.toString(),
    pending: true,
    payload: {
      courseID: course.id,
    },
  },
  {
    type: actions.refreshAssignmentList.toString(),
    payload: {
      result: { data: groups },
      courseID: course.id,
    },
  },
  ])
})
