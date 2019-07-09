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

import { AssigneeSearchActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../__templates__/section'),
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/group'),
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
