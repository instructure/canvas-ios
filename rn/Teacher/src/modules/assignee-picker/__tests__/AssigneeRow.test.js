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
