/* @flow */

import { CourseSectionActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../api/canvas-api/__templates__/section'),
  ...require('../../../api/canvas-api/__templates__/course'),
}

test('refresh assignment list', async () => {
  let course = template.course()
  const section = template.section({
    course_id: course.id,
  })
  let actions = CourseSectionActions({ getCourseSections: apiResponse([section]) })
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
