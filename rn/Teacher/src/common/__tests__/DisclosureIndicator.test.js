/**
 * @flow
 */

import 'react-native'
import React from 'react'
import DisclosureIndicator from '../components/DisclosureIndicator'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders button correctly', () => {
  let tree = renderer.create(
    <DisclosureIndicator />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
