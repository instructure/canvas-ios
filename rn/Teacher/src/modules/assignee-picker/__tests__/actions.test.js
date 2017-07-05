/* @flow */

import { AssigneeSearchActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/section'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/group'),
}

test('refresh course sections', async () => {
  const course = template.course()
  const section = template.section({
    course_id: course.id,
  })
  const actions = AssigneeSearchActions({ getCourseSections: apiResponse([section]) })
  const result = await testAsyncAction(actions.refreshSections(course.id), {})

  expect(result).toMatchObject([{
    type: actions.refreshSections.toString(),
    pending: true,
    payload: {},
  },
  {
    type: actions.refreshSections.toString(),
    payload: {
      result: { data: [section] },
    },
  },
  ])
})

test('refreshGroupsForCategory', async () => {
  const groupCategoryID = '123456789'
  const group = template.section({
    group_category_id: groupCategoryID,
  })
  let actions = AssigneeSearchActions({ getGroupsForCategoryID: apiResponse([group]) })
  const result = await testAsyncAction(actions.refreshGroupsForCategory(groupCategoryID), {})

  expect(result).toMatchObject([{
    type: actions.refreshGroupsForCategory.toString(),
    pending: true,
    payload: {},
  },
  {
    type: actions.refreshGroupsForCategory.toString(),
    payload: {
      result: { data: [group] },
    },
  },
  ])
})
