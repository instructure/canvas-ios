/**
 * @flow
 */

import 'react-native'
import React from 'react'
import ActivityIndicatorView from '../components/ActivityIndicatorView'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders activity indicator view correctly', () => {
  let tree = renderer.create(
    <ActivityIndicatorView />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
