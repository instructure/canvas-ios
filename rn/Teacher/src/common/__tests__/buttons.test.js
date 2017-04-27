/**
 * @flow
 */

import React from 'react'
import { Image } from 'react-native'
import { Button, LinkButton, CircleToggle } from '../buttons'
import Images from '../../images'

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

test('renders circle toggle correctly', () => {
  let tree = renderer.create(
    <CircleToggle on={false}>4</CircleToggle>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders circle toggle when on correctly', () => {
  let tree = renderer.create(
    <CircleToggle on>4</CircleToggle>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders circle toggle with an image', () => {
  let tree = renderer.create(
    <CircleToggle on={false}><Image source={Images.add}/></CircleToggle>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
