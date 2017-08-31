//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
