//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
