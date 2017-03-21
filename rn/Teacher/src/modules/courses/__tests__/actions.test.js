// @flow

import { CoursesActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

test('refresh courses workflow', async () => {
  const courses = [courseTemplate.course()]
  const colors = courseTemplate.customColors()
  let actions = CoursesActions({ getCourses: apiResponse(courses), getCustomColors: apiResponse(colors) })
  const result = await testAsyncAction(actions.refreshCourses())

  expect(result).toMatchObject([
    {
      type: actions.refreshCourses.toString(),
      pending: true,
    },
    {
      type: actions.refreshCourses.toString(),
      payload: [{ data: courses }, { data: colors }],
    },
  ])
})
