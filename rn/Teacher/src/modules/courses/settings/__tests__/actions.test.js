/* @flow */

import { CourseSettingsActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

const template = {
  ...require('../../../../__templates__/course'),
}

test('updateCourse', async () => {
  let oldCourse = template.course()
  let newCourse = { ...oldCourse, name: 'test updateCourse' }

  let api = {
    updateCourse: apiResponse(newCourse),
  }
  let actions = CourseSettingsActions(api)
  let action = actions.updateCourse(newCourse, oldCourse)

  let result = await testAsyncAction(action)

  expect(result).toMatchObject([
    {
      type: actions.updateCourse.toString(),
      pending: true,
      payload: {
        oldCourse,
        course: newCourse,
        handlesError: true,
        courseID: oldCourse.id,
      },
    },
    {
      type: actions.updateCourse.toString(),
      payload: {
        oldCourse,
        course: newCourse,
        handlesError: true,
        courseID: oldCourse.id,
      },
    },
  ])
})
