/**
 * @flow
 */

import React from 'react'
import { Button, LinkButton } from '../buttons'
import renderer from 'react-test-renderer'

jest.mock('react-native-button', () => 'Button')

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
