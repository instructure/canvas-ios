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
  const assignee = template.assignee()
  let tree = renderer.create(
    <AssigneeRow assignee={assignee} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render correctly without image url', () => {
  const assignee = template.assignee({
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
  const assignee = template.assignee()
  let tree = renderer.create(
    <AssigneeRow assignee={assignee} onPress={onPress} onDelete={onDelete} />
  )

  tree.getInstance().onPress()
  tree.getInstance().onDelete()
  expect(onPress).toHaveBeenCalled()
  expect(onDelete).toHaveBeenCalled()
})
