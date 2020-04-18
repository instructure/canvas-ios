//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import React from 'react'
import { Image } from 'react-native'
import CircleToggle from '../CircleToggle'
import Images from '../../../images'
import explore from '../../../../test/helpers/explore'
import renderer from 'react-test-renderer'

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'Button')

let circleToggleProps = {
  on: false,
  onPress: jest.fn(),
  value: '1',
  itemID: '1',
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

  expect(circleToggleProps.onPress).toHaveBeenCalledWith(circleToggleProps.value, circleToggleProps.itemID)
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
