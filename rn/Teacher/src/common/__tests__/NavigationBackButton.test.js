/**
 * @flow
 */

import 'react-native'
import React from 'react'
import NavigationBackButton from '../components/NavigationBackButton'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders button correctly', () => {
  let tree = renderer.create(
    <NavigationBackButton />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
