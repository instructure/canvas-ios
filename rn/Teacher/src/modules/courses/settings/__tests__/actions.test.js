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
