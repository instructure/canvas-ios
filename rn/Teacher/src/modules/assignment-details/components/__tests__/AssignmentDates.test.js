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

/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentDates from '../AssignmentDates'
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../../__templates__/assignments'),
}

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    due_at: undefined,
    all_dates: [template.assignmentDueDate({ base: true }), template.assignmentDueDate({ base: false })],
  })
  let tree = renderer.create(
    <AssignmentDates assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    lock_at: (new Date(0).toISOString()),
  })
  let tree = renderer.create(
    <AssignmentDates assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
