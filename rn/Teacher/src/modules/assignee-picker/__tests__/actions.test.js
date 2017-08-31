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
