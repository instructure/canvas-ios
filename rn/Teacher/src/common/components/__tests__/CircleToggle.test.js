// @flow

import React from 'react'
import { Image } from 'react-native'
import CircleToggle from '../CircleToggle'
import Images from '../../../images'
import explore from '../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest.mock('TouchableOpacity', () => 'Button')

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

test('CircleToggle measures itself on longpress and calls props.onLongPress', () => {
  const onLongPress = jest.fn()
  let button = renderer.create(
    <CircleToggle {...circleToggleProps} onLongPress={onLongPress}>
      12
    </CircleToggle>
  )

  type MeasureFunc = (vx: number, vy: number, width: number, height: number, x: number, y: number) => void
  const measure = jest.fn((callback: MeasureFunc) => {
    callback(1, 2, 3, 4, 5, 6)
  })
  button.getInstance().buttonViewRef = { measure }

  const toggle = explore(button.toJSON()).selectByID(circleToggleProps.testID)
  toggle && toggle.props.onLongPress()
  expect(measure).toHaveBeenCalled()
  expect(onLongPress).toHaveBeenCalled()
})
