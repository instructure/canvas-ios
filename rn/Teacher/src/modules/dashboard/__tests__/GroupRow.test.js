// @flow

import React from 'react'
import 'react-native'
import GroupRow from '../GroupRow'
import renderer from 'react-test-renderer'

test('group row renders', () => {
  const tree = renderer.create(
    <GroupRow
      style={{ margin: 8 }}
      color='blue'
      name='Study Group 3'
      courseName='Bio 101'
      term='Spring 2020' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
