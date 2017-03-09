/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { Button } from '../buttons'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders button correctly', () => {
  let tree = renderer.create(
    <Button />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
