// @flow

import React from 'react'
import 'react-native'
import UI from '../UI'
import renderer from 'react-test-renderer'

test('renders UI correctly', () => {
  let tree = renderer.create(
    <UI />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
