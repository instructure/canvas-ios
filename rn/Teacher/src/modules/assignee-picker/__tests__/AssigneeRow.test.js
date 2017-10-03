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
import AssigneeRow from '../AssigneeRow'
import renderer from 'react-test-renderer'

const template = {
  ...require('../__template__/Assignee.js'),
}

test('render correctly', () => {
  const assignee = template.enrollmentAssignee()
  let tree = renderer.create(
    <AssigneeRow assignee={assignee} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render correctly without image url', () => {
  const assignee = template.enrollmentAssignee({
    imageURL: null,
  })
  let tree = renderer.create(
    <AssigneeRow assignee={assignee} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('callbacks get called correctly', () => {
  const onPress = jest.fn()
  const onDelete = jest.fn()
  const assignee = template.enrollmentAssignee()
  let tree = renderer.create(
    <AssigneeRow assignee={assignee} onPress={onPress} onDelete={onDelete} />
  )

  tree.getInstance().onPress()
  tree.getInstance().onDelete()
  expect(onPress).toHaveBeenCalled()
  expect(onDelete).toHaveBeenCalled()
})

test('callbacks do not get called if they do not exist', () => {
  const onPress = jest.fn()
  const onDelete = jest.fn()
  const assignee = template.enrollmentAssignee()
  let tree = renderer.create(
    <AssigneeRow assignee={assignee}/>
  )

  tree.getInstance().onPress()
  tree.getInstance().onDelete()
  expect(onPress).not.toHaveBeenCalled()
  expect(onDelete).not.toHaveBeenCalled()
})
