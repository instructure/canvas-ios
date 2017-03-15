/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { Button, LinkButton } from '../buttons'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders button correctly', () => {
  let tree = renderer.create(
    <Button />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders link correctly', () => {
  let tree = renderer.create(
    <LinkButton />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
