/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { Text, Paragraph, Heading1 } from '../text'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders text correctly', () => {
  let tree = renderer.create(
    <Text />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders heading1 correctly', () => {
  let tree = renderer.create(
    <Heading1 />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders paragraph correctly', () => {
  let tree = renderer.create(
    <Paragraph />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
