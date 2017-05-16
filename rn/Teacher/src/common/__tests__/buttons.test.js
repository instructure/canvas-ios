/**
 * @flow
 */

import React from 'react'
import { Image } from 'react-native'
import { Button, LinkButton, CircleToggle } from '../buttons'
import Images from '../../images'
import explore from '../../../test/helpers/explore'
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

let circleToggleProps = {
  on: false,
  onPress: jest.fn(),
  value: '1',
  testID: 'circle-button',
}

test('renders circle toggle correctly', () => {
  let tree = renderer.create(
    <CircleToggle {...circleToggleProps}>4</CircleToggle>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders circle toggle when on correctly', () => {
  let tree = renderer.create(
    <CircleToggle {...circleToggleProps} on={true}>4</CircleToggle>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders circle toggle with an image', () => {
  let tree = renderer.create(
    <CircleToggle {...circleToggleProps}><Image source={Images.add}/></CircleToggle>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls onPress with the value', () => {
  let tree = renderer.create(
    <CircleToggle {...circleToggleProps}>1</CircleToggle>
  ).toJSON()

  let button = explore(tree).selectByID('circle-button') || {}
  button.props.onPress()

  expect(circleToggleProps.onPress).toHaveBeenCalledWith(circleToggleProps.value)
})
