/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { NoCourses } from '../NoCourses'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders NoCourses correctly', () => {
  let tree = renderer.create(
    <NoCourses />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
